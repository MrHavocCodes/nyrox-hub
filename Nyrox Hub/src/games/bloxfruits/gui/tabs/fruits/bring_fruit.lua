local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local LoopRunning = false

local function BringLoop()
    if LoopRunning then return end
    LoopRunning = true
    
    spawn(function()
        while getgenv().BringFruit do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                
                for _, item in pairs(Workspace:GetChildren()) do
                    -- Check for fruit-like objects
                    if (item:IsA("Tool") or item:IsA("Model")) and (item.Name:find("Fruit") or item:FindFirstChild("Handle")) then
                        if item:FindFirstChild("Handle") then
                            local handle = item.Handle
                            
                            -- METHOD 1: FireTouchInterest (Best/Instant)
                            -- This interacts without moving the fruit, preventing server rubberbanding/despawn
                            if firetouchinterest then
                                firetouchinterest(hrp, handle, 0)
                                firetouchinterest(hrp, handle, 1)
                            
                            -- METHOD 2: Physical CFrame (Fallback)
                            -- Only works if you have network ownership or are close
                            else
                                pcall(function()
                                    handle.CanCollide = false
                                    handle.Anchored = false
                                    handle.CFrame = hrp.CFrame
                                    handle.Velocity = Vector3.new(0,0,0)
                                    handle.AssemblyLinearVelocity = Vector3.new(0,0,0)
                                end)
                            end
                        end
                    end
                end
            end
            -- Run fast to fight server replication if needed
            task.wait() 
        end
        LoopRunning = false
    end)
end

return {
    Toggle = function(val)
        getgenv().BringFruit = val
        if val then
            BringLoop()
        end
    end
}