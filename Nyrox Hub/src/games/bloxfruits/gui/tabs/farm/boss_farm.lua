local CoreFunctions = nil
pcall(function()
    if script and script.Parent then
        CoreFunctions = require(script.Parent.Parent.Parent.Parent.utils.core_functions)
    end
end)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local function GetEnv()
    if type(getgenv) == "function" then return getgenv() end
    return shared
end
local env = GetEnv()
local LocalPlayer = Players.LocalPlayer

local BossFarm = {}

-- Settings
if env.AutoBoss == nil then env.AutoBoss = false end
if env.SelectedBoss == nil then env.SelectedBoss = "All" end
if env.SelectedWeapon == nil then env.SelectedWeapon = "Combat" end

-- Boss List
local BossList = {
    -- Sea 1
    ["Thunder God"] = {CFrame = CFrame.new(-7748.0185546875, 5606.80615234375, -2305.898681640625)},
    ["Saber Expert"] = {CFrame = CFrame.new(-1458.89013671875, 29.8870182037354, -50.633563995361328)},
    ["The Saw"] = {CFrame = CFrame.new(-683.19287109375, 15.09425163269043, 1610.3231201171875)},
    ["Greybeard"] = {CFrame = CFrame.new(-4875, 125, 4086)},
    
    -- Sea 2
    ["Diamond"] = {CFrame = CFrame.new(-1736.0, 198.0, -236.0)},
    ["Jeremy"] = {CFrame = CFrame.new(2096.0, 448.0, 853.0)},
    ["Fajita"] = {CFrame.new(-2030.0, 73.0, -12855.0)},
    
    -- Sea 3
    ["Don Swan"] = {CFrame = CFrame.new(2288.0, 15.0, 863.0)},
    ["Rip_Indra"] = {CFrame = CFrame.new(-5332.0, 423.0, -2673.0)}
}

-- Find Boss in Workspace
local function FindBoss(bossName)
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    
    if bossName == "All" then
        -- Find any boss
        for name, data in pairs(BossList) do
            local boss = enemies:FindFirstChild(name)
            if boss then
                local bossHum = boss:FindFirstChild("Humanoid")
                local bossHRP = boss:FindFirstChild("HumanoidRootPart")
                if bossHum and bossHRP and bossHum.Health > 0 then
                    return boss, bossHRP
                end
            end
        end
    else
        -- Find specific boss
        local boss = enemies:FindFirstChild(bossName)
        if boss then
            local bossHum = boss:FindFirstChild("Humanoid")
            local bossHRP = boss:FindFirstChild("HumanoidRootPart")
            if bossHum and bossHRP and bossHum.Health > 0 then
                return boss, bossHRP
            end
        end
    end
    
    return nil, nil
end

-- Main Loop
function BossFarm.StartLoop()
    task.spawn(function()
        print("[Boss Farm] 🎯 Started!")
        
        while env.NyroxRunning do
            if not env.AutoBoss then
                task.wait(1)
                continue
            end
            
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                -- Find boss
                local boss, bossHRP = FindBoss(env.SelectedBoss)
                
                if boss and bossHRP then
                    local bossPos = bossHRP.CFrame * CFrame.new(0, 30, 0)
                    local dist = (hrp.Position - bossHRP.Position).Magnitude
                    
                    -- Move to boss
                    if dist > 250 then
                        CoreFunctions.TweenToPosition(bossPos.Position, 350)
                    else
                        -- Attack continuously
                        while env.AutoBoss and boss.Parent and boss.Humanoid.Health > 0 do
                            -- Position above boss
                            hrp.CFrame = bossHRP.CFrame * CFrame.new(0, 30, 0)
                            
                            -- ATTACK using CoreFunctions
                            CoreFunctions.Attack(env.SelectedWeapon)
                            
                            task.wait(0.1)
                        end
                    end
                else
                    -- No boss found, go to spawn
                    if env.SelectedBoss ~= "All" and BossList[env.SelectedBoss] then
                        CoreFunctions.TweenToPosition(BossList[env.SelectedBoss].CFrame.Position, 350)
                    end
                end
            end)
            
            task.wait(0.5)
        end
        
        print("[Boss Farm] ⏹️  Stopped")
    end)
end

function BossFarm.Stop()
    env.AutoBoss = false
end

return BossFarm
