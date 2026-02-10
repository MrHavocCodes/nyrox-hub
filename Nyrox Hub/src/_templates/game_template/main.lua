-- Template Main.lua für neue Spiele
-- Kopiere diese Datei und passe sie an dein Spiel an

local GameTemplate = {}

-- ========================================
-- IMPORTS
-- ========================================

-- Importiere gemeinsame Module
local CoreFunctions = getgenv().Import("src/shared/utils/core_functions.lua")
local ConfigSystem = getgenv().Import("src/shared/services/config_system.lua")
local UILib = getgenv().NyroxLib

-- ========================================
-- VARIABLES
-- ========================================

GameTemplate.GameName = "MeinSpiel"  -- ANPASSEN!
GameTemplate.Version = "1.0.0"
GameTemplate.Config = {}

-- Feature Toggles
local autoFarmEnabled = false
local antiAFKEnabled = false

-- ========================================
-- INITIALIZATION
-- ========================================

function GameTemplate.Init()
    print("========================================")
    print("Nyrox Hub - " .. GameTemplate.GameName)
    print("Version: " .. GameTemplate.Version)
    print("========================================")
    
    -- Warte auf Character
    CoreFunctions.WaitForCharacter()
    
    -- Lade Config
    GameTemplate.LoadConfig()
    
    -- Erstelle UI
    GameTemplate.CreateUI()
    
    -- Starte Features
    GameTemplate.StartFeatures()
    
    print(GameTemplate.GameName .. " erfolgreich geladen!")
end

-- ========================================
-- CONFIG SYSTEM
-- ========================================

function GameTemplate.LoadConfig()
    local config = ConfigSystem.Load(GameTemplate.GameName)
    if config then
        GameTemplate.Config = config
        print("Config geladen!")
    else
        GameTemplate.Config = ConfigSystem.CreateTemplate(GameTemplate.GameName)
        print("Neue Config erstellt")
    end
end

function GameTemplate.SaveConfig()
    GameTemplate.Config.Settings = {
        autoFarm = autoFarmEnabled,
        antiAFK = antiAFKEnabled
        -- Füge weitere Settings hinzu
    }
    
    ConfigSystem.Save(GameTemplate.GameName, GameTemplate.Config)
    CoreFunctions.Notify("Config", "Gespeichert!", 2)
end

-- ========================================
-- UI CREATION
-- ========================================

function GameTemplate.CreateUI()
    -- Erstelle Hauptfenster
    local Window = UILib:CreateWindow({
        Title = "Nyrox Hub - " .. GameTemplate.GameName,
        SubTitle = "v" .. GameTemplate.Version,
        OnClose = function()
            GameTemplate.Cleanup()
        end
    })
    
    -- ========================================
    -- TABS
    -- ========================================
    
    -- Main Tab
    local MainTab = Window:AddTab({
        Name = "Main",
        Icon = "🏠"
    })
    
    -- Farm Tab
    local FarmTab = Window:AddTab({
        Name = "Farm",
        Icon = "🌾"
    })
    
    -- Misc Tab
    local MiscTab = Window:AddTab({
        Name = "Misc",
        Icon = "🔧"
    })
    
    -- Settings Tab
    local SettingsTab = Window:AddTab({
        Name = "Settings",
        Icon = "⚙️"
    })
    
    -- ========================================
    -- MAIN TAB
    -- ========================================
    
    MainTab:AddSection({Name = "Information"})
    
    MainTab:AddLabel({
        Name = "Willkommen bei Nyrox Hub!",
        TextColor = Color3.fromRGB(255, 255, 255)
    })
    
    MainTab:AddLabel({
        Name = "Spiel: " .. GameTemplate.GameName,
        TextColor = Color3.fromRGB(200, 200, 200)
    })
    
    -- ========================================
    -- FARM TAB
    -- ========================================
    
    FarmTab:AddSection({Name = "Auto Farm"})
    
    FarmTab:AddToggle({
        Name = "Auto Farm",
        Description = "Aktiviert automatisches Farmen",
        Default = false,
        Callback = function(value)
            autoFarmEnabled = value
        end
    })
    
    -- Weitere Farm-Features hier hinzufügen
    
    -- ========================================
    -- MISC TAB
    -- ========================================
    
    MiscTab:AddSection({Name = "Player"})
    
    MiscTab:AddSlider({
        Name = "WalkSpeed",
        Description = "Ändere deine Laufgeschwindigkeit",
        Min = 16,
        Max = 200,
        Default = 16,
        Increment = 1,
        Callback = function(value)
            CoreFunctions.SetWalkSpeed(value)
        end
    })
    
    MiscTab:AddToggle({
        Name = "Noclip",
        Description = "Gehe durch Wände",
        Default = false,
        Callback = function(value)
            CoreFunctions.ToggleNoclip(value)
        end
    })
    
    MiscTab:AddSection({Name = "Anti AFK"})
    
    MiscTab:AddToggle({
        Name = "Anti AFK",
        Description = "Verhindert AFK-Kick",
        Default = false,
        Callback = function(value)
            antiAFKEnabled = value
        end
    })
    
    -- ========================================
    -- SETTINGS TAB
    -- ========================================
    
    SettingsTab:AddSection({Name = "Konfiguration"})
    
    SettingsTab:AddButton({
        Name = "Config Speichern",
        Description = "Speichert aktuelle Einstellungen",
        Callback = function()
            GameTemplate.SaveConfig()
        end
    })
    
    SettingsTab:AddButton({
        Name = "Config Laden",
        Description = "Lädt gespeicherte Einstellungen",
        Callback = function()
            GameTemplate.LoadConfig()
            CoreFunctions.Notify("Config", "Geladen!", 2)
        end
    })
    
    SettingsTab:AddSection({Name = "Script"})
    
    SettingsTab:AddButton({
        Name = "Script Beenden",
        Description = "Beendet das Script",
        Callback = function()
            GameTemplate.Cleanup()
        end
    })
    
    SettingsTab:AddSection({Name = "Credits"})
    
    SettingsTab:AddLabel({
        Name = "Erstellt von: Nyrox",
        TextColor = Color3.fromRGB(100, 200, 255)
    })
end

-- ========================================
-- FEATURES
-- ========================================

function GameTemplate.StartFeatures()
    -- Auto Farm Loop
    spawn(function()
        while true do
            wait(0.1)
            
            if autoFarmEnabled and CoreFunctions.IsAlive() then
                -- DEINE AUTO-FARM LOGIK HIER
                -- Beispiel:
                -- local target = CoreFunctions.FindNearest("Coin", 1000)
                -- if target then
                --     CoreFunctions.TweenToPosition(target.Position, 1)
                -- end
            end
        end
    end)
    
    -- Anti AFK
    spawn(function()
        while true do
            wait(60)
            
            if antiAFKEnabled then
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end
    end)
end

-- ========================================
-- CLEANUP
-- ========================================

function GameTemplate.Cleanup()
    -- Speichere Config
    GameTemplate.SaveConfig()
    
    -- Deaktiviere Features
    autoFarmEnabled = false
    antiAFKEnabled = false
    
    -- Cleanup Core Functions
    CoreFunctions.Cleanup()
    
    print(GameTemplate.GameName .. " beendet!")
end

-- ========================================
-- START
-- ========================================

GameTemplate.Init()

return GameTemplate
