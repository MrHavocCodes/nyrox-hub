-- Dev Loader - For local development

print("Nyrox Hub Started")

-- Wait until game is loaded
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ========================================
-- CONFIGURATION
-- ========================================

local Port = 5500
local BaseUrl = "http://127.0.0.1:" .. Port .. "/"

-- ========================================
-- HTTP REQUEST FUNCTION
-- ========================================

local function SafeHttpGet(url)
    -- 1. Try 'request' / 'http_request'
    local requestFunc = http_request or request or (http and http.request) or (syn and syn.request)
    if requestFunc then
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
                    warn("Request failed. Status: " .. tostring(response.StatusCode or "Unknown"))
                end
            end
        else
            warn("Request function failed: " .. tostring(response))
        end
    end
    
    -- 2. Try Global HttpGet
    if type(getgenv) == "function" and type(getgenv().HttpGet) == "function" then
        local success, result = pcall(function() return getgenv().HttpGet(url) end)
        if success then return result end
    end
    
    if type(HttpGet) == "function" then
        local success, result = pcall(function() return HttpGet(url) end)
        if success then return result end
        warn("Global HttpGet failed: " .. tostring(result))
    end
    
    -- 3. Try game:HttpGet
    local success, result = pcall(function() return game:HttpGet(url, true) end)
    if success then return result end
    warn("game:HttpGet failed: " .. tostring(result))
    
    error("No valid HttpGet function found!")
end

-- ========================================
-- SETUP IMPORT FUNCTION
-- ========================================

local function CreateImportFunction()
    local function Import(path)
        -- Cache-Buster
        local url = BaseUrl .. path .. "?t=" .. tostring(os.time())
        
        local content = SafeHttpGet(url)
        
        if not content then
            warn("Failed to fetch: " .. path)
            return nil
        end
        
        -- Check for HTML response (404 error)
        if type(content) == "string" and content:sub(1, 1) == "<" then
            error("Server returned HTML (404 Not Found): " .. path)
        end
        
        -- Load code
        local func, loadError = loadstring(content)
        
        if not func then
            warn("Failed to load: " .. path)
            error("Error: " .. tostring(loadError))
        end
        
        -- Execute
        local success, result = pcall(func)
        
        if success then
            return result
        else
            warn("Execution failed: " .. path)
            error("Error: " .. tostring(result))
        end
    end
    
    return Import
end

getgenv().Import = CreateImportFunction()

-- ========================================
-- LOAD LOADING ANIMATION
-- ========================================

local Animations = getgenv().Import("src/lib/animations.lua")

if Animations and Animations.PlayLoading then
    Animations.PlayLoading()
else
    warn("Animation not available")
end

-- ========================================
-- LOAD UI LIBRARY
-- ========================================

getgenv().NyroxLib = getgenv().Import("src/lib/ui_library.lua")

if not getgenv().NyroxLib then
    error("Failed to load UI Library!")
end

-- ========================================
-- LOAD CORE MODULES
-- ========================================

local GameDetector = getgenv().Import("src/core/game_detector.lua")
if not GameDetector then
    error("Failed to load Game Detector!")
end
getgenv().GameDetector = GameDetector

-- Load Core Functions
local CoreFunctions = getgenv().Import("src/shared/utils/core_functions.lua")
if CoreFunctions then
    getgenv().CoreFunctions = CoreFunctions
end

-- Load Config System
local ConfigSystem = getgenv().Import("src/shared/services/config_system.lua")
if ConfigSystem then
    getgenv().ConfigSystem = ConfigSystem
end

-- ========================================
-- DETECT GAME
-- ========================================

local gameInfo = GameDetector.DetectGame()

if not gameInfo then
    warn("Game not supported! PlaceId: " .. game.PlaceId)
    
    if getgenv().NyroxLib then
        local Window = getgenv().NyroxLib:CreateWindow({
            Title = "Nyrox Hub",
            SubTitle = "Game Not Supported"
        })
        
        local InfoTab = Window:AddTab({Name = "Info"})
        InfoTab:AddSection({Name = "Not Supported"})
        InfoTab:AddLabel({Name = "This game is not supported!", TextColor = Color3.fromRGB(255, 150, 0)})
        InfoTab:AddLabel({Name = "PlaceId: " .. game.PlaceId})
    end
    
    return
end

-- ========================================
-- LOAD GAME SCRIPT
-- ========================================

local gameScript = getgenv().Import(gameInfo.Script)

if not gameScript then
    error("Failed to load game script!")
end

print("Nyrox Hub Loaded")

print("Game: " .. gameInfo.DisplayName)
