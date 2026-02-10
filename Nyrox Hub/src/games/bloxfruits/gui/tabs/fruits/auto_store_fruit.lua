local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local LoopRunning = false

local function StoreFruitInInventory(fruitName)
    -- Try to store the fruit using the game's remote
    pcall(function()
        local args = {
            [1] = "StoreFruit",
            [2] = fruitName
        }
        ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
    end)
end

local function GetEquippedFruit()
    -- Check backpack and character for equipped fruit
    local backpack = LocalPlayer.Backpack
    local char = LocalPlayer.Character
    
    -- Check backpack
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name:find("Fruit") then
            return item.Name
        end
    end
    
    -- Check character (equipped)
    if char then
        for _, item in pairs(char:GetChildren()) do
            if item:IsA("Tool") and item.Name:find("Fruit") then
                return item.Name
            end
        end
    end
    
    return nil
end

local function AutoStoreLoop()
    if LoopRunning then return end
    LoopRunning = true
    
    spawn(function()
        while getgenv().AutoStoreFruit do
            local fruitName = GetEquippedFruit()
            
            if fruitName then
                StoreFruitInInventory(fruitName)
                
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Nyrox Hub - Auto Store",
                    Text = "Storing: " .. fruitName,
                    Duration = 3
                })
                
                task.wait(1) -- Wait a bit after storing
            end
            
            task.wait(0.5) -- Check every 0.5 seconds
        end
        
        LoopRunning = false
    end)
end

return {
    Toggle = function(val)
        getgenv().AutoStoreFruit = val
        if val then
            AutoStoreLoop()
        end
    end
}
