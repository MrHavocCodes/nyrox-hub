-- Improved Hosted Loader
-- Für Production (GitHub)

print("========================================")
print("Nyrox Hub - Hosted Loader")
print("========================================")

-- Warte bis Spiel geladen ist
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ========================================
-- CONFIGURATION
-- ========================================

local Config = {
    BaseUrl = "https://raw.githubusercontent.com/username/repo/main/",
    TimeoutSeconds = 10,
    RetryAttempts = 3
}

-- ========================================
-- SETUP IMPORT FUNCTION
-- ========================================

local function CreateImportFunction()
    local HttpService = game:GetService("HttpService")
    
    local function Import(path)
        print("[Import] Loading: " .. path)
        
        local url = Config.BaseUrl .. path
        local attempts = 0
        
        while attempts < Config.RetryAttempts do
            attempts = attempts + 1
            
            -- Versuche HTTP Request
            local success, content = pcall(function()
                return game:HttpGet(url, true)
            end)
            
            if success and content then
                -- Versuche Code zu laden
                local loadSuccess, loadResult = pcall(function()
                    return loadstring(content)
                end)
                
                if loadSuccess and loadResult then
                    -- Versuche Code auszuführen
                    local execSuccess, execResult = pcall(loadResult)
                    
                    if execSuccess then
                        print("[Import] ✓ Loaded: " .. path)
                        return execResult
                    else
                        warn("[Import] Execution Error: " .. tostring(execResult))
                    end
                else
                    warn("[Import] Load Error: " .. tostring(loadResult))
                end
            else
                warn("[Import] HTTP Error (Versuch " .. attempts .. "/" .. Config.RetryAttempts .. "): " .. tostring(content))
            end
            
            if attempts < Config.RetryAttempts then
                print("[Import] Retrying in 2 seconds...")
                wait(2)
            end
        end
        
        warn("[Import] ✗ Failed to load after " .. Config.RetryAttempts .. " attempts: " .. path)
        return nil
    end
    
    return Import
end

-- Setze globale Import-Funktion
getgenv().Import = CreateImportFunction()

-- ========================================
-- VERSION CHECK
-- ========================================

print("[Loader] Checking version...")

local function CheckVersion()
    local versionUrl = Config.BaseUrl .. "version.txt"
    local success, version = pcall(function()
        return game:HttpGet(versionUrl, true)
    end)
    
    if success then
        print("[Loader] Version: " .. version)
        getgenv().NyroxHubVersion = version
    else
        warn("[Loader] Could not check version")
    end
end

CheckVersion()

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
    warn("[Loader] Game not supported!")
    warn("[Loader] PlaceId: " .. game.PlaceId)
    
    -- Show GUI with 3 Buttons
    if getgenv().NyroxLib then
        local Window = getgenv().NyroxLib:CreateWindow({
            Title = "Nyrox Hub",
            SubTitle = "Game Not Supported"
        })
        
        local InfoTab = Window:AddTab({Name = "Info"})
        
        InfoTab:AddSection({Name = "Not Supported"})
        
        InfoTab:AddLabel({
            Name = "This game is not supported!",
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
            Name = "You can load the General Script,",
            TextColor = Color3.fromRGB(200, 200, 200)
        })
        
        InfoTab:AddLabel({
            Name = "which works in every game!",
            TextColor = Color3.fromRGB(200, 200, 200)
        })
        
        InfoTab:AddSection({Name = "Actions"})
        
        InfoTab:AddButton({
            Name = "Load General Script",
            Description = "Load universal script with default features",
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
            Description = "Join our Discord server",
            Callback = function()
                local discordInvite = "https://discord.gg/yourcode"
                pcall(function() setclipboard(discordInvite) end)
                if getgenv().CoreFunctions then
                    getgenv().CoreFunctions.Notify("Discord", "Link copied!", 3)
                end
                print("[Discord] Link: " .. discordInvite)
            end
        })
        
        InfoTab:AddButton({
            Name = "Close Script",
            Description = "Close the script",
            Callback = function()
                for _, gui in pairs(game.CoreGui:GetChildren()) do
                    if gui.Name == "NyroxHub" then
                        gui:Destroy()
                    end
                end
            end
        })
        
        InfoTab:AddSection({Name = "Supported Games"})
        
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

print("[Loader] Game detected: " .. gameInfo.DisplayName .. " " .. gameInfo.Icon)

-- ========================================
-- LOAD GAME SCRIPT
-- ========================================

print("[Loader] Loading game script...")
print("[Loader] Path: " .. gameInfo.Script)

local gameScript = getgenv().Import(gameInfo.Script)

if not gameScript then
    error("[Loader] Failed to load game script!")
end

print("[Loader] Game script loaded successfully!")
print("========================================")
print("Nyrox Hub - Ready!")
print("Game: " .. gameInfo.DisplayName)
if getgenv().NyroxHubVersion then
    print("Version: " .. getgenv().NyroxHubVersion)
end
print("========================================")
