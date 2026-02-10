local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Reusing the robust Tween logic from islands.lua (Simplified for local use)
-- This ensures we use the same high-speed bypass logic
local ActiveTween = nil
local ActiveBodyVelocity = nil
local ActiveNoclip = nil

local function StopTween()
    if ActiveTween then ActiveTween:Cancel() ActiveTween = nil end
    if ActiveBodyVelocity then ActiveBodyVelocity:Destroy() ActiveBodyVelocity = nil end
    if ActiveNoclip then ActiveNoclip:Disconnect() ActiveNoclip = nil end
    
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.PlatformStand = false
            char.Humanoid.Sit = false
        end
    end
end

local function TweenTo(targetPos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end
    
    StopTween()
    
    local hrp = char.HumanoidRootPart
    local humanoid = char.Humanoid
    
    humanoid.Sit = false
    humanoid.PlatformStand = true
    
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(1, 1, 1) * math.huge
    bv.Parent = hrp
    ActiveBodyVelocity = bv
    
    -- INSANE BYPASS SETTINGS
    local speed = 1200 -- Force high speed for fruit grabbing
    
    local dist = (hrp.Position - targetPos).Magnitude
    local time = dist / speed
    
    -- Insane Bypass Loop
    ActiveNoclip = RunService.RenderStepped:Connect(function()
        if not char or not char.Parent then StopTween() return end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
        -- Aggressive Physics Bypass
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        humanoid.PlatformStand = true
    end)
    
    local info = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, info, {CFrame = CFrame.new(targetPos)})
    ActiveTween = tween
    
    tween.Completed:Connect(function()
        StopTween()
    end)
    
    tween:Play()
    
    -- Wait for completion or finding object
    return tween
end

local function GetFruits()
    local FoundFruits = {}
    
    -- Scan Workspace for Dropped Fruits
    -- Usually they are Handles inside a Model or Tool
    for _, item in pairs(Workspace:GetChildren()) do
        if (item:IsA("Tool") or item:IsA("Model")) and (item.Name:find("Fruit") or item:FindFirstChild("Handle")) then
             -- Strict Filter: Must interactable
             if item:FindFirstChild("Handle") then
                 table.insert(FoundFruits, item)
             end
        end
    end
    
    return FoundFruits
end

local LoopRunning = false
local SniperLoopRunning = false

local function FarmLoop()
    if LoopRunning then return end
    LoopRunning = true
    
    spawn(function()
        while getgenv().GrabFruit do
            local fruits = GetFruits()
            
            if #fruits > 0 then
                for _, fruit in pairs(fruits) do
                    if not getgenv().GrabFruit then break end
                    
                    if fruit and fruit.Parent and fruit:FindFirstChild("Handle") then
                        local handle = fruit.Handle
                        
                        -- Tween to Fruit
                        TweenTo(handle.Position)
                        
                        -- Wait until close
                        local char = LocalPlayer.Character
                        local startTime = tick()
                        while char and (char.HumanoidRootPart.Position - handle.Position).Magnitude > 10 do
                            task.wait(0.1)
                            if not fruit.Parent then break end -- Fruit gone (picked up?)
                            if not getgenv().GrabFruit then break end
                            if tick() - startTime > 20 then break end -- Security Timeout
                        end
                        
                        StopTween()
                        
                        -- Pickup Logic
                        if char and char.PrimaryPart and fruit.Parent then
                            char:SetPrimaryPartCFrame(handle.CFrame)
                            task.wait(0.5)
                        end
                    end
                end
            else
                -- Wait before next scan if no fruits found
                task.wait(2)
            end
            task.wait(1)
        end
        LoopRunning = false
        StopTween()
    end)
end

local function SniperLoop()
    if SniperLoopRunning then return end
    SniperLoopRunning = true
    
    spawn(function()
        while getgenv().FruitSniper do
            local target = getgenv().FruitSniperTarget or "None"
            
            if target ~= "None" then
                local fruits = GetFruits()
                local foundTarget = false
                
                for _, fruit in pairs(fruits) do
                    if not getgenv().FruitSniper then break end
                    
                    local fruitName = fruit.Name:gsub(" Fruit", ""):gsub("-Fruit", "")
                    
                    if fruitName == target and fruit:FindFirstChild("Handle") then
                        foundTarget = true
                        
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Nyrox Hub - Fruit Sniper",
                            Text = "Target found: " .. target .. "! Teleporting...",
                            Duration = 5
                        })
                        
                        -- Instant tween to target fruit
                        local handle = fruit.Handle
                        TweenTo(handle.Position)
                        
                        -- Wait for arrival
                        local char = LocalPlayer.Character
                        local startTime = tick()
                        while char and (char.HumanoidRootPart.Position - handle.Position).Magnitude > 10 do
                            task.wait(0.1)
                            if not fruit.Parent then break end
                            if not getgenv().FruitSniper then break end
                            if tick() - startTime > 20 then break end
                        end
                        
                        StopTween()
                        
                        -- Grab fruit
                        if char and char.PrimaryPart and fruit.Parent then
                            for i = 1, 5 do
                                char:SetPrimaryPartCFrame(handle.CFrame)
                                task.wait(0.1)
                            end
                        end
                        
                        break
                    end
                end
                
                if not foundTarget then
                    -- Target not found
                    if getgenv().FruitSniperHopServer then
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Nyrox Hub - Fruit Sniper",
                            Text = target .. " not found. Hopping server...",
                            Duration = 3
                        })
                        
                        task.wait(2)
                        
                        -- Server hop logic
                        local TeleportService = game:GetService("TeleportService")
                        local HttpService = game:GetService("HttpService")
                        
                        pcall(function()
                            local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                            
                            if servers and servers.data then
                                for _, server in pairs(servers.data) do
                                    if server.id ~= game.JobId and server.playing < server.maxPlayers then
                                        TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                                        break
                                    end
                                end
                            end
                        end)
                    else
                        task.wait(5)
                    end
                else
                    task.wait(2)
                end
            else
                task.wait(2)
            end
        end
        SniperLoopRunning = false
        StopTween()
    end)
end

return {
    StartFarm = function()
        getgenv().GrabFruit = true
        FarmLoop()
    end,
    StopFarm = function()
        getgenv().GrabFruit = false
    end,
    StartSniper = function()
        getgenv().FruitSniper = true
        SniperLoop()
    end,
    StopSniper = function()
        getgenv().FruitSniper = false
    end
}
