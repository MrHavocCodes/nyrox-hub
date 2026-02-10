local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local AutoRollFruit = {}
local RollLoopRunning = false

-- ========================================
-- FRUIT RARITY CONFIGURATION
-- ========================================

local FruitRarities = {
    -- Common (Low-Tier)
    ["Bomb"] = "Common",
    ["Spike"] = "Common",
    ["Chop"] = "Common",
    ["Spring"] = "Common",
    ["Kilo"] = "Common",
    ["Smoke"] = "Common",
    ["Spin"] = "Common",
    
    -- Uncommon
    ["Falcon"] = "Uncommon",
    ["Ice"] = "Uncommon",
    ["Sand"] = "Uncommon",
    ["Dark"] = "Uncommon",
    ["Diamond"] = "Uncommon",
    ["Light"] = "Uncommon",
    ["Rubber"] = "Uncommon",
    ["Barrier"] = "Uncommon",
    
    -- Rare
    ["Magma"] = "Rare",
    ["Quake"] = "Rare",
    ["Buddha"] = "Rare",
    ["Love"] = "Rare",
    ["Spider"] = "Rare",
    ["Sound"] = "Rare",
    ["Phoenix"] = "Rare",
    ["Portal"] = "Rare",
    ["Rumble"] = "Rare",
    ["Pain"] = "Rare",
    ["Blizzard"] = "Rare",
    
    -- Legendary
    ["Gravity"] = "Legendary",
    ["Mammoth"] = "Legendary",
    ["T-Rex"] = "Legendary",
    ["Dough"] = "Legendary",
    ["Shadow"] = "Legendary",
    ["Venom"] = "Legendary",
    ["Control"] = "Legendary",
    ["Spirit"] = "Legendary",
    ["Dragon"] = "Legendary",
    ["Leopard"] = "Legendary",
    ["Kitsune"] = "Legendary",
}

local RarityOrder = {
    ["Common"] = 1,
    ["Uncommon"] = 2,
    ["Rare"] = 3,
    ["Legendary"] = 4
}

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

local function GetEnv()
    if type(getgenv) == "function" then return getgenv() end
    return shared
end

local env = GetEnv()

local function GetFruitRarity(fruitName)
    -- Clean fruit name (remove "Fruit" suffix if present)
    local cleanName = fruitName:gsub(" Fruit", ""):gsub("-Fruit", "")
    return FruitRarities[cleanName] or "Unknown"
end

local function SendNotification(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5
        })
    end)
end

local function GetPlayerGems()
    -- Try to get gems from player's data
    local gems = 0
    
    pcall(function()
        local PlayerData = LocalPlayer:FindFirstChild("Data")
        if PlayerData then
            local GemsValue = PlayerData:FindFirstChild("Gems") or PlayerData:FindFirstChild("Gem")
            if GemsValue then
                gems = GemsValue.Value
            end
        end
    end)
    
    return gems
end

-- ========================================
-- ROLL FUNCTION
-- ========================================

local function RollFruit()
    local success = false
    local rolledFruit = nil
    
    -- Try multiple remote paths (Blox Fruits uses different remotes)
    local remotePaths = {
        "Remotes.CommF_",
        "Remotes.CommE_",
        "Remotes.Franchise",
        "Remotes.Function",
        "Remotes.RF"
    }
    
    for _, path in ipairs(remotePaths) do
        pcall(function()
            local remote = ReplicatedStorage:FindFirstChild("Remotes")
            if remote then
                local func = remote:FindFirstChild("CommF_")
                if func and func:IsA("RemoteFunction") then
                    -- Try rolling with Gems (most common method)
                    local result = func:InvokeServer("Cousin", "Buy")
                    
                    if result then
                        success = true
                        -- Try to extract fruit name from result
                        if type(result) == "string" then
                            rolledFruit = result
                        end
                    end
                end
            end
        end)
        
        if success then break end
    end
    
    -- Alternative method: Direct Blox Fruits Dealer interaction
    if not success then
        pcall(function()
            local remote = ReplicatedStorage:FindFirstChild("Remotes")
            if remote then
                local func = remote:FindFirstChild("CommF_")
                if func then
                    -- Random Fruit purchase
                    func:InvokeServer("BuyRandomFruit")
                    success = true
                end
            end
        end)
    end
    
    return success, rolledFruit
end

-- ========================================
-- CHECK IF SHOULD STOP
-- ========================================

local function ShouldStopRolling(fruitName, rollCount)
    if not env.AutoRollFruit then return true end
    
    -- Check max rolls
    if env.AutoRollMaxRolls and rollCount >= env.AutoRollMaxRolls then
        SendNotification("Auto Roll", "Max rolls reached!", 5)
        return true
    end
    
    -- Check if we have enough gems
    local gems = GetPlayerGems()
    if gems < 50 then -- Assumes 50 gems per roll
        SendNotification("Auto Roll", "Not enough Gems!", 5)
        return true
    end
    
    if not fruitName then return false end
    
    -- Check for specific fruit name
    if env.AutoRollStopFruit and env.AutoRollStopFruit ~= "None" then
        if fruitName:find(env.AutoRollStopFruit) then
            SendNotification("Auto Roll", "Found target fruit: " .. fruitName, 10)
            return true
        end
    end
    
    -- Check for minimum rarity
    if env.AutoRollMinRarity and env.AutoRollMinRarity ~= "None" then
        local fruitRarity = GetFruitRarity(fruitName)
        local minRarityOrder = RarityOrder[env.AutoRollMinRarity] or 0
        local currentRarityOrder = RarityOrder[fruitRarity] or 0
        
        if currentRarityOrder >= minRarityOrder then
            SendNotification("Auto Roll", "Found " .. fruitRarity .. " fruit: " .. fruitName, 10)
            return true
        end
    end
    
    return false
end

-- ========================================
-- AUTO STORE ROLLED FRUIT
-- ========================================

local function StoreFruit()
    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("Remotes")
        if remote then
            local func = remote:FindFirstChild("CommF_")
            if func then
                -- Store current fruit in inventory
                func:InvokeServer("StoreFruit")
            end
        end
    end)
end

-- ========================================
-- MAIN ROLL LOOP
-- ========================================

function AutoRollFruit.StartLoop()
    if RollLoopRunning then return end
    RollLoopRunning = true
    
    task.spawn(function()
        local rollCount = 0
        local startGems = GetPlayerGems()
        
        SendNotification("Auto Roll", "Started rolling fruits!", 3)
        print("[AutoRoll] Starting auto roll fruit loop")
        
        while env.NyroxRunning and env.AutoRollFruit do
            -- Safety check
            if not LocalPlayer or not LocalPlayer.Parent then
                task.wait(1)
                continue
            end
            
            -- Check gems before rolling
            local currentGems = GetPlayerGems()
            if currentGems < 50 then
                SendNotification("Auto Roll", "Out of Gems! Rolled " .. rollCount .. " times", 5)
                break
            end
            
            -- Perform roll
            local success, fruitName = RollFruit()
            
            if success then
                rollCount = rollCount + 1
                
                -- Log roll
                if fruitName then
                    local rarity = GetFruitRarity(fruitName)
                    print(string.format("[AutoRoll] Roll #%d: %s (%s)", rollCount, fruitName, rarity))
                    
                    -- Show notification for rare+ fruits
                    if rarity == "Rare" or rarity == "Legendary" then
                        SendNotification("Auto Roll", "Rolled: " .. fruitName .. " (" .. rarity .. ")", 5)
                    end
                end
                
                -- Check if we should stop
                if ShouldStopRolling(fruitName, rollCount) then
                    -- Auto store if enabled
                    if env.AutoRollAutoStore then
                        task.wait(0.5)
                        StoreFruit()
                        SendNotification("Auto Roll", "Fruit stored!", 3)
                    end
                    break
                end
                
                -- Auto store each fruit if option is enabled
                if env.AutoRollStoreAll then
                    task.wait(0.5)
                    StoreFruit()
                end
                
                -- Progress update every 10 rolls
                if rollCount % 10 == 0 then
                    local gemsSpent = startGems - currentGems
                    print(string.format("[AutoRoll] Progress: %d rolls | Gems spent: %d", rollCount, gemsSpent))
                end
            else
                warn("[AutoRoll] Failed to roll fruit, retrying...")
            end
            
            -- Delay between rolls
            task.wait(env.AutoRollDelay or 1)
        end
        
        -- Final summary
        local finalGems = GetPlayerGems()
        local gemsSpent = startGems - finalGems
        local summary = string.format("Rolled %d times | Spent %d gems", rollCount, gemsSpent)
        
        SendNotification("Auto Roll", "Stopped! " .. summary, 10)
        print("[AutoRoll] Stopped: " .. summary)
        
        RollLoopRunning = false
        env.AutoRollFruit = false
    end)
end

function AutoRollFruit.StopLoop()
    env.AutoRollFruit = false
    RollLoopRunning = false
end

return AutoRollFruit
