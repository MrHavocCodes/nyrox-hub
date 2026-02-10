-- General Script - Main Window
-- Creates the main window and loads all tabs

return function()
    local UILib = getgenv().NyroxLib
    
    print("[General GUI] Creating main window...")
    
    -- Create main window
    local Window = UILib:CreateWindow({
        Title = "Nyrox Hub - General Script",
        SubTitle = "v1.0.0 - Universal",
        OnClose = function()
            if getgenv().CoreFunctions then
                getgenv().CoreFunctions.Cleanup()
            end
        end
    })
    
    print("[General GUI] ✓ Window created")
    
    -- ========================================
    -- CREATE TABS
    -- ========================================
    
    print("[General GUI] Creating tabs...")
    
    local PlayerTab = Window:AddTab({Name = "Player"})
    print("[General GUI] ✓ Player tab created")
    
    local CombatTab = Window:AddTab({Name = "Combat"})
    print("[General GUI] ✓ Combat tab created")
    
    local MovementTab = Window:AddTab({Name = "Movement"})
    print("[General GUI] ✓ Movement tab created")
    
    local VisualsTab = Window:AddTab({Name = "Visuals"})
    print("[General GUI] ✓ Visuals tab created")
    
    local SettingsTab = Window:AddTab({Name = "Settings"})
    print("[General GUI] ✓ Settings tab created")
    
    -- ========================================
    -- LOAD TAB FEATURES
    -- ========================================
    
    print("[General GUI] Loading tab features...")
    
    -- Load Player Tab Features
    local success, err = pcall(function()
        getgenv().Import("src/games/general/gui/tabs/player/character_stats.lua")(PlayerTab)
        print("[General GUI] ✓ Character stats loaded")
    end)
    if not success then
        warn("[General GUI] ✗ Failed to load character_stats: " .. tostring(err))
    end
    
    success, err = pcall(function()
        getgenv().Import("src/games/general/gui/tabs/player/health_stamina.lua")(PlayerTab)
        print("[General GUI] ✓ Health stamina loaded")
    end)
    if not success then
        warn("[General GUI] ✗ Failed to load health_stamina: " .. tostring(err))
    end
    
    -- Load Combat Tab Features
    success, err = pcall(function()
        getgenv().Import("src/games/general/gui/tabs/combat/aimbot.lua")(CombatTab)
        print("[General GUI] ✓ Aimbot loaded")
    end)
    if not success then
        warn("[General GUI] ✗ Failed to load aimbot: " .. tostring(err))
    end
    
    -- Load Movement Tab Features
    success, err = pcall(function()
        getgenv().Import("src/games/general/gui/tabs/movement/movement_features.lua")(MovementTab)
        print("[General GUI] ✓ Movement features loaded")
    end)
    if not success then
        warn("[General GUI] ✗ Failed to load movement_features: " .. tostring(err))
    end
    
    success, err = pcall(function()
        getgenv().Import("src/games/general/gui/tabs/movement/teleport.lua")(MovementTab)
        print("[General GUI] ✓ Teleport loaded")
    end)
    if not success then
        warn("[General GUI] ✗ Failed to load teleport: " .. tostring(err))
    end
    
    -- Load Visuals Tab Features
    success, err = pcall(function()
        getgenv().Import("src/games/general/gui/tabs/visuals/esp_options.lua")(VisualsTab)
        print("[General GUI] ✓ ESP options loaded")
    end)
    if not success then
        warn("[General GUI] ✗ Failed to load esp_options: " .. tostring(err))
    end
    
    success, err = pcall(function()
        getgenv().Import("src/games/general/gui/tabs/visuals/graphics.lua")(VisualsTab)
        print("[General GUI] ✓ Graphics loaded")
    end)
    if not success then
        warn("[General GUI] ✗ Failed to load graphics: " .. tostring(err))
    end
    
    -- Load Settings Tab Features
    success, err = pcall(function()
        getgenv().Import("src/games/general/gui/tabs/settings/anti_afk.lua")(SettingsTab)
        print("[General GUI] ✓ Anti AFK loaded")
    end)
    if not success then
        warn("[General GUI] ✗ Failed to load anti_afk: " .. tostring(err))
    end
    
    success, err = pcall(function()
        getgenv().Import("src/games/general/gui/tabs/settings/script_control.lua")(SettingsTab)
        print("[General GUI] ✓ Script control loaded")
    end)
    if not success then
        warn("[General GUI] ✗ Failed to load script_control: " .. tostring(err))
    end
    
    success, err = pcall(function()
        getgenv().Import("src/games/general/gui/tabs/settings/credits.lua")(SettingsTab)
        print("[General GUI] ✓ Credits loaded")
    end)
    if not success then
        warn("[General GUI] ✗ Failed to load credits: " .. tostring(err))
    end
    
    print("[General GUI] ✓ All features loaded successfully!")
    
    return Window
end