local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function TryReset(targetPos)
    if not getgenv().BypassTP then return end
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        -- Notify user
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Nyrox Hub",
            Text = "Arrived! Holding position...",
            Duration = 2
        })
        
        -- SNAP & HOLD: Anti-Rubberband Loop
        -- We hold the position for 1 second to force the server to accept the new location
        if targetPos then
            local startTime = os.clock()
            local holdConnection
            
            -- Constants loop to fight server correction
            holdConnection = RunService.RenderStepped:Connect(function()
                if char and char.PrimaryPart then
                    char:SetPrimaryPartCFrame(CFrame.new(targetPos))
                    -- Freeze physics completely
                    char.PrimaryPart.Velocity = Vector3.new(0,0,0) 
                    char.PrimaryPart.RotVelocity = Vector3.new(0,0,0)
                    char.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    char.PrimaryPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
                end
                
                -- Safety disconnect
                if os.clock() - startTime > 1.5 then 
                    if holdConnection then holdConnection:Disconnect() end 
                end
            end)
            
            -- Wait 1 second as requested
            task.wait(1)
            
            if holdConnection then holdConnection:Disconnect() end
        else
            task.wait(1) 
        end
        
        -- Reset
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.Health = 0
        end
    end
end

return {
    OnArrival = TryReset
}
