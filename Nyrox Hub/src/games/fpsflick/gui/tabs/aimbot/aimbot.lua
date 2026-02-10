local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Aimbot = {}

-- Settings
local Settings = {
    Enabled = false,
    FOV = 100,
    ShowFOV = true,
    TeamCheck = false, -- Disabled by default for FFA/Flick games
    WallCheck = true,
    AimPart = "Head", 
    Smoothness = 0 
}

-- Drawing Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Radius = Settings.FOV
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = Settings.ShowFOV

-- Add to global drawings cleaner if available
if getgenv().NyroxDrawings then
    table.insert(getgenv().NyroxDrawings, FOVCircle)
end

-- Helper: Check if player is alive and visible
local function IsAlive(model)
    return model and model:FindFirstChild("Humanoid") and model.Humanoid.Health > 0
end

local function IsVisible(targetPart)
    local Origin = Camera.CFrame.Position
    local Direction = (targetPart.Position - Origin).Unit * (targetPart.Position - Origin).Magnitude
    local RaycastParams = RaycastParams.new()
    RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
    RaycastParams.IgnoreWater = true

    local Result = Workspace:Raycast(Origin, Direction, RaycastParams)
    return Result == nil or Result.Instance:IsDescendantOf(targetPart.Parent)
end

-- Helper: Get Closest Player to Mouse
local function GetClosestPlayer()
    local MouseLocation = UserInputService:GetMouseLocation()
    local ClosestPlayer = nil
    local ShortestDistance = Settings.FOV

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            if Settings.TeamCheck and Player.Team == LocalPlayer.Team then
                -- Skip teammates
            else
                local Character = Player.Character
                -- Some games don't use Humanoid.Health properly or use custom health systems. 
                -- We check if Humanoid exists, otherwise we assume alive if character exists.
                local Humanoid = Character and Character:FindFirstChild("Humanoid")
                local IsAliveCheck = Humanoid and Humanoid.Health > 0
                
                -- Fallback for games without standard Humanoids
                if not Humanoid and Character then IsAliveCheck = true end

                if Character and IsAliveCheck then
                    local TargetPart = Character:FindFirstChild(Settings.AimPart) 
                                     or Character:FindFirstChild("Head") 
                                     or Character:FindFirstChild("Torso")
                                     or Character:FindFirstChild("HumanoidRootPart")
                    
                    if TargetPart then
                        local ScreenPoint, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
                        
                        if OnScreen then
                            local Distance = (Vector2.new(ScreenPoint.X, ScreenPoint.Y) - MouseLocation).Magnitude
                            
                            if Distance < ShortestDistance then
                                local isVisible = true
                                if Settings.WallCheck then
                                    isVisible = IsVisible(TargetPart)
                                end

                                if isVisible then
                                    ShortestDistance = Distance
                                    ClosestPlayer = TargetPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return ClosestPlayer
end

-- Main Loop
local function UpdateLoop()
    -- Update FOV Circle Position
    local MouseLocation = UserInputService:GetMouseLocation()
    FOVCircle.Position = MouseLocation
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Visible = Settings.ShowFOV and Settings.Enabled

    if Settings.Enabled then
        local Target = GetClosestPlayer()
        if Target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position)
        end
    end
end

local Connection = RunService.RenderStepped:Connect(UpdateLoop)

-- Add to cleanup
if getgenv().NyroxConnections then
    table.insert(getgenv().NyroxConnections, Connection)
end


-- Module Functions
function Aimbot.SetEnabled(state)
    Settings.Enabled = state
    FOVCircle.Visible = state and Settings.ShowFOV
end

function Aimbot.SetFOV(radius)
    Settings.FOV = radius
    FOVCircle.Radius = radius
end

function Aimbot.ToggleFOV(state)
    Settings.ShowFOV = state
    FOVCircle.Visible = Settings.Enabled and state
end

function Aimbot.ToggleWallCheck(state)
    Settings.WallCheck = state
end

return Aimbot
