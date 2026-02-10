-- Improved Main.lua
-- Entry point für beide Loader

local Main = {}

-- ========================================
-- CONFIGURATION
-- ========================================

Main.Version = "2.0.0"
Main.BaseUrl = "https://raw.githubusercontent.com/username/repo/main/"

-- ========================================
-- INIT FUNCTION
-- ========================================

function Main.Init()
    print("========================================")
    print("Nyrox Hub v" .. Main.Version)
    print("Initializing...")
    print("========================================")
    
    -- Warte bis Spiel geladen
    if not game:IsLoaded() then
        print("[Main] Waiting for game to load...")
        game.Loaded:Wait()
    end
    
    print("[Main] Game loaded!")
    
    -- Setup Import Function
    Main.SetupImport()
    
    -- Load Core Systems
    Main.LoadCore()
    
    -- Detect and Load Game
    Main.DetectAndLoadGame()
end

-- ========================================
-- IMPORT SETUP
-- ========================================

function Main.SetupImport()
    if getgenv().Import then
        print("[Main] Import function already exists")
        return
    end
    
    local function Import(path)
        local url = Main.BaseUrl .. path
        
        local success, content = pcall(function()
            return game:HttpGet(url, true)
        end)
        
        if not success or not content then
            warn("[Import] Failed to fetch: " .. path)
            return nil
        end
        
        local func, err = loadstring(content)
        if not func then
            warn("[Import] Failed to load: " .. path .. " - " .. tostring(err))
            return nil
        end
        
        local execSuccess, result = pcall(func)
        if not execSuccess then
            warn("[Import] Failed to execute: " .. path .. " - " .. tostring(result))
            return nil
        end
        
        return result
    end
    
    getgenv().Import = Import
    print("[Main] Import function created")
end

-- ========================================
-- LOAD CORE
-- ========================================

function Main.LoadCore()
    print("[Main] Loading core systems...")
    
    -- Load UI Library
    getgenv().NyroxLib = getgenv().Import("src/lib/ui_library.lua")
    if not getgenv().NyroxLib then
        error("[Main] Failed to load UI Library!")
    end
    print("[Main] ✓ UI Library loaded")
    
    -- Load Game Detector
    local GameDetector = getgenv().Import("src/core/game_detector.lua")
    if not GameDetector then
        error("[Main] Failed to load Game Detector!")
    end
    getgenv().GameDetector = GameDetector
    print("[Main] ✓ Game Detector loaded")
    
    -- Load Core Functions
    local CoreFunctions = getgenv().Import("src/shared/utils/core_functions.lua")
    if CoreFunctions then
        getgenv().CoreFunctions = CoreFunctions
        print("[Main] ✓ Core Functions loaded")
    end
    
    -- Load Config System
    local ConfigSystem = getgenv().Import("src/shared/services/config_system.lua")
    if ConfigSystem then
        getgenv().ConfigSystem = ConfigSystem
        print("[Main] ✓ Config System loaded")
    end
end

-- ========================================
-- GAME DETECTION
-- ========================================

function Main.DetectAndLoadGame()
    print("[Main] Detecting game...")
    print("[Main] PlaceId: " .. game.PlaceId)
    
    local gameInfo = getgenv().GameDetector.DetectGame()
    
    if not gameInfo then
        Main.ShowUnsupportedGameUI()
        return
    end
    
    print("[Main] ✓ Game detected: " .. gameInfo.DisplayName)
    print("[Main] Loading game script...")
    
    local gameScript = getgenv().Import(gameInfo.Script)
    
    if gameScript then
        print("[Main] ✓ Game script loaded!")
        getgenv().CurrentGame = gameInfo
    else
        error("[Main] Failed to load game script!")
    end
end

-- ========================================
-- UNSUPPORTED GAME UI
-- ========================================

function Main.ShowUnsupportedGameUI()
    warn("[Main] Game not supported!")
    warn("[Main] PlaceId: " .. game.PlaceId)
    
    if not getgenv().NyroxLib then 
        warn("[Main] UI Library not loaded!")
        return 
    end
    
    local success, Window = pcall(function()
        return getgenv().NyroxLib:CreateWindow({
            Title = "Nyrox Hub",
            SubTitle = "Spiel nicht unterstützt"
        })
    end)
    
    if not success or not Window then
        warn("[Main] Failed to create window: " .. tostring(Window))
        return
    end
    
    local InfoTab = Window:AddTab({Name = "Info"})
    
    -- Warnung Section
    InfoTab:AddSection({Name = "⚠️ Nicht Unterstützt"})
    
    InfoTab:AddLabel({
        Name = "Dieses Spiel wird nicht unterstützt!",
        TextColor = Color3.fromRGB(255, 150, 0)
    })
    
    InfoTab:AddLabel({
        Name = "PlaceId: " .. game.PlaceId,
        TextColor = Color3.fromRGB(150, 150, 150)
    })
    
    InfoTab:AddLabel({
        Name = " ",
        TextColor = Color3.fromRGB(200, 200, 200)
    })
    
    InfoTab:AddLabel({
        Name = "Du kannst den General Script laden,",
        TextColor = Color3.fromRGB(200, 200, 200)
    })
    
    InfoTab:AddLabel({
        Name = "der in jedem Spiel funktioniert!",
        TextColor = Color3.fromRGB(200, 200, 200)
    })
    
    -- Aktionen Section
    InfoTab:AddSection({Name = "Aktionen"})
    
    InfoTab:AddButton({
        Name = "Load General Script",
        Description = "Lädt Universal-Script mit Standard-Features",
        Callback = function()
            print("[Main] Loading General Script...")
            
            local loadSuccess, err = pcall(function()
                getgenv().Import("src/games/general/main.lua")
            end)
            
            if loadSuccess then
                print("[Main] ✓ General Script loaded!")
                
                -- Schließe Info-Fenster nach 1 Sekunde
                wait(1)
                for _, gui in pairs(game.CoreGui:GetChildren()) do
                    if gui.Name == "NyroxHub" then
                        gui:Destroy()
                        break
                    end
                end
            else
                warn("[Main] Failed to load General Script: " .. tostring(err))
            end
        end
    })
    
    InfoTab:AddButton({
        Name = "Join Discord",
        Description = "Trete unserem Discord bei für Support",
        Callback = function()
            local discordInvite = "https://discord.gg/yourcode"  -- ANPASSEN!
            
            local clipSuccess = pcall(function()
                setclipboard(discordInvite)
            end)
            
            if clipSuccess then
                if getgenv().CoreFunctions then
                    getgenv().CoreFunctions.Notify("Discord", "Link in Zwischenablage kopiert!", 3)
                else
                    print("[Discord] Link kopiert: " .. discordInvite)
                end
            else
                warn("[Discord] Clipboard nicht verfügbar")
                print("[Discord] Link: " .. discordInvite)
            end
        end
    })
    
    InfoTab:AddButton({
        Name = "Close Script",
        Description = "Schließt das Script",
        Callback = function()
            for _, gui in pairs(game.CoreGui:GetChildren()) do
                if gui.Name == "NyroxHub" then
                    gui:Destroy()
                end
            end
            print("[Main] Script geschlossen")
        end
    })
    
    -- Unterstützte Spiele Section
    InfoTab:AddSection({Name = "Unterstützte Spiele"})
    
    local games = getgenv().GameDetector.GetAllGames()
    if games then
        for _, gameData in ipairs(games) do
            InfoTab:AddLabel({
                Name = gameData.Icon .. " " .. gameData.DisplayName,
                TextColor = Color3.fromRGB(255, 255, 255)
            })
        end
    end
    
    -- Debug Section
    InfoTab:AddSection({Name = "Debug Info"})
    
    InfoTab:AddButton({
        Name = "Copy PlaceId",
        Description = "Kopiert PlaceId in Zwischenablage",
        Callback = function()
            local clipSuccess = pcall(function()
                setclipboard(tostring(game.PlaceId))
            end)
            
            if clipSuccess then
                print("[Debug] PlaceId kopiert: " .. game.PlaceId)
            else
                print("[Debug] PlaceId: " .. game.PlaceId)
            end
        end
    })
    
    print("[Main] Unsupported Game UI created successfully!")
end

-- ========================================
-- RUN
-- ========================================

function Main.run()
    local success, error = pcall(Main.Init)
    
    if not success then
        warn("========================================")
        warn("NYROX HUB - CRITICAL ERROR")
        warn("========================================")
        warn(error)
        warn("========================================")
    end
end

return Main
