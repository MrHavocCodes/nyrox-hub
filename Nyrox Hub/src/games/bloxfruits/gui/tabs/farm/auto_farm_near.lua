local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local function GetEnv()
    if type(getgenv) == "function" then return getgenv() end
    return shared
end
local env = GetEnv()
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ========================================
-- FAST ATTACK REMOTES (FessHub Method)
-- ========================================

local FastAttackRemotes = {
    RegisterAttack = nil,
    RegisterHit = nil
}

pcall(function()
    local Modules = ReplicatedStorage:WaitForChild("Modules", 5)
    if Modules then
        local Net = Modules:FindFirstChild("Net")
        if Net then
            FastAttackRemotes.RegisterAttack = Net:FindFirstChild("RE/RegisterAttack") or Net:FindFirstChild("RegisterAttack")
            FastAttackRemotes.RegisterHit = Net:FindFirstChild("RE/RegisterHit") or Net:FindFirstChild("RegisterHit")
            
            if FastAttackRemotes.RegisterAttack and FastAttackRemotes.RegisterHit then
                print("[AutoFarm Near] ✅ Fast Attack Remotes found!")
            else
                print("[AutoFarm Near] ⚠️ Fast Attack Remotes not found - using fallback")
            end
        end
    end
end)

local AutoFarmNear = {}
local ActiveTween = nil
local ActiveBodyVelocity = nil
local ActiveNoclip = nil
local ActiveFastAttackLoop = nil
local CombatFramework = nil
local CameraShaker = nil
local CurrentTarget = nil

-- Default Settings
if env.FastAttackEnabled == nil then env.FastAttackEnabled = true end
if env.AutoM1Attack == nil then env.AutoM1Attack = true end
if env.AutoMagnetEnemy == nil then env.AutoMagnetEnemy = true end
if env.SelectedWeapon == nil then env.SelectedWeapon = "Combat" end
if env.MagnetRange == nil then env.MagnetRange = 350 end
if env.PositionFarmY == nil then env.PositionFarmY = 30 end
if env.TweenSpeed == nil then env.TweenSpeed = 350 end

-- ========================================
-- AUTO HAKI (FessHub Method)
-- ========================================

spawn(function()
    while wait(1) do
        pcall(function()
            if env.AutoFarmNear and not LocalPlayer.Character:FindFirstChild("HasBuso") then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
            end
        end)
    end
end)

-- ========================================
-- SIMULATION RADIUS (for BringMobs)
-- ========================================

spawn(function()
    while wait() do
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            end
        end)
    end
end)

-- Get nearby enemies for multi-hit
local function GetNearbyEnemies()
    local nearbyEnemies = {}
    local targetPart = nil
    
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local hrp = char.HumanoidRootPart
        local enemies = Workspace:FindFirstChild("Enemies")
        if not enemies then return end
        
        for _, enemy in pairs(enemies:GetChildren()) do
            local head = enemy:FindFirstChild("Head") or enemy:FindFirstChild("HumanoidRootPart")
            local hum = enemy:FindFirstChild("Humanoid")
            
            if head and hum and hum.Health > 0 then
                local distance = (hrp.Position - head.Position).Magnitude
                if distance < 100 then
                    table.insert(nearbyEnemies, {enemy, head})
                    if not targetPart then
                        targetPart = head
                    end
                end
            end
        end
    end)
    
    return targetPart, nearbyEnemies
end

-- Fast Attack using Remotes (FessHub Method)
local function FastAttackRemote()
    pcall(function()
        if FastAttackRemotes.RegisterAttack and FastAttackRemotes.RegisterHit then
            local targetPart, nearbyEnemies = GetNearbyEnemies()
            
            if targetPart and #nearbyEnemies > 0 then
                FastAttackRemotes.RegisterAttack:FireServer(0.1)
                FastAttackRemotes.RegisterHit:FireServer(targetPart, nearbyEnemies)
            end
        end
    end)
end

-- Simple Equip Weapon
local function EquipWeapon(toolName)
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char.Parent then return end
        
        -- Already equipped?
        if char:FindFirstChild(toolName) then return end
        
        -- Equip from backpack
        local tool = LocalPlayer.Backpack:FindFirstChild(toolName)
        if tool then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:EquipTool(tool)
            end
        end
    end)
end

-- MAIN ATTACK FUNCTION (FessHub Style)
local function Attack()
    pcall(function()
        if not env.SelectedWeapon then return end
        
        local char = LocalPlayer.Character
        if not char or not char.Parent then return end
        
        -- Equip weapon first
        EquipWeapon(env.SelectedWeapon)
        
        -- Method 1: Fast Attack Remotes (PRIMARY - WORKING)
        if FastAttackRemotes.RegisterAttack and FastAttackRemotes.RegisterHit then
            FastAttackRemote()
        end
        
        -- Method 2: Tool Activate (Fallback)
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and tool.Activate then
            tool:Activate()
        end
    end)
end

local function FastAttack()
    Attack()
end

-- ========================================
-- NETWORK OWNER CHECK (Silver Hub Method)
-- ========================================

local function InMyNetWork(object)
    if not object or not object.Parent then return false end
    
    -- Method 1: Use isnetworkowner if available
    if isnetworkowner then
        local success, result = pcall(isnetworkowner, object)
        if success then return result end
    end
    
    -- Method 2: Distance-based check
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local dist = (object.Position - char.HumanoidRootPart.Position).Magnitude
        if dist <= 350 then
            return true
        end
    end
    
    return false
end

-- ========================================
-- BRING MOBS (MAGNET) SYSTEM
-- ========================================

local function BringMobs(mainTarget)
    if not env.AutoMagnetEnemy then return end
    if not mainTarget or not mainTarget.Parent then return end
    
    local mainHRP = mainTarget:FindFirstChild("HumanoidRootPart")
    if not mainHRP or not mainHRP.Parent then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return end
    
    -- Increase network radius
    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", 2000)
    end)
    
    local magnetRange = env.MagnetRange or 350
    local bringPos = mainHRP.CFrame * CFrame.new(0, -15, 0)
    
    for _, mob in ipairs(enemies:GetChildren()) do
        if mob ~= mainTarget and mob.Parent then
            local mobHum = mob:FindFirstChild("Humanoid")
            local mobHRP = mob:FindFirstChild("HumanoidRootPart")
            
            if mobHum and mobHum.Health > 0 and mobHRP and mobHRP.Parent then
                local dist = (hrp.Position - mobHRP.Position).Magnitude
                
                if dist <= magnetRange and InMyNetWork(mobHRP) then
                    pcall(function()
                        mobHRP.CFrame = bringPos
                        mobHRP.Velocity = Vector3.new(0, 0, 0)
                        mobHRP.CanCollide = false
                        mobHum.WalkSpeed = 0
                        mobHum.JumpPower = 0
                        
                        -- Destroy animator to prevent animations resetting position
                        if mobHum:FindFirstChild("Animator") then
                            mobHum.Animator:Destroy()
                        end
                        
                        -- Lock in position
                        mobHum:ChangeState(11)
                        mobHum:ChangeState(14)
                    end)
                end
            end
        end
    end
end

-- ========================================
-- MOVEMENT SYSTEM
-- ========================================

local function StopTween()
    if ActiveTween then 
        ActiveTween:Cancel() 
        ActiveTween = nil 
    end
    if ActiveBodyVelocity then 
        ActiveBodyVelocity:Destroy() 
        ActiveBodyVelocity = nil 
    end
    if ActiveNoclip then 
        ActiveNoclip:Disconnect() 
        ActiveNoclip = nil 
    end
    
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
            hrp.RotVelocity = Vector3.new(0,0,0)
        end
        
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
            humanoid.Sit = false
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = true
            end
        end
    end
end

local function TweenTo(targetCFrame)
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end
    
    StopTween()
    
    humanoid.PlatformStand = true
    
    -- Anti-Gravity
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(1, 1, 1) * math.huge
    bv.Parent = hrp
    ActiveBodyVelocity = bv
    
    local speed = env.TweenSpeed or 350
    local dist = (hrp.Position - targetCFrame.Position).Magnitude
    local time = dist / speed
    
    -- Noclip Loop
    ActiveNoclip = RunService.RenderStepped:Connect(function()
        if not char or not char.Parent then StopTween() return end
        
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then 
                v.CanCollide = false 
            end
        end
        
        if hrp then
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
        if humanoid then
            humanoid:ChangeState(11) -- StrafingNoPhysics
        end
    end)
    
    local info = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, info, {CFrame = targetCFrame})
    ActiveTween = tween
    
    tween:Play()
    return tween
end

-- ========================================
-- MAIN FARMING LOOP
-- ========================================

function AutoFarmNear.StartLoop()
    task.spawn(function()
        print("[AutoFarm Near] 🚀 Starting Professional Auto Farm System")
        print("[AutoFarm Near] ⚡ Fast Attack: " .. tostring(env.FastAttackEnabled))
        print("[AutoFarm Near] 🧲 Auto Magnet: " .. tostring(env.AutoMagnetEnemy))
        print("[AutoFarm Near] ⚔️  Weapon: " .. (env.SelectedWeapon or "Combat"))
        
        while env.NyroxRunning do
            if not env.AutoFarmNear then
                StopTween()
                task.wait(1)
                continue
            end
            
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if not hrp then
                task.wait(1)
                continue
            end
            
            -- Find nearest enemy
            local enemies = Workspace:FindFirstChild("Enemies")
            local target = nil
            local minDist = math.huge
            
            if enemies then
                for _, mob in ipairs(enemies:GetChildren()) do
                    if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        local mobHRP = mob:FindFirstChild("HumanoidRootPart")
                        if mobHRP then
                            local dist = (hrp.Position - mobHRP.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                target = mob
                            end
                        end
                    end
                end
            end
            
            if target and target:FindFirstChild("HumanoidRootPart") then
                CurrentTarget = target
                local targetHRP = target.HumanoidRootPart
                local farmHeight = env.PositionFarmY or 30
                local targetPos = targetHRP.CFrame * CFrame.new(0, farmHeight, 0)
                local dist = (hrp.Position - targetHRP.Position).Magnitude
                
                -- Move to target if too far
                if dist > 50 then
                    TweenTo(targetPos)
                else
                    -- We're close - CONTINUOUS ATTACK LOOP (like BloxFruits.lua)
                    if ActiveTween then 
                        ActiveTween:Cancel() 
                        ActiveTween = nil 
                    end
                    
                    -- ⚔️ ATTACK CONTINUOUSLY while near target
                    while env.AutoFarmNear and target and target.Parent and target:FindFirstChild("HumanoidRootPart") do
                        local targetHRP = target.HumanoidRootPart
                        local currentDist = (hrp.Position - targetHRP.Position).Magnitude
                        
                        -- Target too far away or dead? Break to outer loop
                        if currentDist > 100 or (target:FindFirstChild("Humanoid") and target.Humanoid.Health <= 0) then
                            break
                        end
                        
                        -- ⚔️ ATTACK EVERY FRAME (THIS IS THE KEY!)
                        if env.AutoM1Attack ~= false then
                            FastAttack()
                        end
                        
                        -- Maintain float position
                        if not ActiveBodyVelocity or not ActiveBodyVelocity.Parent then
                            local bv = Instance.new("BodyVelocity")
                            bv.Velocity = Vector3.new(0, 0, 0)
                            bv.MaxForce = Vector3.new(1, 1, 1) * math.huge
                            bv.Parent = hrp
                            ActiveBodyVelocity = bv
                        end
                        
                        -- Keep noclip active
                        if not ActiveNoclip then
                            ActiveNoclip = RunService.RenderStepped:Connect(function()
                                if char and char.Parent then
                                    for _, v in ipairs(char:GetDescendants()) do
                                        if v:IsA("BasePart") and v.CanCollide then 
                                            v.CanCollide = false 
                                        end
                                    end
                                end
                            end)
                        end
                        
                        -- Position above target
                        pcall(function()
                            local freshTargetPos = targetHRP.CFrame * CFrame.new(0, farmHeight, 0)
                            hrp.CFrame = freshTargetPos
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                            hrp.RotVelocity = Vector3.new(0, 0, 0)
                        end)
                        
                        if char:FindFirstChild("Humanoid") then
                            char.Humanoid.PlatformStand = true
                        end
                        
                        -- 🧲 Auto Magnet
                        if env.AutoMagnetEnemy ~= false then
                            BringMobs(target)
                        end
                        
                        task.wait(0.03) -- FAST loop - attack every frame!
                    end
                    
                    -- Exited attack loop - target dead or moved, continue to outer loop
                end
            else
                -- No target found
                CurrentTarget = nil
                StopTween()
            end
            
            task.wait(0.03) -- Very fast loop for maximum damage
        end
        
        -- Cleanup
        CurrentTarget = nil
        StopTween()
        print("[AutoFarm Near] ⏹️  Auto farm stopped")
    end)
end

-- ========================================
-- CONTROL FUNCTIONS
-- ========================================

function AutoFarmNear.Stop()
    env.AutoFarmNear = false
    CurrentTarget = nil
    StopTween()
    print("[AutoFarm Near] ⏹️  Stopped manually")
end

function AutoFarmNear.ToggleM1Attack(enabled)
    env.AutoM1Attack = enabled
    print("[AutoFarm Near] ⚔️  M1 Attack: " .. tostring(enabled))
end

function AutoFarmNear.ToggleFastAttack(enabled)
    env.FastAttackEnabled = enabled
    print("[AutoFarm Near] ⚡ Fast Attack: " .. tostring(enabled))
end

function AutoFarmNear.ToggleMagnet(enabled)
    env.AutoMagnetEnemy = enabled
    print("[AutoFarm Near] 🧲 Auto Magnet: " .. tostring(enabled))
end

function AutoFarmNear.SetWeapon(weaponName)
    env.SelectedWeapon = weaponName
    print("[AutoFarm Near] ⚔️  Weapon: " .. weaponName)
end

function AutoFarmNear.SetMagnetRange(range)
    env.MagnetRange = range
    print("[AutoFarm Near] 🧲 Magnet Range: " .. range)
end

function AutoFarmNear.SetFarmHeight(height)
    env.PositionFarmY = height
    print("[AutoFarm Near] 📏 Farm Height: " .. height)
end

function AutoFarmNear.SetTweenSpeed(speed)
    env.TweenSpeed = speed
    print("[AutoFarm Near] 🚀 Tween Speed: " .. speed)
end

function AutoFarmNear.GetStats()
    return {
        Running = env.AutoFarmNear == true,
        FastAttack = env.FastAttackEnabled ~= false,
        AutoM1 = env.AutoM1Attack ~= false,
        AutoMagnet = env.AutoMagnetEnemy ~= false,
        Weapon = env.SelectedWeapon or "Combat",
        MagnetRange = env.MagnetRange or 350,
        FarmHeight = env.PositionFarmY or 30,
        TweenSpeed = env.TweenSpeed or 350,
        CombatFramework = CombatFramework ~= nil,
        CurrentTarget = CurrentTarget and CurrentTarget.Name or "None"
    }
end

function AutoFarmNear.GetCurrentTarget()
    return CurrentTarget
end

-- Character respawn handler
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    SetupCombatFramework()
end)

return AutoFarmNear

