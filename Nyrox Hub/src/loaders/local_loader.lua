-- Improved Local Loader
-- Für lokale Entwicklung

print("Nyrox Hub Load Started...")

-- Warte bis Spiel geladen ist
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ========================================
-- SETUP IMPORT FUNCTION
-- ========================================

local BASE_PATH = "c:/Users/lukeb/OneDrive/Own Scrip/"

local function CreateImportFunction()
    local function Import(path)
        local fullPath = BASE_PATH .. path
        -- print("[Import] Loading: " .. fullPath)
        
        -- Versuche lokale Datei zu laden
        local success, result = pcall(function()
            return loadfile(fullPath)()
        end)
        
        if success and result then
            -- print("[Import] ✓ Loaded: " .. path)
            return result
        else
            warn("[Import] ✗ Failed to load: " .. path)
            warn("[Import] Error: " .. tostring(result))
            return nil
        end
    end
    
    return Import
end

-- Setze globale Import-Funktion
getgenv().Import = CreateImportFunction()

-- ========================================
-- LOAD UI LIBRARY
-- ========================================

print("[Loader] Loading UI Library...")
getgenv().NyroxLib = getgenv().Import("src/lib/ui_library.lua")

if not getgenv().NyroxLib then
    error("[Loader] ✗ Failed to load UI Library!")
end

print("[Loader] ✓ UI Library loaded")

-- ========================================
-- LOAD CORE MODULES
-- ========================================

print("[Loader] Loading Core Modules...")

local GameDetector = getgenv().Import("src/core/game_detector.lua")
if not GameDetector then
    error("[Loader] ✗ Failed to load Game Detector!")
end
getgenv().GameDetector = GameDetector

-- Load Core Functions
local CoreFunctions = getgenv().Import("src/shared/utils/core_functions.lua")
if CoreFunctions then
    getgenv().CoreFunctions = CoreFunctions
    print("[Loader] ✓ Core Functions loaded")
end

-- Load Config System
local ConfigSystem = getgenv().Import("src/shared/services/config_system.lua")
if ConfigSystem then
    getgenv().ConfigSystem = ConfigSystem
    print("[Loader] ✓ Config System loaded")
end

print("[Loader] ✓ Core Modules loaded")

-- ========================================
-- DETECT GAME
-- ========================================

print("[Loader] Detecting game...")
print("[Loader] PlaceId: " .. game.PlaceId)

local gameInfo = GameDetector.DetectGame()

if not gameInfo then
    warn("[Loader] ✗ Spiel wird nicht unterstützt!")
    warn("[Loader] PlaceId: " .. game.PlaceId)
    
    -- Zeige GUI mit 3 Buttons
    if getgenv().NyroxLib then
        local Window = getgenv().NyroxLib:CreateWindow({
            Title = "Nyrox Hub",
            SubTitle = "Spiel nicht unterstützt"
        })
        
        local InfoTab = Window:AddTab({Name = "Info"})
        
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
        
        InfoTab:AddSection({Name = "Aktionen"})
        
        InfoTab:AddButton({
            Name = "Load General Script",
            Description = "Lädt Universal-Script mit Standard-Features",
            Callback = function()
                print("[Loader] Loading General Script...")
                local success = pcall(function()
                    getgenv().Import("src/games/general/main.lua")
                end)
                
                if success then
                    wait(1)
                    for _, gui in pairs(game.CoreGui:GetChildren()) do
                        if gui.Name == "NyroxHub" then
                            gui:Destroy()
                            break
                        end
                    end
                end
            end
        })
        
        InfoTab:AddButton({
            Name = "Join Discord",
            Description = "Trete unserem Discord bei",
            Callback = function()
                local discordInvite = "https://discord.gg/yourcode"
                pcall(function() setclipboard(discordInvite) end)
                print("[Discord] Link: " .. discordInvite)
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
            end
        })
        
        InfoTab:AddSection({Name = "Unterstützte Spiele"})
        
        local games = GameDetector.GetAllGames()
        for _, gameData in ipairs(games) do
            InfoTab:AddLabel({
                Name = gameData.Icon .. " " .. gameData.DisplayName,
                TextColor = Color3.fromRGB(255, 255, 255)
            })
        end
    end
    
    return
end

print("[Loader] ✓ Spiel erkannt: " .. gameInfo.DisplayName .. " " .. gameInfo.Icon)

-- ========================================
-- LOAD GAME SCRIPT
-- ========================================

print("[Loader] Loading game script...")
print("[Loader] Path: " .. gameInfo.Script)

local gameScript = getgenv().Import(gameInfo.Script)

if not gameScript then
    error("[Loader] ✗ Failed to load game script!")
end

print("[Loader] ✓ Game script loaded successfully!")
print("========================================")
print("Nyrox Hub - Ready!")
print("Spiel: " .. gameInfo.DisplayName)
print("========================================")
