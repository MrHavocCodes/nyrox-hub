local Workspace = game:GetService("Workspace")
local WaterGod = {}
local Enabled = false
local Connection = nil

local function DisableWater(instance)
    if instance:IsA("BasePart") then
        local name = instance.Name:lower()
        if name:find("water") or name == "sea" or name == "ocean" or name == "river" then
            instance.CanTouch = false
        end
    end
end

local function EnableWater(instance)
     if instance:IsA("BasePart") then
        local name = instance.Name:lower()
        if name:find("water") or name == "sea" or name == "ocean" or name == "river" then
            instance.CanTouch = true
        end
    end
end

function WaterGod.Toggle(state)
    Enabled = state
    if state then
        -- Apply to existing
        for _, v in pairs(Workspace:GetDescendants()) do
            DisableWater(v)
        end
        
        -- Watch for new (e.g. stage loading)
        if Connection then Connection:Disconnect() end
        Connection = Workspace.DescendantAdded:Connect(DisableWater)
        
        -- Periodic check (sometimes needed for streamed parts)
        task.spawn(function()
            while Enabled and getgenv().NyroxRunning do
                for _, v in pairs(Workspace:GetDescendants()) do
                     DisableWater(v)
                end
                task.wait(5)
            end
        end)
    else
        if Connection then 
             Connection:Disconnect() 
             Connection = nil
        end
        
        -- Revert existing
        for _, v in pairs(Workspace:GetDescendants()) do
            EnableWater(v)
        end
    end
end

return WaterGod
