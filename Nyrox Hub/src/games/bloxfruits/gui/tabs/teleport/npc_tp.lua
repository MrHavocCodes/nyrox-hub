local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Connect Bypass TP Module
local BypassTP 
pcall(function()
    BypassTP = getgenv().Import("src/games/bloxfruits/gui/tabs/farm/bypass_tp.lua")
end)

-- Connect Complete Close Handler
local CloseHandler
pcall(function()
    CloseHandler = getgenv().Import("src/games/bloxfruits/utils/complete_close.lua")
end)

local LocalPlayer = Players.LocalPlayer

local NPCData = {}

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
warn("Nyrox Hub NPC TP Detected Sea: " .. tostring(Sea) .. " | PlaceID: " .. tostring(PlaceId))

-- NPC Data by Sea (Name -> Position)
local Sea1NPCs = {
    -- Starter Area
    ["Blox Fruit Dealer"] = Vector3.new(-4607, 872, 4442),
    ["Blox Fruit Gacha"] = Vector3.new(-4607, 872, 4442),
    ["Experienced Captain"] = Vector3.new(-5185, 7, 3788),
    ["Jungle Boss"] = Vector3.new(-1441, 62, -15),
    ["Fishman Lord"] = Vector3.new(61123, 18, 1569),
    ["Thunder God"] = Vector3.new(-7748, 5545, -2305),
    ["Shanks"] = Vector3.new(-1926, 5, 1912),
    ["Rayleigh"] = Vector3.new(4892, 4, 734),
    ["Plokster"] = Vector3.new(-5537, 11, 8401),
    ["Colosseum Quest Giver"] = Vector3.new(-1576, 8, -3047),
    ["Marine Commodore"] = Vector3.new(-2823, 20, 2111),
    ["Tavern"] = Vector3.new(959, 17, 1547),
    ["Pirate Recruiter"] = Vector3.new(1049, 16, 1429),
    ["Marine Recruiter"] = Vector3.new(-2770, 24, 2047),
    ["Weapon Shop"] = Vector3.new(253, 41, 1299),
    ["Jungle Weapons"] = Vector3.new(-1539, 62, 150),
    ["Desert Weapons"] = Vector3.new(966, 6, 4398),
    ["Frozen Weapons"] = Vector3.new(1304, 24, -1303),
    ["Swordsman Hat"] = Vector3.new(-1538, 62, 158),
    ["Black Leg Teacher"] = Vector3.new(-5424, 14, 8437),
    ["Electro Teacher"] = Vector3.new(-5389, 14, 8396),
    ["Fishman Karate Teacher"] = Vector3.new(61123, 18, 1569),
    ["Dark Step Teacher"] = Vector3.new(-4607, 872, 4442),
}

local Sea2NPCs = {
    -- Second Sea NPCs
    ["Blox Fruit Dealer"] = Vector3.new(-12, 38, 231),
    ["Blox Fruit Gacha"] = Vector3.new(-12, 38, 231),
    ["Advanced Fruit Dealer"] = Vector3.new(-12, 38, 231),
    ["Bartilo"] = Vector3.new(-276, 74, 1165),
    ["Don Swan"] = Vector3.new(2285, 15, 906),
    ["Citizen"] = Vector3.new(-282, 73, 302),
    ["Hungry Man"] = Vector3.new(-282, 73, 302),
    ["Factory Staff"] = Vector3.new(289, 12, -120),
    ["Dough King"] = Vector3.new(-2009, 38, -12450),
    ["Cursed Captain"] = Vector3.new(930, 125, 33108),
    ["Awakenings Expert"] = Vector3.new(-5420, 314, -2823),
    ["Alchemist"] = Vector3.new(-2777, 73, -3302),
    ["Nerd"] = Vector3.new(-380, 73, 262),
    ["Ice Admiral"] = Vector3.new(5414, 24, -5127),
    ["Previous Hero"] = Vector3.new(-10752, 374, -7257),
    ["Lunoven"] = Vector3.new(-5232, 10, -2825),
    ["Wenlocktoad"] = Vector3.new(-5420, 314, -2823),
    ["Death King"] = Vector3.new(-5420, 314, -2823),
    ["Experianced Captain"] = Vector3.new(-5185, 7, 3788),
    ["Tavern"] = Vector3.new(-282, 73, 302),
    ["Weapon Shop"] = Vector3.new(-282, 73, 302),
    ["Armor Shop"] = Vector3.new(-282, 73, 302),
    ["Accessories Shop"] = Vector3.new(-282, 73, 302),
}

local Sea3NPCs = {
    -- Third Sea NPCs
    ["Blox Fruit Dealer"] = Vector3.new(-292, 53, 172),
    ["Blox Fruit Gacha"] = Vector3.new(-292, 53, 172),
    ["Advanced Fruit Dealer"] = Vector3.new(-292, 53, 172),
    ["Mysterious Scientist"] = Vector3.new(-6437, 251, -2965),
    ["Citizen"] = Vector3.new(-282, 22, 5305),
    ["Cyborg"] = Vector3.new(-289, 54, 327),
    ["Experianced Captain"] = Vector3.new(-5185, 7, 3788),
    ["Elite Hunter"] = Vector3.new(5172, 88, 4283),
    ["Legendary Sword Dealer"] = Vector3.new(-8181, 603, 10593),
    ["Luxury Boat Dealer"] = Vector3.new(-1911, 85, 1500),
    ["Tiki Outpost Dealer"] = Vector3.new(-16234, 9, 450),
    ["Longma"] = Vector3.new(-10168, 332, -8631),
    ["Rip_Indra"] = Vector3.new(-5420, 314, -2823),
    ["Beautiful Pirate"] = Vector3.new(5240, 23, 788),
    ["Raw Fruit Seller"] = Vector3.new(-12491, 337, -7660),
    ["Awakenings Expert"] = Vector3.new(-12, 6, -7659),
    ["Death King"] = Vector3.new(-5420, 314, -2823),
    ["Alchemist"] = Vector3.new(-2777, 73, -3302),
    ["Dough King"] = Vector3.new(-2009, 38, -12450),
    ["Shark Hunter"] = Vector3.new(-12550, 23, 1377),
    ["Submarine Worker"] = Vector3.new(-12550, 23, 1377),
    ["Arowe"] = Vector3.new(-1860, 14, -11131),
    ["Cocoa Warrior"] = Vector3.new(-12091, 73, -10324),
    ["Tiki Outpost Guardian"] = Vector3.new(-16234, 9, 450),
    ["Cacao Island Dealer"] = Vector3.new(-12091, 73, -10324),
    ["Sweet Crafter"] = Vector3.new(-12091, 73, -10324),
    ["Equipment Shop"] = Vector3.new(-292, 53, 172),
    ["Tavern"] = Vector3.new(-292, 53, 172),
    ["Accessories Shop"] = Vector3.new(-292, 53, 172),
    ["Boat Dealer"] = Vector3.new(-292, 53, 172),
}

local DisplayNPCs = {}
local CurrentList = {}

-- Populate List based on Sea
if Sea == 1 then
    CurrentList = Sea1NPCs
elseif Sea == 2 then
    CurrentList = Sea2NPCs
elseif Sea == 3 then
    CurrentList = Sea3NPCs
else
    CurrentList = Sea1NPCs
end

-- Sort Names for Dropdown
local Names = {}
for name, _ in pairs(CurrentList) do
    table.insert(Names, name)
end
table.sort(Names)

-- Function to get NPC Position (Dynamic + Fallback)
local function GetNPCPosition(npcName)
    -- 1. Try to find NPC dynamically in workspace
    local NPCFolder = Workspace:FindFirstChild("NPCs")
    if NPCFolder then
        local npc = NPCFolder:FindFirstChild(npcName)
        if npc and npc:FindFirstChild("HumanoidRootPart") then
            return npc.HumanoidRootPart.Position
        end
    end
    
    -- 2. Check if NPC is in Map folder
    local Map = Workspace:FindFirstChild("Map")
    if Map then
        for _, child in pairs(Map:GetDescendants()) do
            if child.Name == npcName and child:IsA("Model") and child:FindFirstChild("HumanoidRootPart") then
                return child.HumanoidRootPart.Position
            end
        end
    end
    
    -- 3. Fallback to static position
    if CurrentList[npcName] then
        return CurrentList[npcName]
    end
    
    return nil
end

local ActiveTween = nil
local ActiveBodyVelocity = nil
local ActiveNoclip = nil
local ActiveDeathConnection = nil

local function StopTween()
    if ActiveTween then ActiveTween:Cancel() ActiveTween = nil end
    if ActiveBodyVelocity then ActiveBodyVelocity:Destroy() ActiveBodyVelocity = nil end
    if ActiveNoclip then ActiveNoclip:Disconnect() ActiveNoclip = nil end
    if ActiveDeathConnection then ActiveDeathConnection:Disconnect() ActiveDeathConnection = nil end
    
    local char = LocalPlayer.Character
    if char then
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

-- Cleanup function for complete close
local function StopAll()
    StopTween()
    warn("NPC Teleport: Cleanup complete")
end

local function TweenTo(targetPos, npcName)
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
    
    -- 3. Calculate Speed & Tween
    local speed = getgenv().TweenSpeed or 400
    
    if speed < 300 then speed = 300 end
    if speed > 850 then speed = 850 end
    
    local dist = (hrp.Position - targetPos).Magnitude
    local time = dist / speed
    
    local info = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, info, {CFrame = CFrame.new(targetPos)})
    ActiveTween = tween
    
    -- SAFETY: Stop if player dies mid-flight
    ActiveDeathConnection = humanoid.Died:Connect(function()
        StopTween()
    end)
    
    -- 4. Robust Noclip & Bypass Loop
    local RunService = game:GetService("RunService")
    ActiveNoclip = RunService.RenderStepped:Connect(function()
        if not char or not char.Parent or not humanoid or humanoid.Health <= 0 then 
            StopTween() 
            return 
        end
        
        -- Check if script was stopped
        if not getgenv().NyroxRunning then
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

            -- Arrival Detection
            if (hrp.Position - targetPos).Magnitude < 300 then
                StopTween()
                
                -- Trigger bypass reset if available
                if BypassTP and BypassTP.OnArrival then 
                    BypassTP.OnArrival(targetPos) 
                end
                
                -- Wait for character to be ready after reset, then position next to NPC
                task.spawn(function()
                    -- Wait for potential reset/respawn
                    task.wait(0.8)
                    
                    -- Get fresh character reference
                    local newChar = LocalPlayer.Character
                    if not newChar or not newChar:FindFirstChild("HumanoidRootPart") then
                        -- Wait for character to load
                        local waited = 0
                        while (not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and waited < 5 do
                            task.wait(0.1)
                            waited = waited + 0.1
                        end
                        newChar = LocalPlayer.Character
                    end
                    
                    if not newChar or not newChar:FindFirstChild("HumanoidRootPart") then
                        warn("NPC TP: Character not loaded after reset")
                        return
                    end
                    
                    -- Find the NPC
                    local NPCFolder = Workspace:FindFirstChild("NPCs")
                    if NPCFolder then
                        local npc = NPCFolder:FindFirstChild(npcName)
                        if npc and npc:FindFirstChild("HumanoidRootPart") then
                            local npcPos = npc.HumanoidRootPart.Position
                            local npcCFrame = npc.HumanoidRootPart.CFrame
                            
                            -- Position player right next to NPC (in front, 3 studs away)
                            local targetCFrame = npcCFrame * CFrame.new(0, 0, 3)
                            
                            -- Teleport multiple times to ensure it sticks
                            for i = 1, 5 do
                                if newChar and newChar:FindFirstChild("HumanoidRootPart") then
                                    newChar:SetPrimaryPartCFrame(targetCFrame)
                                end
                                task.wait(0.05)
                            end
                            
                            task.wait(0.3)
                            
                            -- Try to interact with NPC
                            pcall(function()
                                ReplicatedStorage.Remotes.CommF_:InvokeServer("Talk", npcName)
                            end)
                        else
                            warn("NPC TP: NPC '" .. tostring(npcName) .. "' not found in workspace")
                        end
                    end
                end)
                
                return
            end
        end
        
        -- Bypass: State Spam
        if humanoid then
            humanoid:ChangeState(11) 
        end
    end)
    
    -- 5. Execute with Arrival Check
    tween:Play()
    
    -- Register with CloseHandler
    if CloseHandler and CloseHandler.Register then
        if ActiveNoclip then CloseHandler.Register(ActiveNoclip) end
        if ActiveDeathConnection then CloseHandler.Register(ActiveDeathConnection) end
    end
    
    tween.Completed:Connect(function(status)
        StopTween()
        if status == Enum.PlaybackState.Completed then
            if BypassTP and BypassTP.OnArrival then
                BypassTP.OnArrival()
            end
            
            -- Position player next to NPC after completion
            task.spawn(function()
                task.wait(0.8)
                
                local newChar = LocalPlayer.Character
                if not newChar or not newChar:FindFirstChild("HumanoidRootPart") then
                    local waited = 0
                    while (not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and waited < 5 do
                        task.wait(0.1)
                        waited = waited + 0.1
                    end
                    newChar = LocalPlayer.Character
                end
                
                if not newChar or not newChar:FindFirstChild("HumanoidRootPart") then
                    return
                end
                
                local NPCFolder = Workspace:FindFirstChild("NPCs")
                if NPCFolder then
                    local npc = NPCFolder:FindFirstChild(npcName)
                    if npc and npc:FindFirstChild("HumanoidRootPart") then
                        local targetCFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                        
                        for i = 1, 5 do
                            if newChar and newChar:FindFirstChild("HumanoidRootPart") then
                                newChar:SetPrimaryPartCFrame(targetCFrame)
                            end
                            task.wait(0.05)
                        end
                        
                        task.wait(0.3)
                        
                        pcall(function()
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("Talk", npcName)
                        end)
                    end
                end
            end)
        end
    end)
end

return {
    NPCNames = Names,
    Teleport = function(npcName)
        local pos = GetNPCPosition(npcName)
        if pos then
            TweenTo(pos, npcName)
        else
            warn("Position not found for NPC: " .. tostring(npcName))
        end
    end,
    StopAll = StopAll
}
