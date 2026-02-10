-- Auto Farm Module for Blox Fruits
local CoreFunctions = nil

-- Try to load CoreFunctions safely
pcall(function()
    if script and script.Parent then
        CoreFunctions = require(script.Parent.Parent.Parent.Parent.utils.core_functions)
    end
end)

local AutoFarm = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Environment
local function GetEnv()
    if type(getgenv) == "function" then return getgenv() end
    return shared
end
local env = GetEnv()

-- Player References
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Update character reference when respawning
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- Workspace References
local Workspace = workspace
local Enemies = Workspace:WaitForChild("Enemies")
local NPCs = Workspace:WaitForChild("NPCs")

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Remotes:WaitForChild("CommF_")

-- Fast Attack Remotes
local FastAttackRemotes = {
    RegisterAttack = nil,
    RegisterHit = nil
}

pcall(function()
    local Modules = ReplicatedStorage:WaitForChild("Modules")
    local Net = Modules:WaitForChild("Net")
    FastAttackRemotes.RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
    FastAttackRemotes.RegisterHit = Net:WaitForChild("RE/RegisterHit")
end)

-- Settings (using environment)
if env.AutoFarm == nil then env.AutoFarm = false end
if env.FarmMode == nil then env.FarmMode = "Quest" end
if env.AutoQuest == nil then env.AutoQuest = true end
if env.BringMobs == nil then env.BringMobs = true end
if env.FastAttack == nil then env.FastAttack = true end
if env.AttackDistance == nil then env.AttackDistance = 15 end
if env.SpinPosition == nil then env.SpinPosition = true end
if env.SelectWeapon == nil then env.SelectWeapon = "Melee" end
if env.SelectedWeapon == nil then env.SelectedWeapon = nil end
if env.AutoHaki == nil then env.AutoHaki = true end
if env.NoClip == nil then env.NoClip = true end
if env.TweenSpeed == nil then env.TweenSpeed = 300 end

-- World Detection
local World1, World2, World3 = false, false, false
if game.PlaceId == 2753915549 then
    World1 = true
elseif game.PlaceId == 4442272183 then
    World2 = true
elseif game.PlaceId == 7449423635 then
    World3 = true
end

-- Quest Data
local QuestData = {
    Mon = "",
    LevelQuest = 1,
    NameQuest = "",
    NameMon = "",
    CFrameQuest = CFrame.new(0, 0, 0),
    CFrameMon = CFrame.new(0, 0, 0)
}

-- Spinning angle for anti-ban
local CurrentAngle = 0

-- Character Update
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- Utility Functions
function AutoFarm:IsAlive(char)
    char = char or Character
    if not char or not char.Parent then return false end
    
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    return hum and root and hum.Health > 0
end

function AutoFarm:GetDistance(pos)
    if not self:IsAlive() then return math.huge end
    return (HumanoidRootPart.Position - pos).Magnitude
end

function AutoFarm:AutoHaki()
    if not Character:FindFirstChild("HasBuso") then
        pcall(function()
            CommF:InvokeServer("Buso")
        end)
    end
end

function AutoFarm:Click()
    VirtualInputManager:SendKeyEvent(true, "E", false, game)
    task.wait()
    VirtualInputManager:SendKeyEvent(false, "E", false, game)
end

function AutoFarm:Tween(cframe, speed)
    if not self:IsAlive() then return end
    
    speed = speed or env.TweenSpeed
    local distance = self:GetDistance(cframe.Position)
    local duration = distance / speed
    
    local tween = TweenService:Create(
        HumanoidRootPart,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {CFrame = cframe}
    )
    
    tween:Play()
    return tween
end

function AutoFarm:Teleport(cframe)
    if not self:IsAlive() then return end
    HumanoidRootPart.CFrame = cframe
end

function AutoFarm:BTP(cframe)
    if not self:IsAlive() then return end
    
    local distance = self:GetDistance(cframe.Position)
    
    if distance >= 2000 then
        repeat
            task.wait()
            HumanoidRootPart.CFrame = cframe
            CommF:InvokeServer("SetSpawnPoint")
            Character.Head:Destroy()
            task.wait()
        until self:GetDistance(cframe.Position) <= 2000
    end
end

-- Quest System
function AutoFarm:CheckQuest()
    local myLevel = LocalPlayer.Data.Level.Value
    
    if World1 then
        if myLevel >= 1 and myLevel <= 9 then
            QuestData.Mon = "Bandit"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "BanditQuest1"
            QuestData.NameMon = "Bandit"
            QuestData.CFrameQuest = CFrame.new(1059.37, 15.45, 1550.42)
            QuestData.CFrameMon = CFrame.new(1045.96, 27.00, 1560.82)
        elseif myLevel >= 10 and myLevel <= 14 then
            QuestData.Mon = "Monkey"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "JungleQuest"
            QuestData.NameMon = "Monkey"
            QuestData.CFrameQuest = CFrame.new(-1598.09, 35.55, 153.38)
            QuestData.CFrameMon = CFrame.new(-1448.52, 67.85, 11.47)
        elseif myLevel >= 15 and myLevel <= 29 then
            QuestData.Mon = "Gorilla"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "JungleQuest"
            QuestData.NameMon = "Gorilla"
            QuestData.CFrameQuest = CFrame.new(-1598.09, 35.55, 153.38)
            QuestData.CFrameMon = CFrame.new(-1129.88, 40.46, -525.42)
        elseif myLevel >= 30 and myLevel <= 39 then
            QuestData.Mon = "Pirate"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "BuggyQuest1"
            QuestData.NameMon = "Pirate"
            QuestData.CFrameQuest = CFrame.new(-1141.07, 4.10, 3831.55)
            QuestData.CFrameMon = CFrame.new(-1103.51, 13.75, 3896.09)
        elseif myLevel >= 40 and myLevel <= 59 then
            QuestData.Mon = "Brute"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "BuggyQuest1"
            QuestData.NameMon = "Brute"
            QuestData.CFrameQuest = CFrame.new(-1141.07, 4.10, 3831.55)
            QuestData.CFrameMon = CFrame.new(-1140.08, 14.81, 4322.92)
        elseif myLevel >= 60 and myLevel <= 74 then
            QuestData.Mon = "Desert Bandit"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "DesertQuest"
            QuestData.NameMon = "Desert Bandit"
            QuestData.CFrameQuest = CFrame.new(894.49, 5.14, 4392.43)
            QuestData.CFrameMon = CFrame.new(924.80, 6.45, 4481.59)
        elseif myLevel >= 75 and myLevel <= 89 then
            QuestData.Mon = "Desert Officer"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "DesertQuest"
            QuestData.NameMon = "Desert Officer"
            QuestData.CFrameQuest = CFrame.new(894.49, 5.14, 4392.43)
            QuestData.CFrameMon = CFrame.new(1608.28, 8.61, 4371.01)
        elseif myLevel >= 90 and myLevel <= 99 then
            QuestData.Mon = "Snow Bandit"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "SnowQuest"
            QuestData.NameMon = "Snow Bandit"
            QuestData.CFrameQuest = CFrame.new(1389.74, 88.15, -1298.91)
            QuestData.CFrameMon = CFrame.new(1354.35, 87.27, -1393.95)
        elseif myLevel >= 100 and myLevel <= 119 then
            QuestData.Mon = "Snowman"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "SnowQuest"
            QuestData.NameMon = "Snowman"
            QuestData.CFrameQuest = CFrame.new(1389.74, 88.15, -1298.91)
            QuestData.CFrameMon = CFrame.new(1201.64, 144.58, -1550.07)
        elseif myLevel >= 120 and myLevel <= 149 then
            QuestData.Mon = "Chief Petty Officer"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "MarineQuest2"
            QuestData.NameMon = "Chief Petty Officer"
            QuestData.CFrameQuest = CFrame.new(-5039.59, 27.35, 4324.68)
            QuestData.CFrameMon = CFrame.new(-4881.23, 22.65, 4273.75)
        elseif myLevel >= 150 and myLevel <= 174 then
            QuestData.Mon = "Sky Bandit"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "SkyQuest"
            QuestData.NameMon = "Sky Bandit"
            QuestData.CFrameQuest = CFrame.new(-4839.53, 716.37, -2619.44)
            QuestData.CFrameMon = CFrame.new(-4953.21, 295.74, -2899.23)
        elseif myLevel >= 175 and myLevel <= 189 then
            QuestData.Mon = "Dark Master"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "SkyQuest"
            QuestData.NameMon = "Dark Master"
            QuestData.CFrameQuest = CFrame.new(-4839.53, 716.37, -2619.44)
            QuestData.CFrameMon = CFrame.new(-5259.84, 391.40, -2229.04)
        elseif myLevel >= 190 and myLevel <= 209 then
            QuestData.Mon = "Prisoner"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "PrisonerQuest"
            QuestData.NameMon = "Prisoner"
            QuestData.CFrameQuest = CFrame.new(5308.93, 1.66, 475.12)
            QuestData.CFrameMon = CFrame.new(5098.97, -0.32, 474.24)
        elseif myLevel >= 210 and myLevel <= 249 then
            QuestData.Mon = "Dangerous Prisoner"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "PrisonerQuest"
            QuestData.NameMon = "Dangerous Prisoner"
            QuestData.CFrameQuest = CFrame.new(5308.93, 1.66, 475.12)
            QuestData.CFrameMon = CFrame.new(5654.56, 15.63, 866.30)
        elseif myLevel >= 250 and myLevel <= 274 then
            QuestData.Mon = "Toga Warrior"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "ColosseumQuest"
            QuestData.NameMon = "Toga Warrior"
            QuestData.CFrameQuest = CFrame.new(-1580.05, 6.35, -2986.48)
            QuestData.CFrameMon = CFrame.new(-1820.21, 51.68, -2740.67)
        elseif myLevel >= 275 and myLevel <= 299 then
            QuestData.Mon = "Gladiator"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "ColosseumQuest"
            QuestData.NameMon = "Gladiator"
            QuestData.CFrameQuest = CFrame.new(-1580.05, 6.35, -2986.48)
            QuestData.CFrameMon = CFrame.new(-1292.84, 56.38, -3339.03)
        elseif myLevel >= 300 and myLevel <= 324 then
            QuestData.Mon = "Military Soldier"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "MagmaQuest"
            QuestData.NameMon = "Military Soldier"
            QuestData.CFrameQuest = CFrame.new(-5313.37, 10.95, 8515.29)
            QuestData.CFrameMon = CFrame.new(-5411.16, 11.08, 8454.29)
        elseif myLevel >= 325 and myLevel <= 374 then
            QuestData.Mon = "Military Spy"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "MagmaQuest"
            QuestData.NameMon = "Military Spy"
            QuestData.CFrameQuest = CFrame.new(-5313.37, 10.95, 8515.29)
            QuestData.CFrameMon = CFrame.new(-5802.87, 86.26, 8828.86)
        elseif myLevel >= 375 and myLevel <= 399 then
            QuestData.Mon = "Fishman Warrior"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "FishmanQuest"
            QuestData.NameMon = "Fishman Warrior"
            QuestData.CFrameQuest = CFrame.new(61122.65, 18.50, 1569.40)
            QuestData.CFrameMon = CFrame.new(60878.30, 18.48, 1543.76)
        elseif myLevel >= 400 and myLevel <= 449 then
            QuestData.Mon = "Fishman Commando"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "FishmanQuest"
            QuestData.NameMon = "Fishman Commando"
            QuestData.CFrameQuest = CFrame.new(61122.65, 18.50, 1569.40)
            QuestData.CFrameMon = CFrame.new(61922.68, 18.48, 1493.93)
        elseif myLevel >= 450 and myLevel <= 474 then
            QuestData.Mon = "God's Guard"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "SkyExp1Quest"
            QuestData.NameMon = "God's Guard"
            QuestData.CFrameQuest = CFrame.new(-4721.88, 843.87, -1949.96)
            QuestData.CFrameMon = CFrame.new(-4710.04, 845.09, -1927.92)
        elseif myLevel >= 475 and myLevel <= 524 then
            QuestData.Mon = "Shanda"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "SkyExp1Quest"
            QuestData.NameMon = "Shanda"
            QuestData.CFrameQuest = CFrame.new(-7859.09, 5544.19, -381.48)
            QuestData.CFrameMon = CFrame.new(-7678.48, 5566.40, -497.00)
        elseif myLevel >= 525 and myLevel <= 549 then
            QuestData.Mon = "Royal Squad"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "SkyExp2Quest"
            QuestData.NameMon = "Royal Squad"
            QuestData.CFrameQuest = CFrame.new(-7906.81, 5634.61, -1411.99)
            QuestData.CFrameMon = CFrame.new(-7624.46, 5658.50, -1467.77)
        elseif myLevel >= 550 and myLevel <= 624 then
            QuestData.Mon = "Royal Soldier"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "SkyExp2Quest"
            QuestData.NameMon = "Royal Soldier"
            QuestData.CFrameQuest = CFrame.new(-7906.81, 5634.61, -1411.99)
            QuestData.CFrameMon = CFrame.new(-7836.75, 5645.61, -1790.23)
        elseif myLevel >= 625 and myLevel <= 649 then
            QuestData.Mon = "Galley Pirate"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "FountainQuest"
            QuestData.NameMon = "Galley Pirate"
            QuestData.CFrameQuest = CFrame.new(5259.81, 37.72, 4050.45)
            QuestData.CFrameMon = CFrame.new(5551.02, 78.90, 3930.41)
        elseif myLevel >= 650 then
            QuestData.Mon = "Galley Captain"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "FountainQuest"
            QuestData.NameMon = "Galley Captain"
            QuestData.CFrameQuest = CFrame.new(5259.81, 37.72, 4050.45)
            QuestData.CFrameMon = CFrame.new(5441.95, 42.50, 4950.09)
        end
    elseif World2 then
        if myLevel >= 700 and myLevel <= 724 then
            QuestData.Mon = "Raider"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "Area1Quest"
            QuestData.NameMon = "Raider"
            QuestData.CFrameQuest = CFrame.new(-429.54, 71.77, 1836.18)
            QuestData.CFrameMon = CFrame.new(-728.33, 52.78, 2345.77)
        elseif myLevel >= 725 and myLevel <= 774 then
            QuestData.Mon = "Mercenary"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "Area1Quest"
            QuestData.NameMon = "Mercenary"
            QuestData.CFrameQuest = CFrame.new(-429.54, 71.77, 1836.18)
            QuestData.CFrameMon = CFrame.new(-1004.32, 80.16, 1424.62)
        elseif myLevel >= 775 and myLevel <= 799 then
            QuestData.Mon = "Swan Pirate"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "Area2Quest"
            QuestData.NameMon = "Swan Pirate"
            QuestData.CFrameQuest = CFrame.new(638.44, 71.77, 918.28)
            QuestData.CFrameMon = CFrame.new(1068.66, 137.61, 1322.11)
        elseif myLevel >= 800 and myLevel <= 874 then
            QuestData.Mon = "Factory Staff"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "Area2Quest"
            QuestData.NameMon = "Factory Staff"
            QuestData.CFrameQuest = CFrame.new(632.70, 73.11, 918.67)
            QuestData.CFrameMon = CFrame.new(73.08, 81.86, -27.47)
        elseif myLevel >= 875 and myLevel <= 899 then
            QuestData.Mon = "Marine Lieutenant"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "MarineQuest3"
            QuestData.NameMon = "Marine Lieutenant"
            QuestData.CFrameQuest = CFrame.new(-2440.79, 71.72, -3216.06)
            QuestData.CFrameMon = CFrame.new(-2821.37, 72.99, -3070.11)
        elseif myLevel >= 900 and myLevel <= 949 then
            QuestData.Mon = "Marine Captain"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "MarineQuest3"
            QuestData.NameMon = "Marine Captain"
            QuestData.CFrameQuest = CFrame.new(-2440.79, 71.72, -3216.06)
            QuestData.CFrameMon = CFrame.new(-1861.26, 80.14, -3415.35)
        elseif myLevel >= 950 and myLevel <= 974 then
            QuestData.Mon = "Zombie"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "ZombieQuest"
            QuestData.NameMon = "Zombie"
            QuestData.CFrameQuest = CFrame.new(-5497.06, 47.59, -795.24)
            QuestData.CFrameMon = CFrame.new(-5657.77, 78.28, -928.68)
        elseif myLevel >= 975 and myLevel <= 999 then
            QuestData.Mon = "Vampire"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "ZombieQuest"
            QuestData.NameMon = "Vampire"
            QuestData.CFrameQuest = CFrame.new(-5497.06, 47.59, -795.24)
            QuestData.CFrameMon = CFrame.new(-6037.66, 6.32, -1313.64)
        elseif myLevel >= 1000 and myLevel <= 1049 then
            QuestData.Mon = "Snow Trooper"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "SnowMountainQuest"
            QuestData.NameMon = "Snow Trooper"
            QuestData.CFrameQuest = CFrame.new(609.86, 400.10, -5372.25)
            QuestData.CFrameMon = CFrame.new(549.13, 427.14, -5563.74)
        elseif myLevel >= 1050 and myLevel <= 1099 then
            QuestData.Mon = "Winter Warrior"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "SnowMountainQuest"
            QuestData.NameMon = "Winter Warrior"
            QuestData.CFrameQuest = CFrame.new(609.86, 400.10, -5372.25)
            QuestData.CFrameMon = CFrame.new(1142.66, 475.52, -5199.42)
        elseif myLevel >= 1100 and myLevel <= 1124 then
            QuestData.Mon = "Lab Subordinate"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "IceSideQuest"
            QuestData.NameMon = "Lab Subordinate"
            QuestData.CFrameQuest = CFrame.new(-6064.06, 15.20, -4902.97)
            QuestData.CFrameMon = CFrame.new(-5707.48, 15.95, -4513.39)
        elseif myLevel >= 1125 and myLevel <= 1174 then
            QuestData.Mon = "Horned Warrior"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "IceSideQuest"
            QuestData.NameMon = "Horned Warrior"
            QuestData.CFrameQuest = CFrame.new(-6064.06, 15.20, -4902.97)
            QuestData.CFrameMon = CFrame.new(-6341.36, 15.90, -5723.60)
        elseif myLevel >= 1175 and myLevel <= 1199 then
            QuestData.Mon = "Magma Ninja"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "FireSideQuest"
            QuestData.NameMon = "Magma Ninja"
            QuestData.CFrameQuest = CFrame.new(-5428.03, 15.09, -5299.43)
            QuestData.CFrameMon = CFrame.new(-5449.60, 76.65, -5808.79)
        elseif myLevel >= 1200 and myLevel <= 1249 then
            QuestData.Mon = "Lava Pirate"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "FireSideQuest"
            QuestData.NameMon = "Lava Pirate"
            QuestData.CFrameQuest = CFrame.new(-5428.03, 15.09, -5299.43)
            QuestData.CFrameMon = CFrame.new(-5213.33, 49.73, -4701.46)
        elseif myLevel >= 1250 and myLevel <= 1274 then
            QuestData.Mon = "Ship Deckhand"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "ShipQuest1"
            QuestData.NameMon = "Ship Deckhand"
            QuestData.CFrameQuest = CFrame.new(1037.80, 125.72, 32911.19)
            QuestData.CFrameMon = CFrame.new(1212.00, 150.79, 33059.24)
        elseif myLevel >= 1275 and myLevel <= 1299 then
            QuestData.Mon = "Ship Engineer"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "ShipQuest1"
            QuestData.NameMon = "Ship Engineer"
            QuestData.CFrameQuest = CFrame.new(1037.80, 125.72, 32911.19)
            QuestData.CFrameMon = CFrame.new(919.44, 43.54, 32779.96)
        elseif myLevel >= 1300 and myLevel <= 1324 then
            QuestData.Mon = "Ship Steward"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "ShipQuest2"
            QuestData.NameMon = "Ship Steward"
            QuestData.CFrameQuest = CFrame.new(968.80, 125.14, 33244.13)
            QuestData.CFrameMon = CFrame.new(919.54, 129.59, 33436.03)
        elseif myLevel >= 1325 and myLevel <= 1349 then
            QuestData.Mon = "Ship Officer"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "ShipQuest2"
            QuestData.NameMon = "Ship Officer"
            QuestData.CFrameQuest = CFrame.new(968.80, 125.14, 33244.13)
            QuestData.CFrameMon = CFrame.new(1036.01, 181.06, 33315.75)
        elseif myLevel >= 1350 and myLevel <= 1374 then
            QuestData.Mon = "Arctic Warrior"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "FrostQuest"
            QuestData.NameMon = "Arctic Warrior"
            QuestData.CFrameQuest = CFrame.new(5669.33, 28.20, -6482.60)
            QuestData.CFrameMon = CFrame.new(5995.07, 57.37, -6183.47)
        elseif myLevel >= 1375 and myLevel <= 1424 then
            QuestData.Mon = "Snow Lurker"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "FrostQuest"
            QuestData.NameMon = "Snow Lurker"
            QuestData.CFrameQuest = CFrame.new(5669.33, 28.20, -6482.60)
            QuestData.CFrameMon = CFrame.new(5518.38, 63.57, -6828.80)
        elseif myLevel >= 1425 and myLevel <= 1449 then
            QuestData.Mon = "Sea Soldier"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "ForgottenQuest"
            QuestData.NameMon = "Sea Soldier"
            QuestData.CFrameQuest = CFrame.new(-3054.45, 235.55, -10142.77)
            QuestData.CFrameMon = CFrame.new(-3028.14, 64.52, -9775.75)
        elseif myLevel >= 1450 then
            QuestData.Mon = "Water Fighter"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "ForgottenQuest"
            QuestData.NameMon = "Water Fighter"
            QuestData.CFrameQuest = CFrame.new(-3054.45, 235.55, -10142.77)
            QuestData.CFrameMon = CFrame.new(-3352.88, 285.01, -10534.84)
        end
    elseif World3 then
        if myLevel >= 1500 and myLevel <= 1524 then
            QuestData.Mon = "Pirate Millionaire"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "PiratePortQuest"
            QuestData.NameMon = "Pirate Millionaire"
            QuestData.CFrameQuest = CFrame.new(-290.07, 42.90, 5581.59)
            QuestData.CFrameMon = CFrame.new(-245.99, 47.31, 5584.10)
        elseif myLevel >= 1525 and myLevel <= 1574 then
            QuestData.Mon = "Pistol Billionaire"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "PiratePortQuest"
            QuestData.NameMon = "Pistol Billionaire"
            QuestData.CFrameQuest = CFrame.new(-290.07, 42.90, 5581.59)
            QuestData.CFrameMon = CFrame.new(-187.33, 86.24, 6013.51)
        elseif myLevel >= 1575 and myLevel <= 1599 then
            QuestData.Mon = "Dragon Crew Warrior"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "AmazonQuest"
            QuestData.NameMon = "Dragon Crew Warrior"
            QuestData.CFrameQuest = CFrame.new(5832.83, 51.60, -1101.51)
            QuestData.CFrameMon = CFrame.new(6141.14, 51.35, -1340.77)
        elseif myLevel >= 1600 and myLevel <= 1624 then
            QuestData.Mon = "Dragon Crew Archer"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "AmazonQuest"
            QuestData.NameMon = "Dragon Crew Archer"
            QuestData.CFrameQuest = CFrame.new(5832.83, 51.60, -1101.51)
            QuestData.CFrameMon = CFrame.new(6616.21, 441.76, 446.47)
        elseif myLevel >= 1625 and myLevel <= 1649 then
            QuestData.Mon = "Female Islander"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "AmazonQuest2"
            QuestData.NameMon = "Female Islander"
            QuestData.CFrameQuest = CFrame.new(5443.66, 601.62, 751.43)
            QuestData.CFrameMon = CFrame.new(4685.25, 735.09, -769.95)
        elseif myLevel >= 1650 and myLevel <= 1699 then
            QuestData.Mon = "Giant Islander"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "AmazonQuest2"
            QuestData.NameMon = "Giant Islander"
            QuestData.CFrameQuest = CFrame.new(5443.66, 601.62, 751.43)
            QuestData.CFrameMon = CFrame.new(4729.09, 590.44, -1975.30)
        elseif myLevel >= 1700 and myLevel <= 1724 then
            QuestData.Mon = "Marine Commodore"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "MarineTreeIsland"
            QuestData.NameMon = "Marine Commodore"
            QuestData.CFrameQuest = CFrame.new(2180.54, 27.82, -6741.50)
            QuestData.CFrameMon = CFrame.new(2286.05, 73.13, -7159.87)
        elseif myLevel >= 1725 and myLevel <= 1774 then
            QuestData.Mon = "Marine Rear Admiral"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "MarineTreeIsland"
            QuestData.NameMon = "Marine Rear Admiral"
            QuestData.CFrameQuest = CFrame.new(2180.54, 27.82, -6741.50)
            QuestData.CFrameMon = CFrame.new(3656.77, 160.52, -7001.84)
        elseif myLevel >= 1775 and myLevel <= 1799 then
            QuestData.Mon = "Fishman Raider"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "DeepForestIsland3"
            QuestData.NameMon = "Fishman Raider"
            QuestData.CFrameQuest = CFrame.new(-10581.60, 330.87, -8761.18)
            QuestData.CFrameMon = CFrame.new(-10407.51, 551.55, -8576.85)
        elseif myLevel >= 1800 and myLevel <= 1824 then
            QuestData.Mon = "Fishman Captain"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "DeepForestIsland3"
            QuestData.NameMon = "Fishman Captain"
            QuestData.CFrameQuest = CFrame.new(-10581.60, 330.87, -8761.18)
            QuestData.CFrameMon = CFrame.new(-10994.70, 521.55, -9298.12)
        elseif myLevel >= 1825 and myLevel <= 1849 then
            QuestData.Mon = "Forest Pirate"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "DeepForestIsland"
            QuestData.NameMon = "Forest Pirate"
            QuestData.CFrameQuest = CFrame.new(-13234.04, 331.49, -7625.40)
            QuestData.CFrameMon = CFrame.new(-13274.53, 332.40, -7769.34)
        elseif myLevel >= 1850 and myLevel <= 1899 then
            QuestData.Mon = "Mythological Pirate"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "DeepForestIsland"
            QuestData.NameMon = "Mythological Pirate"
            QuestData.CFrameQuest = CFrame.new(-13234.04, 331.49, -7625.40)
            QuestData.CFrameMon = CFrame.new(-13508.62, 582.45, -6985.36)
        elseif myLevel >= 1900 and myLevel <= 1924 then
            QuestData.Mon = "Jungle Pirate"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "DeepForestIsland2"
            QuestData.NameMon = "Jungle Pirate"
            QuestData.CFrameQuest = CFrame.new(-12680.39, 389.97, -9902.01)
            QuestData.CFrameMon = CFrame.new(-12256.16, 331.73, -10485.80)
        elseif myLevel >= 1925 and myLevel <= 1974 then
            QuestData.Mon = "Musketeer Pirate"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "DeepForestIsland2"
            QuestData.NameMon = "Musketeer Pirate"
            QuestData.CFrameQuest = CFrame.new(-12680.39, 389.97, -9902.01)
            QuestData.CFrameMon = CFrame.new(-13291.54, 520.47, -9904.64)
        elseif myLevel >= 1975 and myLevel <= 1999 then
            QuestData.Mon = "Reborn Skeleton"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "HauntedQuest1"
            QuestData.NameMon = "Reborn Skeleton"
            QuestData.CFrameQuest = CFrame.new(-9479.85, 141.22, 5566.09)
            QuestData.CFrameMon = CFrame.new(-8763.96, 165.72, 6159.86)
        elseif myLevel >= 2000 and myLevel <= 2024 then
            QuestData.Mon = "Living Zombie"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "HauntedQuest1"
            QuestData.NameMon = "Living Zombie"
            QuestData.CFrameQuest = CFrame.new(-9479.85, 141.22, 5566.09)
            QuestData.CFrameMon = CFrame.new(-10144.75, 138.65, 5971.24)
        elseif myLevel >= 2025 and myLevel <= 2049 then
            QuestData.Mon = "Demonic Soul"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "HauntedQuest2"
            QuestData.NameMon = "Demonic Soul"
            QuestData.CFrameQuest = CFrame.new(-9546.99, 172.02, 6078.46)
            QuestData.CFrameMon = CFrame.new(-9507.13, 172.13, 6158.88)
        elseif myLevel >= 2050 and myLevel <= 2074 then
            QuestData.Mon = "Posessed Mummy"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "HauntedQuest2"
            QuestData.NameMon = "Posessed Mummy"
            QuestData.CFrameQuest = CFrame.new(-9546.99, 172.02, 6078.46)
            QuestData.CFrameMon = CFrame.new(-9582.04, 6.25, 6205.78)
        elseif myLevel >= 2075 and myLevel <= 2099 then
            QuestData.Mon = "Peanut Scout"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "NutsIslandQuest"
            QuestData.NameMon = "Peanut Scout"
            QuestData.CFrameQuest = CFrame.new(-2104.35, 38.10, -10192.08)
            QuestData.CFrameMon = CFrame.new(-2143.12, 47.62, -10029.42)
        elseif myLevel >= 2100 and myLevel <= 2124 then
            QuestData.Mon = "Peanut President"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "NutsIslandQuest"
            QuestData.NameMon = "Peanut President"
            QuestData.CFrameQuest = CFrame.new(-2104.35, 38.10, -10192.08)
            QuestData.CFrameMon = CFrame.new(-1859.35, 38.10, -10422.03)
        elseif myLevel >= 2125 and myLevel <= 2149 then
            QuestData.Mon = "Ice Cream Chef"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "IceCreamIslandQuest"
            QuestData.NameMon = "Ice Cream Chef"
            QuestData.CFrameQuest = CFrame.new(-820.64, 65.82, -10965.79)
            QuestData.CFrameMon = CFrame.new(-882.24, 71.22, -11010.79)
        elseif myLevel >= 2150 and myLevel <= 2199 then
            QuestData.Mon = "Ice Cream Commander"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "IceCreamIslandQuest"
            QuestData.NameMon = "Ice Cream Commander"
            QuestData.CFrameQuest = CFrame.new(-820.64, 65.82, -10965.79)
            QuestData.CFrameMon = CFrame.new(-558.06, 112.55, -11290.92)
        elseif myLevel >= 2200 and myLevel <= 2224 then
            QuestData.Mon = "Cookie Crafter"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "CakeQuest1"
            QuestData.NameMon = "Cookie Crafter"
            QuestData.CFrameQuest = CFrame.new(-2021.32, 37.80, -12028.73)
            QuestData.CFrameMon = CFrame.new(-2374.13, 37.79, -12125.97)
        elseif myLevel >= 2225 and myLevel <= 2249 then
            QuestData.Mon = "Cake Guard"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "CakeQuest1"
            QuestData.NameMon = "Cake Guard"
            QuestData.CFrameQuest = CFrame.new(-2021.32, 37.80, -12028.73)
            QuestData.CFrameMon = CFrame.new(-1598.00, 43.73, -12244.90)
        elseif myLevel >= 2250 and myLevel <= 2274 then
            QuestData.Mon = "Baking Staff"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "CakeQuest2"
            QuestData.NameMon = "Baking Staff"
            QuestData.CFrameQuest = CFrame.new(-1927.91, 37.80, -12842.53)
            QuestData.CFrameMon = CFrame.new(-1887.83, 77.22, -12998.07)
        elseif myLevel >= 2275 and myLevel <= 2299 then
            QuestData.Mon = "Head Baker"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "CakeQuest2"
            QuestData.NameMon = "Head Baker"
            QuestData.CFrameQuest = CFrame.new(-1927.91, 37.80, -12842.53)
            QuestData.CFrameMon = CFrame.new(-2216.19, 82.88, -12869.87)
        elseif myLevel >= 2300 and myLevel <= 2324 then
            QuestData.Mon = "Cocoa Warrior"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "ChocQuest1"
            QuestData.NameMon = "Cocoa Warrior"
            QuestData.CFrameQuest = CFrame.new(233.22, 29.88, -12201.29)
            QuestData.CFrameMon = CFrame.new(-21.55, 80.57, -12352.11)
        elseif myLevel >= 2325 and myLevel <= 2349 then
            QuestData.Mon = "Chocolate Bar Battler"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "ChocQuest1"
            QuestData.NameMon = "Chocolate Bar Battler"
            QuestData.CFrameQuest = CFrame.new(233.22, 29.88, -12201.29)
            QuestData.CFrameMon = CFrame.new(582.59, 77.34, -12463.01)
        elseif myLevel >= 2350 and myLevel <= 2374 then
            QuestData.Mon = "Sweet Thief"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "ChocQuest2"
            QuestData.NameMon = "Sweet Thief"
            QuestData.CFrameQuest = CFrame.new(150.50, 30.69, -12774.79)
            QuestData.CFrameMon = CFrame.new(165.23, 76.05, -12600.78)
        elseif myLevel >= 2375 and myLevel <= 2399 then
            QuestData.Mon = "Candy Rebel"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "ChocQuest2"
            QuestData.NameMon = "Candy Rebel"
            QuestData.CFrameQuest = CFrame.new(150.50, 30.69, -12774.79)
            QuestData.CFrameMon = CFrame.new(134.86, 77.22, -12882.44)
        elseif myLevel >= 2400 and myLevel <= 2424 then
            QuestData.Mon = "Candy Pirate"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "CandyQuest1"
            QuestData.NameMon = "Candy Pirate"
            QuestData.CFrameQuest = CFrame.new(-1150.07, 20.13, -14446.13)
            QuestData.CFrameMon = CFrame.new(-1310.37, 26.52, -14562.40)
        elseif myLevel >= 2425 and myLevel <= 2449 then
            QuestData.Mon = "Snow Demon"
            QuestData.LevelQuest = 2
            QuestData.NameQuest = "CandyQuest1"
            QuestData.NameMon = "Snow Demon"
            QuestData.CFrameQuest = CFrame.new(-1150.07, 20.13, -14446.13)
            QuestData.CFrameMon = CFrame.new(-880.20, 71.25, -14538.61)
        elseif myLevel >= 2450 then
            QuestData.Mon = "Isle Outlaw"
            QuestData.LevelQuest = 1
            QuestData.NameQuest = "TikiQuest1"
            QuestData.NameMon = "Isle Outlaw"
            QuestData.CFrameQuest = CFrame.new(-16545.90, 55.68, -173.23)
            QuestData.CFrameMon = CFrame.new(-16120.60, 116.52, -103.14)
        end
    end
end

function AutoFarm:TakeQuest()
    if not env.AutoQuest then return end
    if not QuestData or not QuestData.NameQuest then return end
    
    local questGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
    if not questGui then return end
    
    local questContainer = questGui:FindFirstChild("Quest")
    if not questContainer then return end
    
    -- Check if we have the right quest
    if questContainer.Visible == true then
        local container = questContainer:FindFirstChild("Container")
        if container then
            local questTitle = container:FindFirstChild("QuestTitle")
            if questTitle and questTitle:FindFirstChild("Title") then
                local titleText = questTitle.Title.Text
                if string.find(titleText, QuestData.NameMon) then
                    return -- Already have correct quest
                else
                    -- Abandon wrong quest
                    pcall(function()
                        CommF:InvokeServer("AbandonQuest")
                    end)
                    task.wait(0.5)
                end
            end
        end
    end
    
    -- Update quest for current level
    self:CheckQuest()
    
    -- Go to quest giver if too far
    if self:GetDistance(QuestData.CFrameQuest.Position) > 10 then
        self:Tween(QuestData.CFrameQuest)
        task.wait(1)
    end
    
    -- Take quest
    pcall(function()
        CommF:InvokeServer("StartQuest", QuestData.NameQuest, QuestData.LevelQuest)
    end)
    
    task.wait(0.5)
end

-- Weapon Management
function AutoFarm:AutoSelectWeapon()
    local weaponType = env.SelectWeapon
    
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local tooltip = tool.ToolTip
            
            if weaponType == "Melee" and tooltip == "Melee" then
                env.SelectedWeapon = tool.Name
                return
            elseif weaponType == "Sword" and tooltip == "Sword" then
                env.SelectedWeapon = tool.Name
                return
            elseif weaponType == "Gun" and tooltip == "Gun" then
                env.SelectedWeapon = tool.Name
                return
            elseif weaponType == "Fruit" and tooltip == "Blox Fruit" then
                env.SelectedWeapon = tool.Name
                return
            end
        end
    end
    
    for _, tool in pairs(Character:GetChildren()) do
        if tool:IsA("Tool") then
            local tooltip = tool.ToolTip
            
            if weaponType == "Melee" and tooltip == "Melee" then
                env.SelectedWeapon = tool.Name
                return
            elseif weaponType == "Sword" and tooltip == "Sword" then
                env.SelectedWeapon = tool.Name
                return
            elseif weaponType == "Gun" and tooltip == "Gun" then
                env.SelectedWeapon = tool.Name
                return
            elseif weaponType == "Fruit" and tooltip == "Blox Fruit" then
                env.SelectedWeapon = tool.Name
                return
            end
        end
    end
end

function AutoFarm:EquipWeapon()
    if not self:IsAlive() then return end
    
    self:AutoSelectWeapon()
    
    if not env.SelectedWeapon then
        return
    end
    
    if Character:FindFirstChild(env.SelectedWeapon) then
        return
    end
    
    local weapon = LocalPlayer.Backpack:FindFirstChild(env.SelectedWeapon)
    if weapon then
        Humanoid:EquipTool(weapon)
    end
end

-- Attack System
function AutoFarm:Attack()
    if not self:IsAlive() then return end
    
    self:EquipWeapon()
    
    if env.FastAttack and FastAttackRemotes.RegisterAttack and FastAttackRemotes.RegisterHit then
        local nearbyEnemies = {}
        local targetPart = nil
        
        for _, enemy in pairs(Enemies:GetChildren()) do
            local head = enemy:FindFirstChild("Head")
            local hum = enemy:FindFirstChild("Humanoid")
            if head and hum and hum.Health > 0 then
                local distance = (HumanoidRootPart.Position - head.Position).Magnitude
                if distance < 100 then
                    table.insert(nearbyEnemies, {enemy, head})
                    if not targetPart then
                        targetPart = head
                    end
                end
            end
        end
        
        if targetPart and #nearbyEnemies > 0 then
            pcall(function()
                FastAttackRemotes.RegisterAttack:FireServer(0.1)
                FastAttackRemotes.RegisterHit:FireServer(targetPart, nearbyEnemies)
            end)
        end
    end
    
    self:Click()
end

-- Enemy Management
function AutoFarm:GetQuestEnemies()
    local enemies = {}
    
    for _, enemy in pairs(Enemies:GetChildren()) do
        if enemy.Name == QuestData.Mon then
            local enemyHum = enemy:FindFirstChild("Humanoid")
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
            
            if enemyHum and enemyRoot and enemyHum.Health > 0 then
                table.insert(enemies, {
                    Model = enemy,
                    Humanoid = enemyHum,
                    Root = enemyRoot,
                    Distance = self:GetDistance(enemyRoot.Position)
                })
            end
        end
    end
    
    table.sort(enemies, function(a, b)
        return a.Distance < b.Distance
    end)
    
    return enemies
end

function AutoFarm:GetAllEnemies()
    local enemies = {}
    
    for _, enemy in pairs(Enemies:GetChildren()) do
        local enemyHum = enemy:FindFirstChild("Humanoid")
        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
        
        if enemyHum and enemyRoot and enemyHum.Health > 0 then
            table.insert(enemies, {
                Model = enemy,
                Humanoid = enemyHum,
                Root = enemyRoot,
                Distance = self:GetDistance(enemyRoot.Position)
            })
        end
    end
    
    table.sort(enemies, function(a, b)
        return a.Distance < b.Distance
    end)
    
    return enemies
end

function AutoFarm:GetClosestEnemy()
    if env.FarmMode == "Quest" then
        local questEnemies = self:GetQuestEnemies()
        return questEnemies[1]
    else
        local enemies = self:GetAllEnemies()
        return enemies[1]
    end
end

-- Mob Bringing System
function AutoFarm:GetSpinPosition()
    if not env.SpinPosition then
        return CFrame.new(0, env.AttackDistance, 0)
    end
    
    local radius = 20
    local radian = math.rad(CurrentAngle)
    local x = math.cos(radian) * radius
    local z = math.sin(radian) * radius
    CurrentAngle = (CurrentAngle + 30) % 360
    
    return CFrame.new(x, env.AttackDistance, z)
end

function AutoFarm:BringMobs(targetCFrame)
    if not env.BringMobs then return end
    
    for _, enemy in pairs(Enemies:GetChildren()) do
        if env.FarmMode == "Quest" and enemy.Name ~= QuestData.Mon then
            continue
        end
        
        local enemyHum = enemy:FindFirstChild("Humanoid")
        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
        
        if enemyHum and enemyRoot and enemyHum.Health > 0 then
            if self:GetDistance(enemyRoot.Position) <= 350 then
                enemyRoot.CFrame = targetCFrame
                enemyRoot.CanCollide = false
                enemyRoot.Size = Vector3.new(60, 60, 60)
                enemyRoot.Transparency = 1
                enemyHum.WalkSpeed = 0
                enemyHum.JumpPower = 0
                
                if enemyHum:FindFirstChild("Animator") then
                    enemyHum.Animator:Destroy()
                end
                
                sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            end
        end
    end
end

-- Main Farm Loop
function AutoFarm.StartLoop()
    print("[Auto Farm] Farm loop started!")
    
    task.spawn(function()
        -- Initialize first
        print("[Auto Farm] Initializing...")
        print("[Auto Farm] World:", World1 and "Sea 1" or World2 and "Sea 2" or World3 and "Sea 3" or "Unknown")
        
        -- Enable SimulationRadius for BringMobs
        task.spawn(function()
            RunService.Heartbeat:Connect(function()
                pcall(function()
                    if sethiddenproperty then
                        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
                    end
                end)
            end)
        end)
        
        -- NoClip
        if env.NoClip then
            AutoFarm:StartNoClip()
        end
        
        print("[Auto Farm] Initialized successfully!")
        
        -- Main loop
        while task.wait(0.1) do
            pcall(function()
                if not env.AutoFarm or not AutoFarm:IsAlive() then
                    return
                end
                
                -- Auto Haki
                if env.AutoHaki then
                    AutoFarm:AutoHaki()
                end
                
                -- Take Quest
                if env.FarmMode == "Quest" then
                    AutoFarm:TakeQuest()
                end
                
                -- Find Enemy
                local enemy = AutoFarm:GetClosestEnemy()
                
                if enemy and enemy.Humanoid.Health > 0 then
                    local spinPos = AutoFarm:GetSpinPosition()
                    local attackCFrame = enemy.Root.CFrame * spinPos
                    
                    -- Move to enemy
                    if AutoFarm:GetDistance(enemy.Root.Position) > 250 then
                        AutoFarm:Tween(attackCFrame, env.TweenSpeed)
                    else
                        AutoFarm:Teleport(attackCFrame)
                    end
                    
                    -- Bring mobs
                    AutoFarm:BringMobs(enemy.Root.CFrame)
                    
                    -- Attack
                    if env.FastAttack then
                        for i = 1, 3 do
                            AutoFarm:Attack()
                            task.wait(0.15)
                        end
                    else
                        AutoFarm:Attack()
                    end
                else
                    -- No enemies, go to spawn location
                    if env.FarmMode == "Quest" and QuestData.CFrameMon then
                        AutoFarm:Tween(QuestData.CFrameMon, env.TweenSpeed)
                    end
                end
            end)
        end
    end)
end

-- NoClip System
function AutoFarm:StartNoClip()
    if not env.NoClip then return end
    
    task.spawn(function()
        RunService.Stepped:Connect(function()
            if env.NoClip and self:IsAlive() then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end)
    
    print("[Auto Farm] NoClip enabled")
end

-- Stop function for cleanup
function AutoFarm.Stop()
    env.AutoFarm = false
    print("[Auto Farm] Stopped")
end

return AutoFarm
