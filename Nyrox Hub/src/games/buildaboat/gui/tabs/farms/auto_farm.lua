local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local AutoFarm = {}
local Farming = false

-- Constants
-- Try to find stages safely
local StagesFolder = Workspace:FindFirstChild("BoatStages") and Workspace.BoatStages:FindFirstChild("NormalStages")

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetRootPart()
    local Char = GetCharacter()
    return Char:WaitForChild("HumanoidRootPart", 5)
end

local function NoClip()
    if not Farming then return end
    local Char = LocalPlayer.Character
    if Char then
        for _, part in pairs(Char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- Global Noclip Connection
local NoclipConnection = nil

local function TweenCharacter(targetCFrame, speed)
    if not Farming then return end
    local Root = GetRootPart()
    if not Root then return end

    local distance = (Root.Position - targetCFrame.Position).Magnitude
    local duration = distance / speed

    local Info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local Tween = TweenService:Create(Root, Info, {CFrame = targetCFrame})
    Tween:Play()
    
    -- Wait loop with cancellation check
    while Tween.PlaybackState == Enum.PlaybackState.Playing do
        if not Farming then
            Tween:Cancel()
            break
        end
        task.wait()
    end
end

local function RunFarm()
    while Farming and getgenv().NyroxRunning do
        local success, err = pcall(function()
            local Root = GetRootPart()
            if not Root then return end
            
            local Humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if Humanoid then
                Humanoid.Sit = false -- Unsit before flying
            end

            local startTime = tick()
            while tick() - startTime < 0.5 do
                if not Farming then return end
                task.wait()
            end

            if not StagesFolder then
                warn("Stagesfolder nil")
                return 
            end

            -- Anti-Gravity / Float
            local BodyVel = Instance.new("BodyVelocity")
            BodyVel.Name = "FlyVelocity"
            BodyVel.Parent = Root
            BodyVel.Velocity = Vector3.new(0, 0, 0)
            BodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9) -- Very high force
            
            -- Constants tracking removal
            task.spawn(function()
                while BodyVel.Parent do
                    if not Farming then
                        BodyVel:Destroy()
                        break
                    end
                    task.wait(0.1)
                end
            end)

            -- Iterate Stages 1 to 10
            for i = 1, 10 do
                if not Farming then break end
                local StageName = "CaveStage" .. i
                local StageModel = StagesFolder:FindFirstChild(StageName)
                
                -- Support varied naming or structure
                if StageModel and StageModel:FindFirstChild("DarknessPart") then
                    -- Fly to the black wall
                    -- Check if character still exists
                    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then break end

                    TweenCharacter(StageModel.DarknessPart.CFrame, 350) 
                    
                    if not Farming then break end -- Exit immediately if stopped during tween
                    task.wait(0.1) 
                end
            end
            
            -- Finally go to TheEnd
            if Farming then
                local EndZone = StagesFolder:FindFirstChild("TheEnd")
                if EndZone and EndZone:FindFirstChild("GoldenChest") and EndZone.GoldenChest:FindFirstChild("Trigger") then
                     if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        TweenCharacter(EndZone.GoldenChest.Trigger.CFrame, 350)
                     end
                end
            end
            
            -- Remove fly velocity
            if BodyVel and BodyVel.Parent then BodyVel:Destroy() end
            
            if not Farming then return end -- Exit if stopped

            -- Wait for claim
            task.wait(0.5) -- Fast claim check
            if not Farming then return end
            
            -- Reset Character
            local Char = LocalPlayer.Character
            if Char and Char:FindFirstChild("Humanoid") then
                 Char.Humanoid.Health = 0
            end
            
            -- Wait for respawn safely
            local NewChar = LocalPlayer.CharacterAdded:Wait()
            local NewRoot = NewChar:WaitForChild("HumanoidRootPart", 10)
            task.wait(2) -- Wait for load after respawn
        end)

        if not success then
            warn("AutoFarm Error: " .. tostring(err))
            task.wait(1)
        end
    end
end

function AutoFarm.ToggleAutoFarm(state)
    Farming = state
    if state then
        -- Enable Persistent Noclip
        if NoclipConnection then NoclipConnection:Disconnect() end
        NoclipConnection = RunService.Stepped:Connect(NoClip)
        
        task.spawn(RunFarm)
    else
        -- Disable Noclip
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
    end
end

return AutoFarm
