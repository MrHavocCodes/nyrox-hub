-- Configuration for local development

if not game:IsLoaded() then
    game.Loaded:Wait()
end

print("Nyrox Hub Started")
local Port = 5500
local BaseUrl = "http://127.0.0.1:" .. Port .. "/"

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
                end
            end
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
    end
    
    -- 3. Try game:HttpGet
    local success, result = pcall(function() return game:HttpGet(url) end)
    if success then return result end

    error("CRITICAL: No valid HttpGet or Request function found!")
end

local function Import(path)
    local Url = BaseUrl .. path .. "?t=" .. tostring(os.time())
    local Content = SafeHttpGet(Url)

    if type(Content) == "string" and Content:sub(1, 1) == "<" then
        error("Nyrox Hub: Failed to load " .. path .. " (404)")
    end

    local Func, Error = loadstring(Content)
    
    if not Func then
        error("Error loading: " .. path)
    end
    
    return Func()
end

getgenv().Import = Import

-- 1. Load UI Library
getgenv().NyroxLib = Import("src/lib/ui_library.lua")

-- 2. Load Core Modules
local GameDetector = Import("src/core/game_detector.lua")
getgenv().GameDetector = GameDetector

local CoreFunctions = Import("src/shared/utils/core_functions.lua")
if CoreFunctions then
    getgenv().CoreFunctions = CoreFunctions
end

local ConfigSystem = Import("src/shared/services/config_system.lua")
if ConfigSystem then
    getgenv().ConfigSystem = ConfigSystem
end

-- Load Animations
local Animations = Import("src/lib/animations.lua")
if Animations then
    getgenv().NyroxAnimations = Animations
end

-- 3. Detect Game
local gameInfo = GameDetector.DetectGame()

if not gameInfo then
    warn("Game not supported! PlaceId: " .. game.PlaceId)
    
    if getgenv().NyroxLib then
        local Window = getgenv().NyroxLib:CreateWindow({
            Title = "Nyrox Hub",
            SubTitle = "Not Supported"
        })
        
        local InfoTab = Window:AddTab({Name = "Info"})
        InfoTab:AddSection({Name = "Not Supported"})
        InfoTab:AddLabel({Name = "This game is not supported!", TextColor = Color3.fromRGB(255, 150, 0)})
        InfoTab:AddLabel({Name = "PlaceId: " .. game.PlaceId})
    end
    return
end

-- Play Animation
if getgenv().NyroxAnimations and getgenv().NyroxAnimations.PlayLoading then
    getgenv().NyroxAnimations.PlayLoading()
end

-- 4. Load Game Script
Import(gameInfo.Script)

print("Nyrox Hub Loaded")

