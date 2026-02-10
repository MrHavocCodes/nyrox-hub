-- Game Detector
-- Detects the current game and loads the corresponding script

local GameDetector = {}

-- ========================================
-- GAME DEFINITIONS
-- ========================================

GameDetector.Games = {
    -- Blox Fruits
    BloxFruits = {
        Name = "Blox Fruits",
        PlaceIds = {
            2753915549,          -- First Sea
            85211729168715,      -- First Sea (Variant)
            4442272183,          -- Second Sea
            79091703265657,      -- Second Sea (Variant)
            7449423635,          -- Third Sea
            100117331123089      -- Private Server / Specific Instance
        },
        Script = "src/games/bloxfruits/main.lua",
        Icon = ""
    },
    
    -- Build a Boat
    BuildABoat = {
        Name = "Build a Boat for Treasure",
        PlaceIds = {
            537413528
        },
        Script = "src/games/buildaboat/main.lua",
        Icon = ""
    },
    
    -- FPS Flick
    FPSFlick = {
        Name = "FPS Flick",
        PlaceIds = {
            136801880565837
        },
        Script = "src/games/fpsflick/main.lua",
        Icon = ""
    },
    
    -- Tap Simulator
    TapSimulator = {
        Name = "Tap Simulator",
        PlaceIds = {
            18901165922
        },
        Script = "src/games/tapsimulator/main.lua",
        Icon = ""
    }
}

-- ========================================
-- DETECTION FUNCTIONS
-- ========================================

function GameDetector.DetectGame()
    local currentPlaceId = game.PlaceId
    
    -- Search all registered games
    for gameName, gameData in pairs(GameDetector.Games) do
        for _, placeId in ipairs(gameData.PlaceIds) do
            if placeId == currentPlaceId then
                return {
                    Name = gameName,
                    DisplayName = gameData.Name,
                    Script = gameData.Script,
                    Icon = gameData.Icon,
                    PlaceId = currentPlaceId
                }
            end
        end
    end
    
    return nil
end

function GameDetector.GetGameInfo(gameName)
    return GameDetector.Games[gameName]
end

function GameDetector.IsGameSupported(placeId)
    for _, gameData in pairs(GameDetector.Games) do
        for _, id in ipairs(gameData.PlaceIds) do
            if id == placeId then
                return true
            end
        end
    end
    return false
end

function GameDetector.GetAllGames()
    local games = {}
    for gameName, gameData in pairs(GameDetector.Games) do
        table.insert(games, {
            Name = gameName,
            DisplayName = gameData.Name,
            Icon = gameData.Icon,
            PlaceIds = gameData.PlaceIds
        })
    end
    return games
end

return GameDetector
