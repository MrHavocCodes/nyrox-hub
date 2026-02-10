-- Dev Loader - Für lokale Entwicklung mit VS Code Live Server
-- Lädt via HTTP Requests von localhost (mit Cache-Busting für sofortige Updates)

print("========================================")
print("Nyrox Hub - Dev Loader")
print("========================================")

-- Warte bis Spiel geladen ist
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ========================================
-- CONFIGURATION
-- ========================================

local Port = 5500  -- VS Code Live Server Standard-Port
local BaseUrl = "http://127.0.0.1:" .. Port .. "/"

-- ========================================
-- HTTP REQUEST FUNCTION
-- ========================================

local function SafeHttpGet(url)
    print("[HTTP] Fetching: " .. url)
    
    -- 1. Try 'request' / 'http_request' (Modern Executors)
    local requestFunc = http_request or request or (http and http.request) or (syn and syn.request)
    if requestFunc then
        print("[HTTP] Using request function...")
        local success, response = pcall(function() 
            return requestFunc({Url = url, Method = "GET"}) 
        end)
        
        if success and response then
            if type(response) == "string" then
                return response
            elseif type(response) == "table" then
                if response.StatusCode == 200 and response.Body then
                    return response.Body
                else
                    warn("[HTTP] Request failed. Status: " .. tostring(response.StatusCode or "Unknown"))
                end
            end
        else
            warn("[HTTP] Request function failed: " .. tostring(response))
        end
    end
    
    -- 2. Try Global HttpGet
    if type(getgenv) == "function" and type(getgenv().HttpGet) == "function" then
        print("[HTTP] Using getgenv().HttpGet...")
        local success, result = pcall(function() return getgenv().HttpGet(url) end)
        if success then return result end
    end
    
    if type(HttpGet) == "function" then
        print("[HTTP] Using global HttpGet...")
        local success, result = pcall(function() return HttpGet(url) end)
        if success then return result end
        warn("[HTTP] Global HttpGet failed: " .. tostring(result))
    end
    
    -- 3. Try game:HttpGet (Last Resort)
    print("[HTTP] Using game:HttpGet...")
    local success, result = pcall(function() return game:HttpGet(url, true) end)
    if success then return result end
    warn("[HTTP] game:HttpGet failed: " .. tostring(result))
    
    error("[HTTP] ✗ No valid HttpGet function found!")
end

-- ========================================
-- SETUP IMPORT FUNCTION
-- ========================================

local function CreateImportFunction()
    local function Import(path)
        -- Cache-Buster für sofortige Updates ohne Roblox Neustart
        local url = BaseUrl .. path .. "?t=" .. tostring(os.time())
        print("[Import] Loading: " .. path)
        
        local content = SafeHttpGet(url)
        
        if not content then
            warn("[Import] ✗ Failed to fetch: " .. path)
            return nil
        end
        
        -- Check for HTML response (404 error)
        if type(content) == "string" and content:sub(1, 1) == "<" then
            error("[Import] ✗ Server returned HTML (404 Not Found). Check file path and Live Server: " .. path)
        end
        
        -- Load code with loadstring
        local func, loadError = loadstring(content)
        
        if not func then
            warn("[Import] ✗ Failed to load: " .. path)
            error("[Import] Error: " .. tostring(loadError))
        end
        
        -- Execute and return result
        local success, result = pcall(func)
        
        if success then
            print("[Import] ✓ Loaded: " .. path)
            return result
        else
            warn("[Import] ✗ Execution failed: " .. path)
            error("[Import] Error: " .. tostring(result))
        end
    end
    
    return Import
end

-- Setze globale Import-Funktion
getgenv().Import = CreateImportFunction()

-- ========================================
-- LOAD LOADING ANIMATION
-- ========================================

print("[Loader] Loading Animation...")
local Animations = getgenv().Import("src/lib/animations.lua")

if Animations and Animations.PlayLoading then
    Animations.PlayLoading() -- Wartet bis Animation fertig ist
    print("[Loader] ✓ Loading Animation completed")
else
    warn("[Loader] ! Animation not available")
end

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
            Description = "Join our Discord server",
            Callback = function()
                local discordInvite = "https://discord.gg/yourcode"
                pcall(function() setclipboard(discordInvite) end)
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
    error("[Loader] ✗ Failed to load game script!")
end

print("[Loader] ✓ Game script loaded successfully!")
print("========================================")
print("Nyrox Hub - Ready! (Dev Mode)")
print("Game: " .. gameInfo.DisplayName)
print("========================================")
