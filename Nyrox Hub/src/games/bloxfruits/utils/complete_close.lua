local CloseHandler = {}
CloseHandler.ActiveConnections = {}
CloseHandler.RunningLoops = true

function CloseHandler.Register(connection)
    table.insert(CloseHandler.ActiveConnections, connection)
end

function CloseHandler.StopAll(guiObject)
    -- Set global stop flag
    getgenv().NyroxRunning = false
    CloseHandler.RunningLoops = false
    
    -- Disable all features
    getgenv().AutoFarm = false
    getgenv().AutoStats = false
    getgenv().ChestFarm = false
    getgenv().AutoKillPlayer = false
    getgenv().Aimbot = false
    getgenv().NoClip = false
    getgenv().InfStamina = false
    getgenv().InfSkyJump = false
    getgenv().PlayerESP = false
    getgenv().FruitESP = false
    getgenv().IslandESP = false
    getgenv().ChestESP = false
    getgenv().WalkOnWater = false
    getgenv().Fly = false
    
    -- Disconnect all connections
    for _, c in pairs(CloseHandler.ActiveConnections) do
        if c then c:Disconnect() end
    end
    CloseHandler.ActiveConnections = {}
    
    -- Restore player state
    local char = game:GetService("Players").LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, obj in ipairs(hrp:GetChildren()) do
                if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") then
                    obj:Destroy()
                end
            end
        end
    end
    
    -- Clean up workspace
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == "WaterPlatform" then
            obj:Destroy()
        end
    end
    
    -- Destroy UI
    if guiObject then
        guiObject:Destroy()
    end
end

return CloseHandler