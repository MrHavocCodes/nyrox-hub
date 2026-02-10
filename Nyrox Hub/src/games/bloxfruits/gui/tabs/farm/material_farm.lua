--[[
    Nyrox Hub - Material Farm
    Uses shared CoreFunctions for M1 Attack
]]

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

local MaterialFarm = {}

-- Settings
if env.AutoMaterial == nil then env.AutoMaterial = false end
if env.SelectedMaterial == nil then env.SelectedMaterial = "Leather" end
if env.SelectedWeapon == nil then env.SelectedWeapon = "Combat" end

-- Material -> Mob Mapping
local MaterialMobs = {
    ["Leather"] = "Pirate",
    ["Scrap Metal"] = "Brute",
    ["Angel Wings"] = "God's Guard",
    ["Magma Ore"] = "Military Soldier",
    ["Fish Tail"] = "Fishman Warrior",
    ["Mystic Droplet"] = "Sea Soldier",
    ["Dragon Scale"] = "Dragon Crew Warrior",
    ["Gunpowder"] = "Pistol Billionaire",
    ["Mini Tusk"] = "Mythological Pirate",
    ["Conjured Cocoa"] = "Chocolate Bar Battler",
    ["Demonic Wisp"] = "Demonic Soul"
}

-- Find Material Mob
local function FindMaterialMob()
    local mobName = MaterialMobs[env.SelectedMaterial]
    if not mobName then return nil end
    
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    
    local closestMob = nil
    local closestDist = math.huge
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    for _, mob in pairs(enemies:GetChildren()) do
        if mob.Name == mobName then
            local mobHum = mob:FindFirstChild("Humanoid")
            local mobHRP = mob:FindFirstChild("HumanoidRootPart")
            
            if mobHum and mobHRP and mobHum.Health > 0 then
                local dist = (hrp.Position - mobHRP.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestMob = mob
                end
            end
        end
    end
    
    return closestMob
end

-- Main Loop
function MaterialFarm.StartLoop()
    task.spawn(function()
        print("[Material Farm] 📦 Started farming:", env.SelectedMaterial)
        
        while env.NyroxRunning do
            if not env.AutoMaterial then
                task.wait(1)
                continue
            end
            
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                -- Find material mob
                local mob = FindMaterialMob()
                
                if mob then
                    local mobHRP = mob:FindFirstChild("HumanoidRootPart")
                    local mobPos = mobHRP.CFrame * CFrame.new(0, 30, 0)
                    local dist = (hrp.Position - mobHRP.Position).Magnitude
                    
                    -- Move to mob
                    if dist > 250 then
                        CoreFunctions.TweenToPosition(mobPos.Position, 350)
                    else
                        -- Attack continuously
                        while env.AutoMaterial and mob.Parent and mob.Humanoid.Health > 0 do
                            -- Position above mob
                            hrp.CFrame = mobHRP.CFrame * CFrame.new(0, 30, 0)
                            
                            -- ATTACK using CoreFunctions
                            CoreFunctions.Attack(env.SelectedWeapon)
                            
                            -- Bring other mobs
                            CoreFunctions.BringMobs(mobHRP.CFrame, 350)
                            
                            task.wait(0.1)
                        end
                    end
                end
            end)
            
            task.wait(0.5)
        end
        
        print("[Material Farm] ⏹️  Stopped")
    end)
end

function MaterialFarm.Stop()
    env.AutoMaterial = false
end

return MaterialFarm
