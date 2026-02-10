local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Safe environment access
local function GetEnv()
    if type(getgenv) == "function" then
        return getgenv()
    end
    return shared
end

local env = GetEnv()

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local SpectatePlayer = {}

-- Variable tracking (optional, but good for saving state locally if needed)
local currentConnection = nil

function SpectatePlayer.StartLoop()
    -- Use RenderStepped to ensure the camera subject is locked every frame
    if currentConnection then return end -- Already running logic (though usually we just rely on global flags)

    currentConnection = RunService.RenderStepped:Connect(function()
        if not env.NyroxRunning then
            if currentConnection then 
                currentConnection:Disconnect() 
                currentConnection = nil
            end
            return
        end

        if env.AutoSpectate then
            local targetName = env.TargetPlayer
            if targetName and targetName ~= "None" then
                local targetUser = Players:FindFirstChild(targetName)
                
                if targetUser and targetUser.Character and targetUser.Character:FindFirstChild("Humanoid") then
                    Camera.CameraSubject = targetUser.Character.Humanoid
                else
                    -- Fallback to LocalPlayer if target is invalid/dead/missing
                   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        Camera.CameraSubject = LocalPlayer.Character.Humanoid
                   end
                end
            else
                -- No target selected
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                   Camera.CameraSubject = LocalPlayer.Character.Humanoid
                end
            end
        else
            -- If disabled, ensure we are watching LocalPlayer (one-time reset usually handled by game, but good to force once)
            -- However, simply NOT setting it allows the game default behavior. 
            -- But if we just toggled off, we want to snap back immediately.
             if Camera.CameraSubject ~= LocalPlayer.Character and Camera.CameraSubject ~= LocalPlayer.Character:FindFirstChild("Humanoid") then
                 if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    Camera.CameraSubject = LocalPlayer.Character.Humanoid
                 end
             end
        end
    end)
end

return SpectatePlayer
