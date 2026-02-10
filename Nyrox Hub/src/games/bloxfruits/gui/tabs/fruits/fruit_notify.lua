local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local NotifiedFruits = {}

local function Notify(fruitName, position)
    if not getgenv().FruitNotify then return end
    
    -- Avoid duplicate notifications
    local key = fruitName .. tostring(position)
    if NotifiedFruits[key] then return end
    NotifiedFruits[key] = true
    
    -- Clean up old notifications after 30 seconds
    task.delay(30, function()
        NotifiedFruits[key] = nil
    end)
    
    StarterGui:SetCore("SendNotification", {
        Title = "🍎 Nyrox Hub - Fruit Spawned!",
        Text = fruitName .. " detected in the world!",
        Duration = 10
    })
    
    warn("[Fruit Notifier] " .. fruitName .. " spawned at: " .. tostring(position))
end

local function CheckObject(obj)
    if not obj then return end
    
    task.wait(0.1) -- Wait for properties to load
    
    local name = obj.Name
    
    -- Blox Fruits spawn as Tools or Models with "Fruit" in the name
    if (obj:IsA("Tool") or obj:IsA("Model")) and name:find("Fruit") then
        -- Exclude NPCs and Dealers
        if not name:find("Dealer") and not name:find("Gacha") then
            -- Check if it has a Handle (physical fruit)
            if obj:FindFirstChild("Handle") then
                local position = obj.Handle.Position
                Notify(name, position)
            end
        end
    end
end

-- Monitor Workspace for new fruits
Workspace.ChildAdded:Connect(CheckObject)

-- Check existing fruits on load
for _, obj in pairs(Workspace:GetChildren()) do
    CheckObject(obj)
end

return {
    -- Runs automatically when loaded
}

