local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Safe environment access (referencing farm_settings.lua style)
local function GetEnv()
    if type(getgenv) == "function" then
        return getgenv()
    end
    return shared
end

local env = GetEnv()
local LocalPlayer = Players.LocalPlayer

local ChestFarm = {}
local ActiveTween = nil
local ActiveBodyVelocity = nil
local ActiveNoclip = nil

-- ========================================
-- MOVEMENT / BYPASS LOGIC
-- ========================================

local function StopTween()
    if ActiveTween then ActiveTween:Cancel() ActiveTween = nil end
    if ActiveBodyVelocity then ActiveBodyVelocity:Destroy() ActiveBodyVelocity = nil end
    if ActiveNoclip then ActiveNoclip:Disconnect() ActiveNoclip = nil end
    
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.PlatformStand = false
            char.Humanoid.Sit = false
        end
    end
end

local function TweenTo(targetCFrame)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end
    
    StopTween()
    
    local hrp = char.HumanoidRootPart
    local humanoid = char.Humanoid
    
    humanoid.Sit = false
    humanoid.PlatformStand = true
    
    -- Anti-Gravity / Physics Freeze (Bypass Logic)
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(1, 1, 1) * math.huge
    bv.Parent = hrp
    ActiveBodyVelocity = bv
    
    -- Speed Calculation (High speed for efficiency)
    local speed = env.TweenSpeed or 400
    
    -- Speed Limit Logic: Improved for speed (same as island TP)
    if speed < 300 then speed = 300 end
    if speed > 850 then speed = 850 end -- Allow up to 850
    
    local dist = (hrp.Position - targetCFrame.Position).Magnitude
    local time = dist / speed
    
    -- Noclip & Physics Override Loop
    ActiveNoclip = RunService.RenderStepped:Connect(function()
        if not char or not char.Parent then StopTween() return end
        
        -- Noclip
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then 
                v.CanCollide = false 
            end
        end
        
        -- Aggressive Velocity Freeze (same as island TP bypass)
        if hrp then
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            hrp.RotVelocity = Vector3.new(0,0,0)
        end
        
        if humanoid then
            humanoid.PlatformStand = true
            humanoid:ChangeState(11) -- StrafingNoPhysics (Anti-Rubberband)
        end
    end)
    
    local info = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, info, {CFrame = targetCFrame})
    ActiveTween = tween
    
    tween:Play()
    return tween, time
end

-- ========================================
-- CHEST DETECTION WITH CACHING
-- ========================================

local ChestCache = {}
local LastScanTime = 0
local SCAN_COOLDOWN = 2 -- Only rescan every 2 seconds

local function GetChests()
    local currentTime = os.clock()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    -- Use cached chests if scan was recent
    if currentTime - LastScanTime < SCAN_COOLDOWN then
        -- Filter out destroyed chests from cache
        local validChests = {}
        for _, chest in ipairs(ChestCache) do
            if chest and chest.Parent then
                table.insert(validChests, chest)
            end
        end
        ChestCache = validChests
        
        -- Sort by distance
        if hrp and #ChestCache > 0 then
            table.sort(ChestCache, function(a, b)
                local posA = (a:IsA("Model") and a:GetPivot().Position) or a.Position
                local posB = (b:IsA("Model") and b:GetPivot().Position) or b.Position
                return (hrp.Position - posA).Magnitude < (hrp.Position - posB).Magnitude
            end)
        end
        
        return ChestCache
    end
    
    -- Perform new scan
    local chests = {}
    local scannedObjects = 0
    
    -- Optimized search - only look in Map/World areas
    local searchAreas = {Workspace.Map, Workspace}
    
    for _, searchArea in ipairs(searchAreas) do
        if not searchArea then continue end
        
        -- Non-recursive scan with yield to prevent lag
        for _, v in ipairs(searchArea:GetDescendants()) do
            scannedObjects = scannedObjects + 1
            
            -- Yield every 100 objects to prevent lag spike
            if scannedObjects % 100 == 0 then
                task.wait()
            end
            
            -- Check if it's a chest - more specific filtering
            if v.Name == "Chest" or v.Name:match("^Chest%d*$") then
                if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("Model") then
                    if v.Parent then -- Ensure it still exists
                        table.insert(chests, v)
                    end
                end
            end
        end
        
        -- Don't scan Workspace if Map had chests
        if #chests > 0 then break end
    end
    
    -- Update cache
    ChestCache = chests
    LastScanTime = currentTime
    
    -- Sort by distance to farm nearest first
    if hrp and #chests > 0 then
        table.sort(chests, function(a, b)
            local posA = (a:IsA("Model") and a:GetPivot().Position) or a.Position
            local posB = (b:IsA("Model") and b:GetPivot().Position) or b.Position
            return (hrp.Position - posA).Magnitude < (hrp.Position - posB).Magnitude
        end)
    end
    
    return chests
end

-- ========================================
-- MAIN LOOP
-- ========================================

function ChestFarm.StartLoop()
    task.spawn(function()
        while env.NyroxRunning do
            if not env.ChestFarm then 
                StopTween()
                task.wait(1)
                continue 
            end
            
            local chests = GetChests()
            
            if #chests == 0 then
                task.wait(1.5) -- No chests found, shorter wait
            else
                for _, chest in ipairs(chests) do
                    if not env.ChestFarm then break end
                    if not chest or not chest.Parent then continue end -- Chest already taken
                    
                    -- Get the chest's CFrame safely
                    local success, targetCFrame = pcall(function()
                        if chest:IsA("Model") then
                            return chest:GetPivot() or (chest.PrimaryPart and chest.PrimaryPart.CFrame) or chest:FindFirstChildOfClass("Part").CFrame
                        else
                            return chest.CFrame
                        end
                    end)
                    
                    if not success or not targetCFrame then continue end
                    
                    -- Tween to chest
                    local tween, duration = TweenTo(targetCFrame)
                    
                    -- Fast collection logic (similar to island TP)
                    local startTime = os.clock()
                    local timeout = duration + 1.5
                    
                    -- Wait with instant TP when close
                    while chest and chest.Parent and env.ChestFarm and (os.clock() - startTime < timeout) do
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local distance = (char.HumanoidRootPart.Position - targetCFrame.Position).Magnitude
                            
                            -- Instant TP when within range
                            if distance < 150 then
                                StopTween()
                                pcall(function()
                                    char:SetPrimaryPartCFrame(targetCFrame)
                                end)
                                task.wait(0.15) -- Minimal wait for collection
                                break
                            end
                        end
                        task.wait(0.05) -- Fast check interval
                    end
                    
                    StopTween()
                    task.wait(0.05) -- Minimal delay between chests
                end
            end
            task.wait(0.25) -- Faster delay between full scans
        end
        
        -- Cleanup on stop
        StopTween()
    end)
end

return ChestFarm