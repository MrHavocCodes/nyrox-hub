--[[
    Nyrox Hub - Factory Farm (Sea 2)
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function GetEnv()
    if type(getgenv) == "function" then return getgenv() end
    return shared
end
local env = GetEnv()
local LocalPlayer = Players.LocalPlayer

local FactoryFarm = {}

-- Settings
if env.AutoFactory == nil then env.AutoFactory = false end
if env.SelectedWeapon == nil then env.SelectedWeapon = "Combat" end

-- Factory Core Door
local FactoryCoreDoor = CFrame.new(250, 73, -372)

-- Find Factory Staff
local function FindFactoryStaff()
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    
    local closestMob = nil
    local closestDist = math.huge
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    for _, mob in pairs(enemies:GetChildren()) do
        if mob.Name == "Factory Staff" then
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

-- Enter Factory
local function EnterFactory()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- Check if already inside
        local dist = (hrp.Position - FactoryCoreDoor.Position).Magnitude
        if dist < 500 then return end
        
        -- Request entrance
        ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(250, 73, -372))
        task.wait(1)
    end)
end

-- Main Loop
function FactoryFarm.StartLoop()
    task.spawn(function()
        print("[Factory Farm] 🏭 Started!")
        
        while env.NyroxRunning do
            if not env.AutoFactory then
                task.wait(1)
                continue
            end
            
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                -- Enter factory first
                EnterFactory()
                
                -- Find Factory Staff
                local mob = FindFactoryStaff()
                
                if mob then
                    local mobHRP = mob:FindFirstChild("HumanoidRootPart")
                    local mobPos = mobHRP.CFrame * CFrame.new(0, 30, 0)
                    local dist = (hrp.Position - mobHRP.Position).Magnitude
                    
                    -- Move to mob
                    if dist > 250 then
                        CoreFunctions.TweenToPosition(mobPos.Position, 350)
                    else
                        -- Attack continuously
                        while env.AutoFactory and mob.Parent and mob.Humanoid.Health > 0 do
                            -- Position above mob
                            hrp.CFrame = mobHRP.CFrame * CFrame.new(0, 30, 0)
                            
                            -- ATTACK using CoreFunctions
                            CoreFunctions.Attack(env.SelectedWeapon)
                            
                            -- Bring other mobs
                            CoreFunctions.BringMobs(mobHRP.CFrame, 350)
                            
                            task.wait(0.1)
                        end
                    end
                else
                    -- No mobs, go to spawn area
                    CoreFunctions.TweenToPosition(FactoryCoreDoor.Position, 350)
                end
            end)
            
            task.wait(0.5)
        end
        
        print("[Factory Farm] ⏹️  Stopped")
    end)
end

function FactoryFarm.Stop()
    env.AutoFactory = false
end

return FactoryFarm
