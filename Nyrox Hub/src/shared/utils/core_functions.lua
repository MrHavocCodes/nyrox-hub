-- Shared Core Functions
-- Diese Funktionen können in allen Spielen verwendet werden

local CoreFunctions = {}

-- ========================================
-- Services
-- ========================================
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- ========================================
-- Variables
-- ========================================
local LocalPlayer = Players.LocalPlayer

-- ========================================
-- CHARACTER FUNCTIONS
-- ========================================

function CoreFunctions.GetCharacter()
    return LocalPlayer.Character
end

function CoreFunctions.GetHumanoidRootPart()
    local char = CoreFunctions.GetCharacter()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

function CoreFunctions.GetHumanoid()
    local char = CoreFunctions.GetCharacter()
    if char then
        return char:FindFirstChild("Humanoid")
    end
    return nil
end

function CoreFunctions.IsAlive()
    local char = CoreFunctions.GetCharacter()
    if not char then return false end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    return humanoid.Health > 0
end

function CoreFunctions.WaitForCharacter()
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    return LocalPlayer.Character
end

-- ========================================
-- MOVEMENT FUNCTIONS
-- ========================================

-- Noclip
local NoclipConnection = nil

function CoreFunctions.ToggleNoclip(state)
    if state then
        getgenv().Noclip = true
        if NoclipConnection then return end
        
        NoclipConnection = RunService.Stepped:Connect(function()
            if not getgenv().Noclip then
                if NoclipConnection then
                    NoclipConnection:Disconnect()
                    NoclipConnection = nil
                end
                return
            end
            
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        getgenv().Noclip = false
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
    end
end

-- WalkSpeed
function CoreFunctions.SetWalkSpeed(speed)
    local humanoid = CoreFunctions.GetHumanoid()
    if humanoid then
        humanoid.WalkSpeed = speed
    end
end

-- Tween zu Position
function CoreFunctions.TweenToPosition(position, duration, callback)
    local hrp = CoreFunctions.GetHumanoidRootPart()
    if not hrp then
        warn("CoreFunctions: HumanoidRootPart nicht gefunden")
        return
    end
    
    duration = duration or 2
    
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(hrp, tweenInfo, {
        CFrame = CFrame.new(position)
    })
    
    tween:Play()
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    return tween
end

-- Instant Teleport
function CoreFunctions.InstantTeleport(position)
    local hrp = CoreFunctions.GetHumanoidRootPart()
    if hrp then
        hrp.CFrame = CFrame.new(position)
    end
end

-- ========================================
-- FIND FUNCTIONS
-- ========================================

function CoreFunctions.FindNearest(objectName, maxDistance, parent)
    parent = parent or Workspace
    maxDistance = maxDistance or math.huge
    
    local hrp = CoreFunctions.GetHumanoidRootPart()
    if not hrp then return nil end
    
    local nearestObject = nil
    local nearestDistance = maxDistance
    
    for _, obj in pairs(parent:GetDescendants()) do
        if obj.Name == objectName and obj:IsA("BasePart") then
            local distance = (obj.Position - hrp.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestObject = obj
            end
        end
    end
    
    return nearestObject
end

function CoreFunctions.FindAll(objectName, parent)
    parent = parent or Workspace
    local objects = {}
    
    for _, obj in pairs(parent:GetDescendants()) do
        if obj.Name == objectName then
            table.insert(objects, obj)
        end
    end
    
    return objects
end

function CoreFunctions.GetDistance(object)
    local hrp = CoreFunctions.GetHumanoidRootPart()
    if not hrp or not object then return math.huge end
    
    local objectPos = object.Position or object
    return (hrp.Position - objectPos).Magnitude
end

function CoreFunctions.IsInRadius(position, radius)
    local distance = CoreFunctions.GetDistance(position)
    return distance <= radius
end

-- ========================================
-- ESP FUNCTIONS
-- ========================================

local ESPObjects = {}

function CoreFunctions.CreateESP(object, config)
    if not object then return nil end
    
    config = config or {}
    local name = config.Name or object.Name
    local color = config.Color or Color3.fromRGB(255, 255, 255)
    local showDistance = config.ShowDistance or false
    local showName = config.ShowName or true
    
    -- BillboardGui erstellen
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. name
    billboard.Adornee = object
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = object
    
    -- TextLabel
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextSize = 18
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextScaled = false
    textLabel.Parent = billboard
    
    -- Update Distance
    if showDistance then
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not object or not object.Parent then
                connection:Disconnect()
                return
            end
            
            local distance = CoreFunctions.GetDistance(object)
            local text = showName and name .. "\n" or ""
            text = text .. math.floor(distance) .. " studs"
            textLabel.Text = text
        end)
        
        table.insert(ESPObjects, {billboard = billboard, connection = connection})
    else
        textLabel.Text = name
        table.insert(ESPObjects, {billboard = billboard})
    end
    
    return billboard
end

function CoreFunctions.RemoveESP(billboard)
    for i, data in ipairs(ESPObjects) do
        if data.billboard == billboard then
            if data.connection then
                data.connection:Disconnect()
            end
            billboard:Destroy()
            table.remove(ESPObjects, i)
            break
        end
    end
end

function CoreFunctions.ClearAllESP()
    for _, data in ipairs(ESPObjects) do
        if data.connection then
            data.connection:Disconnect()
        end
        if data.billboard then
            data.billboard:Destroy()
        end
    end
    ESPObjects = {}
end

-- ========================================
-- COMBAT FUNCTIONS
-- ========================================

function CoreFunctions.GetNearestPlayer(teamCheck, maxDistance)
    maxDistance = maxDistance or math.huge
    teamCheck = teamCheck ~= false  -- Default true
    
    local hrp = CoreFunctions.GetHumanoidRootPart()
    if not hrp then return nil end
    
    local nearestPlayer = nil
    local nearestDistance = maxDistance
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Team Check
            if teamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            
            if player.Character then
                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    local distance = (targetHRP.Position - hrp.Position).Magnitude
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestPlayer = player
                    end
                end
            end
        end
    end
    
    return nearestPlayer
end

function CoreFunctions.LookAt(position)
    local hrp = CoreFunctions.GetHumanoidRootPart()
    if hrp then
        hrp.CFrame = CFrame.new(hrp.Position, position)
    end
end

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

function CoreFunctions.Notify(title, text, duration)
    duration = duration or 3
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration
    })
end

function CoreFunctions.SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("CoreFunctions SafeCall Error: " .. tostring(result))
    end
    return success, result
end

function CoreFunctions.Wait(seconds)
    local start = tick()
    while tick() - start < seconds do
        RunService.Heartbeat:Wait()
    end
end

-- ========================================
-- CLEANUP
-- ========================================

function CoreFunctions.Cleanup()
    CoreFunctions.ToggleNoclip(false)
    CoreFunctions.ClearAllESP()
    
    -- Reset WalkSpeed
    local humanoid = CoreFunctions.GetHumanoid()
    if humanoid then
        humanoid.WalkSpeed = 16
    end
end

return CoreFunctions
