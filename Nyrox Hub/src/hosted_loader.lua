-- ============================================
-- NYROX HUB - UNIVERSAL LOADSTRING LOADER
-- ============================================
-- Execute this script to load Nyrox Hub from web
-- Works on ANY account, ANY executor
-- ============================================

-- CONFIGURATION: Change these to your GitHub details
local Owner = "MrHavocCodes"  -- Your GitHub username
local Repo = "s"            -- Your repository name  
local Branch = "main"               -- Branch (usually "main" or "master")

-- Auto-construct base URL
local BaseUrl = string.format("https://raw.githubusercontent.com/%s/%s/%s/", Owner, Repo, Branch)

-- ============================================
-- HTTP GET WRAPPER (Multi-Executor Support)
-- ============================================
local function SafeHttpGet(url)
    -- Try different HttpGet methods for different executors
    local methods = {
        function() return game:HttpGet(url, true) end,
        function() return game:HttpGet(url) end,
        function() return game:GetObjects(url)[1] end,
        function() 
            local req = http_request or request or (http and http.request) or (syn and syn.request)
            if req then 
                return req({Url = url, Method = "GET"}).Body 
            end
        end
    }
    
    for _, method in ipairs(methods) do
        local success, result = pcall(method)
        if success and result then 
            return result 
        end
    end
    
    error("Failed to fetch URL: " .. url .. "\nNo working HttpGet method found for your executor.")
end

-- ============================================
-- IMPORT SYSTEM (Loads scripts from web)
-- ============================================
local function Import(path)
    local url = BaseUrl .. path
    
    -- Show what we're loading
    print("[Nyrox Hub] Loading: " .. path)
    
    -- Fetch the script
    local success, content = pcall(function()
        return SafeHttpGet(url)
    end)
    
    if not success then
        warn("[Nyrox Hub] Failed to fetch: " .. path)
        warn("[Nyrox Hub] Error: " .. tostring(content))
        return nil
    end
    
    -- Compile the script
    local func, compileError = loadstring(content, path)
    if not func then
        warn("[Nyrox Hub] Failed to compile: " .. path)
        warn("[Nyrox Hub] Error: " .. tostring(compileError))
        return nil
    end
    
    -- Execute the script
    local execSuccess, result = pcall(func)
    if not execSuccess then
        warn("[Nyrox Hub] Failed to execute: " .. path)
        warn("[Nyrox Hub] Error: " .. tostring(result))
        return nil
    end
    
    return result
end

-- Make Import globally accessible
getgenv().Import = Import
getgenv().NyroxBaseUrl = BaseUrl

-- ============================================
-- MAIN LOADER SEQUENCE
-- ============================================

print("╔════════════════════════════════════════╗")
print("║         NYROX HUB LOADING...          ║")
print("╚════════════════════════════════════════╝")
print("URL: " .. BaseUrl)

-- Check if already running
if getgenv().NyroxRunning then
    warn("[Nyrox Hub] Script is already running!")
    warn("[Nyrox Hub] Please restart the game to load again.")
    return
end

-- Step 1: Load UI Library
print("[Nyrox Hub] [1/4] Loading UI Library...")
local UILib = Import("src/lib/ui_library.lua")
if not UILib then
    error("[Nyrox Hub] FATAL: Could not load UI Library. Check your GitHub URL settings!")
end
getgenv().NyroxLib = UILib
print("[Nyrox Hub] ✓ UI Library loaded")

-- Step 2: Load Animations (optional)
print("[Nyrox Hub] [2/4] Loading Animations...")
pcall(function()
    local Animations = Import("src/lib/animations.lua")
    if Animations and Animations.PlayLoading then
        Animations.PlayLoading()
    end
end)

-- Step 3: Detect Game
print("[Nyrox Hub] [3/4] Detecting Game...")
local GameId = game.PlaceId
local GameName = "Unknown"
local GamePath = nil

-- Game Detection Table
local Games = {
    -- Blox Fruits
    [2753915549] = {name = "Blox Fruits (Sea 1)", path = "src/games/bloxfruits/main.lua"},
    [4442272183] = {name = "Blox Fruits (Sea 2)", path = "src/games/bloxfruits/main.lua"},
    [7449423635] = {name = "Blox Fruits (Sea 3)", path = "src/games/bloxfruits/main.lua"},
    
    -- Other Games
    [18901165922] = {name = "Tap Simulator", path = "src/games/tapsimulator/main.lua"},
    [136801880565837] = {name = "FPS Flick", path = "src/games/fpsflick/main.lua"},
    [537413528] = {name = "Build A Boat", path = "src/games/buildaboat/main.lua"},
}

if Games[GameId] then
    GameName = Games[GameId].name
    GamePath = Games[GameId].path
    print("[Nyrox Hub] ✓ Detected: " .. GameName)
else
    print("[Nyrox Hub] ⚠ Unknown Game (PlaceId: " .. GameId .. ")")
    print("[Nyrox Hub] Loading Universal GUI...")
    GamePath = "src/games/general/main.lua"
end

-- Step 4: Load Game Script
print("[Nyrox Hub] [4/4] Loading Game Module...")
if GamePath then
    local GameModule = Import(GamePath)
    if GameModule then
        print("[Nyrox Hub] ✓ Game module loaded")
    else
        warn("[Nyrox Hub] Failed to load game module!")
    end
else
    warn("[Nyrox Hub] No game module found!")
end

-- Mark as running
getgenv().NyroxRunning = true

print("╔════════════════════════════════════════╗")
print("║      NYROX HUB LOADED SUCCESSFULLY!    ║")
print("╚════════════════════════════════════════╝")
print("Game: " .. GameName)
print("Press INSERT or your executor's GUI key to open")
