local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local WalkSpeed = {}
local Enabled = false
local SpeedValue = 16

local function UpdateSpeed()
    if not Enabled then return end
    
    local Character = LocalPlayer.Character
    if Character then
        local Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.WalkSpeed = SpeedValue
        end
    end
end

-- Force speed constantly in case game resets it
RunService.RenderStepped:Connect(UpdateSpeed)

function WalkSpeed.Toggle(state)
    Enabled = state
    if not state then
        -- Reset to default
        local Character = LocalPlayer.Character
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.WalkSpeed = 16
        end
    end
end

function WalkSpeed.SetSpeed(val)
    SpeedValue = val
end

return WalkSpeed
