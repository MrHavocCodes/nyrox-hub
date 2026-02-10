-- Walk on Water Script

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Plattform erstellen
local WaterPlatform = Instance.new("Part")
WaterPlatform.Size = Vector3.new(10, 0.5, 10) -- Größe der Plattform
WaterPlatform.Anchored = true  -- Fixiert in der Luft
WaterPlatform.Transparency = 1  -- Unsichtbar
WaterPlatform.CanCollide = false  -- Erstmal aus
WaterPlatform.Name = "WaterPlatform"
WaterPlatform.Parent = workspace

local connection

local function StartWalkOnWater()
    if connection then return end
    
    connection = RunService.Heartbeat:Connect(function()
        if not getgenv().WalkOnWater then
            WaterPlatform.CanCollide = false
            return
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- Plattform unter dem Spieler positionieren
        local pos = hrp.Position
        WaterPlatform.Position = Vector3.new(pos.X, 0.5, pos.Z) -- Y = Wasserhöhe
        WaterPlatform.CanCollide = true
    end)
end

StartWalkOnWater()