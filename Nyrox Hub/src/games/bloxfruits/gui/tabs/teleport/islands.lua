local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- Connect Bypass TP Module
local BypassTP 
pcall(function()
    BypassTP = getgenv().Import("src/games/bloxfruits/gui/tabs/farm/bypass_tp.lua")
end)

local LocalPlayer = Players.LocalPlayer

local IslandData = {}

-- Current Sea Detection
local PlaceId = game.PlaceId
local Sea = 1

-- Check by Place ID
if PlaceId == 2753915549 then Sea = 1 end
if PlaceId == 4442272183 then Sea = 2 end
if PlaceId == 7449423635 then Sea = 3 end

-- Fallback: Check for robust Map Landmarks
if Sea == 1 then 
    local Map = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("Locations")
    
    -- Function to check existence deep or shallow
    local function Exists(name)
        if Workspace:FindFirstChild(name) then return true end
        if Map and Map:FindFirstChild(name) then return true end
        if Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations") then
             if Workspace._WorldOrigin.Locations:FindFirstChild(name) then return true end
        end
        return false
    end
    
    -- Sea 3 Checks
    if Exists("Turtle") or Exists("Floating Turtle") or Exists("Sea of Treats") or Exists("Castle on the Sea") or Exists("Port Town") or Exists("Hydra Island") then
        Sea = 3
    -- Sea 2 Checks
    elseif Exists("Factory") or Exists("Green Zone") or Exists("Kingdom of Rose") or Exists("Cursed Ship") then
        Sea = 2
    end
end

-- Debug print
warn("Nyrox Hub Detected Sea: " .. tostring(Sea) .. " | PlaceID: " .. tostring(PlaceId))

-- Static Positions (Fallbacks)
local Sea1Islands = {
    ["Starter Marine"] = Vector3.new(-2566, 6, 2045),
    ["Starter Pirate"] = Vector3.new(973, 16, 1413),
    ["Jungle"] = Vector3.new(-1441, 62, -15),
    ["Pirate Village"] = Vector3.new(-1137, 4, 3826),
    ["Desert"] = Vector3.new(964, 6, 4363),
    ["Middle Island"] = Vector3.new(-650, 7, 1500),
    ["Frozen Village"] = Vector3.new(1158, 26, -1193),
    ["Marine Fortress"] = Vector3.new(-4958, 20, 4272),
    ["Skylands"] = Vector3.new(-4842, 717, -2620),
    ["Prison"] = Vector3.new(4849, 5, 736),
    ["Colosseum"] = Vector3.new(-1568, 7, -2958),
    ["Magma Village"] = Vector3.new(-5315, 8, 8511),
    ["Underwater City"] = Vector3.new(3906, 12, -1941), -- Entrance (Whirlpool)
    ["Fountain City"] = Vector3.new(5124, 4, 4016),
}

local Sea2Islands = {
    ["Kingdom of Rose"] = Vector3.new(-463, 73, 1667),
    ["Cafe"] = Vector3.new(-380, 73, 290),
    ["Green Zone"] = Vector3.new(-2627, 73, -3173),
    ["Graveyard"] = Vector3.new(-5419, 8, -699),
    ["Snow Mountain"] = Vector3.new(568, 401, -5382),
    ["Hot and Cold"] = Vector3.new(-5909, 8, 4601),
    ["Cursed Ship"] = Vector3.new(927, 126, 32986),
    ["Ice Castle"] = Vector3.new(5428, 28, -6113),
    ["Forgotten Island"] = Vector3.new(-3042, 237, -10166),
    ["Dark Arena"] = Vector3.new(3776, 14, -3511),
}

local Sea3Islands = {
    ["Port Town"] = Vector3.new(-232, 21, 5522),
    ["Hydra Arena"] = Vector3.new(4819, 52, -1847),
    ["Hydra Town"] = Vector3.new(5301, 1004, 203),
    ["Great Tree"] = Vector3.new(3025, 2281, -7347),
    ["Floating Turtle"] = Vector3.new(-12551, 337, -7540),
    ["Castle on the Sea"] = Vector3.new(-5088, 314, -2994),
    ["Haunted Castle"] = Vector3.new(-9545, 140, 5683),
    ["Sea of Treats"] = Vector3.new(-1912, 14, -11588),
    ["Peanut Island"] = Vector3.new(-2044, 5, -9903),
    ["North Pole"] = Vector3.new(-1095, 64, -14524),
    ["Chocolate Island"] = Vector3.new(-29, 17, -12000),
    ["Ice Cream Island"] = Vector3.new(-893, 59, -10869),
    ["Tiki Outpost"] = Vector3.new(-16521, 528, 424),
    ["Submerged Island"] = Vector3.new(-16268, 25, 1372),
    }


local DisplayIslands = {}
local CurrentList = {}

-- Populate List based on Sea
if Sea == 1 then
    CurrentList = Sea1Islands
elseif Sea == 2 then
    CurrentList = Sea2Islands
elseif Sea == 3 then
    CurrentList = Sea3Islands
else
    -- Fallback / Unknown
    CurrentList = Sea1Islands
end

-- Sort Names for Dropdown
local Names = {}
for name, _ in pairs(CurrentList) do
    table.insert(Names, name)
end
table.sort(Names)

-- Function to get Target Position
local function GetPosition(name)
    -- 1 Check Static List
    if CurrentList[name] then
        return CurrentList[name]
    end
    
    -- 2 Dynamic Check (Map Folder)
    local Map = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("Locations")
    if Map then
        local obj = Map:FindFirstChild(name)
        if obj then
            if obj:IsA("Model") then return obj:GetPivot().Position end
            if obj:IsA("BasePart") then return obj.Position end
        end
    end
    
    return nil
end

local ActiveTween = nil
local ActiveBodyVelocity = nil
local ActiveNoclip = nil

local function StopTween()
    if ActiveTween then ActiveTween:Cancel() ActiveTween = nil end
    if ActiveBodyVelocity then ActiveBodyVelocity:Destroy() ActiveBodyVelocity = nil end
    if ActiveNoclip then ActiveNoclip:Disconnect() ActiveNoclip = nil end
    
    local char = LocalPlayer.Character
    if char then
        -- STOP EVERYTHING
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            hrp.RotVelocity = Vector3.new(0,0,0)
        end
        
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.PlatformStand = false
            char.Humanoid.Sit = false
            char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

local function TweenTo(targetPos, targetName)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end
    
    -- Cleanup previous tween
    StopTween()
    
    local hrp = char.HumanoidRootPart
    local humanoid = char.Humanoid
    
    -- 1. Unsit & Stabilize
    humanoid.Sit = false
    humanoid.PlatformStand = true
    
    -- 2. Anti-Gravity (Stabilizer)
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(1, 1, 1) * math.huge
    bv.Name = "TweenStabilizer"
    bv.Parent = hrp
    ActiveBodyVelocity = bv
    
    -- 3. Calculate Speed & Tween (FASTER BYPASS)
    local speed = getgenv().TweenSpeed or 400
    
    -- Speed Limit Logic: Improved for speed
    if speed < 300 then speed = 300 end
    if speed > 850 then speed = 850 end -- Allow up to 850
    
    local dist = (hrp.Position - targetPos).Magnitude
    local time = dist / speed
    
    local info = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, info, {CFrame = CFrame.new(targetPos)})
    ActiveTween = tween
    
    -- SAFETY: Stop if player dies mid-flight (Fixes "Dead body flying")
    local deathConn
    deathConn = humanoid.Died:Connect(function()
        StopTween()
        if deathConn then deathConn:Disconnect() end
    end)
    
    -- 4. Robust Noclip & Bypass Loop
    local RunService = game:GetService("RunService")
    ActiveNoclip = RunService.RenderStepped:Connect(function() -- Switch to RenderStepped for faster updates
        if not char or not char.Parent or not humanoid or humanoid.Health <= 0 then 
            if deathConn then deathConn:Disconnect() end
            StopTween() 
            return 
        end
        
        -- Force Noclip
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
        
        -- Bypass: Aggressive Velocity Freeze
        if hrp then 
            hrp.Velocity = Vector3.new(0,0,0) 
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) 
            hrp.RotVelocity = Vector3.new(0,0,0)

            if targetName ~= "Submerged Island" and (hrp.Position - targetPos).Magnitude < 5000 then 
                 local params = RaycastParams.new()
                 params.FilterDescendantsInstances = {char}
                 params.FilterType = Enum.RaycastFilterType.Exclude
                 
                 local ray = Workspace:Raycast(hrp.Position, Vector3.new(0, -2000, 0), params)
                 if ray and ray.Instance and ray.Instance.Material ~= Enum.Material.Water then
                     StopTween()
                     
                     -- Only Reset if NOT Submerged Island
                     if targetName ~= "Submerged Island" then
                        if BypassTP and BypassTP.OnArrival then BypassTP.OnArrival(targetPos) end
                     end
                     
                     -- Auto Talk for Submerged Island
                     if targetName == "Submerged Island" then
                         task.spawn(function()
                             task.wait(1) -- Wait for reset/position hold

                             for _, v in pairs(Workspace.NPCs:GetChildren()) do
                                 if v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - targetPos).Magnitude < 20 then
                                     pcall(function()
                                         game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Talk", v.Name) 
                                     end)
                                     break
                                 end
                             end
                         end)
                     end
                     return 
                 end
            end

            -- 2. Fallback Distance (Close range arrival)
            if (hrp.Position - targetPos).Magnitude < 350 then
                 StopTween()
                 
                 -- Standard Reset Logic
                 if targetName ~= "Submerged Island" then
                    if BypassTP and BypassTP.OnArrival then BypassTP.OnArrival(targetPos) end
                 end
                 
                 -- Auto Talk for Submerged Island
                 if targetName == "Submerged Island" then
                     -- 1. Snap to exact position (Force multiple times)
                     task.spawn(function()
                         for i = 1, 5 do
                             if char.PrimaryPart then
                                 char:SetPrimaryPartCFrame(CFrame.new(targetPos))
                             end
                             task.wait()
                         end
                     end)
                     
                     -- 2. "Super Interaction" - Force Open Shop/Dialogue
                     task.spawn(function()
                         local Players = game:GetService("Players")
                         local VirtualInputManager = game:GetService("VirtualInputManager")
                         local ReplicatedStorage = game:GetService("ReplicatedStorage")
                         
                         local findStart = tick()
                         local npcModel = nil
                         
                         -- A. Find NPC Loop (Timeout 5s)
                         while tick() - findStart < 5 do
                             for _, v in pairs(Workspace.NPCs:GetChildren()) do
                                 if (v.Name == "Submarine Worker" or v.Name == "Shark Hunter") and v:FindFirstChild("HumanoidRootPart") then
                                     if (v.HumanoidRootPart.Position - targetPos).Magnitude < 300 then
                                         npcModel = v
                                         break
                                     end
                                 end
                             end
                             if npcModel then break end
                             task.wait(0.1)
                         end
                         
                         if npcModel then
                             -- Move player EXACTLY to NPC front to ensure server checks pass
                             if char.PrimaryPart then
                                 char:SetPrimaryPartCFrame(npcModel.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4))
                             end
                             
                             -- B. Spam Remotes (Open Shop Bypass)
                             task.spawn(function()
                                 -- Try 1: Specific Key
                                 ReplicatedStorage.Remotes.CommF_:InvokeServer("SharkHunter")
                                 -- Try 2: Talk Key
                                 ReplicatedStorage.Remotes.CommF_:InvokeServer("Talk", npcModel.Name)
                             end)
                             
                             -- C. Auto-Click "Yes" Loop (Skip Dialogue)
                             local clickStart = tick()
                             while tick() - clickStart < 3 do
                                 local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
                                 if pg then
                                     local dialogue = pg:FindFirstChild("Dialogue") or pg:FindFirstChild("Npc_Dialogue")
                                     if dialogue and dialogue.Visible then
                                         for _, btn in pairs(dialogue:GetDescendants()) do
                                             if btn:IsA("TextButton") and (btn.Text == "Yes" or btn.Name == "Option1") then
                                                 -- Method A: Executor
                                                 if type(getconnections) == "function" then
                                                     for _, c in pairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
                                                 end
                                                 -- Method B: Virtual Input
                                                 if btn.AbsolutePosition.X > 0 then
                                                      VirtualInputManager:SendMouseButtonEvent(btn.AbsolutePosition.X + 10, btn.AbsolutePosition.Y + 10, 0, true, game, 1)
                                                      VirtualInputManager:SendMouseButtonEvent(btn.AbsolutePosition.X + 10, btn.AbsolutePosition.Y + 10, 0, false, game, 1)
                                                 end
                                             end
                                         end
                                     end
                                 end
                                 task.wait(0.2)
                             end
                         else
                             warn("Nyrox Hub: Submarine Worker not found even after scan.")
                         end
                     end)
                 end
            end
        end
        
        -- Bypass: State Spam
         if humanoid then
             humanoid:ChangeState(11) 
        end
    end)
    
    -- 5. Execute with Arrival Check
    tween:Play()
    tween.Completed:Connect(function(status)
        if deathConn then deathConn:Disconnect() end
        StopTween()
        if status == Enum.PlaybackState.Completed then
             if BypassTP and BypassTP.OnArrival then
                 BypassTP.OnArrival()
             end
        end
    end)
end

return {
    IslandNames = Names,
    Teleport = function(islandName)
        local pos = GetPosition(islandName)
        if pos then
            TweenTo(pos, islandName)
        else
            warn("Position not found for island: " .. tostring(islandName))
        end
    end
}
