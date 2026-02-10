local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Fly = {}
local Buying = false

-- === FLY LOGIC ===
local Flying = false
local FlySpeed = 50
local BodyGyro, BodyVel

local function FlyLogic()
    if not Flying then return end

    local Char = LocalPlayer.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") or not Char:FindFirstChild("Humanoid") then return end
    
    local Root = Char.HumanoidRootPart
    local Humanoid = Char.Humanoid
    
    -- Ensure not sitting
    if Humanoid.Sit then Humanoid.Sit = false end
    
    -- 1. Create BodyMovers if missing
    local bg = Root:FindFirstChild("FlyGyro")
    if not bg then
        bg = Instance.new("BodyGyro")
        bg.Name = "FlyGyro"
        bg.P = 9e4
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.CFrame = Root.CFrame
        bg.Parent = Root
    end
    
    local bv = Root:FindFirstChild("FlyVel")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVel"
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.P = 10000
        bv.Parent = Root
    end
    
    Humanoid.PlatformStand = true 

    -- 2. Update Movement
    local MoveDirection = Vector3.new(0, 0, 0)
    local CamCFrame = Camera.CFrame

    -- Check for input (ignore if typing in chat)
    if not UserInputService:GetFocusedTextBox() then
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            MoveDirection = MoveDirection + CamCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            MoveDirection = MoveDirection - CamCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            MoveDirection = MoveDirection - CamCFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            MoveDirection = MoveDirection + CamCFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            MoveDirection = MoveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            MoveDirection = MoveDirection - Vector3.new(0, 1, 0)
        end
    end

    bg.CFrame = CamCFrame
    
    -- Apply Speed
    if MoveDirection.Magnitude > 0 then
        -- Normalize direction to prevent faster diagonal movement, roughly
        bv.Velocity = MoveDirection.Unit * FlySpeed
    else
        bv.Velocity = Vector3.new(0, 0, 0)
    end
end

RunService.RenderStepped:Connect(FlyLogic)

function Fly.ToggleFly(state)
    Flying = state
    
    if not state then
        -- Force immediate cleanup
        local Char = LocalPlayer.Character
        if Char and Char:FindFirstChild("HumanoidRootPart") then
            local Root = Char.HumanoidRootPart
            if Root:FindFirstChild("FlyGyro") then Root.FlyGyro:Destroy() end
            if Root:FindFirstChild("FlyVel") then Root.FlyVel:Destroy() end
        end
        if Char and Char:FindFirstChild("Humanoid") then
             Char.Humanoid.PlatformStand = false
        end
    end
end

function Fly.SetFlySpeed(speed)
    FlySpeed = speed
end

return Fly
