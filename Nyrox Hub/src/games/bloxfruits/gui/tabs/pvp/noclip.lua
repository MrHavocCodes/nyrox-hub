-- Noclip Module
local NoClip = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local NoClipConnection

function NoClip.Enable()
    if NoClipConnection then return end
    
    NoClipConnection = RunService.Stepped:Connect(function()
        if not getgenv().NoClip then return end
        
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

function NoClip.Disable()
    if NoClipConnection then
        NoClipConnection:Disconnect()
        NoClipConnection = nil
    end
    
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

-- Auto-toggle based on global flag
task.spawn(function()
    while getgenv().NyroxRunning do
        if getgenv().NoClip and not NoClipConnection then
            NoClip.Enable()
        elseif not getgenv().NoClip and NoClipConnection then
            NoClip.Disable()
        end
        task.wait(0.5)
    end
end)

return NoClip
