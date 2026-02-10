-- main.lua (for production loader)
local Main = {}

function Main.run()
    print("Nyrox Hub: Production environment detected. Setting up loader...")
    local BaseUrl = "https://raw.githubusercontent.com/username/repo/main/"

    -- A simple Import function for production.
    local function Import(path)
        local Url = BaseUrl .. path
        local success, content = pcall(game.HttpGet, game, Url, true)
        if not success or not content then
            warn("Nyrox Hub: Failed to import " .. path)
            return nil
        end

        local func, err = loadstring(content)
        if not func then
            warn("Nyrox Hub: Error loading code from " .. path .. ": " .. tostring(err))
            return nil
        end
        
        -- Using pcall to catch errors inside the loaded module
        local s, res = pcall(func)
        if not s then
            warn("Nyrox Hub: Error executing module " .. path .. ": " .. tostring(res))
            return nil
        end
        return res
    end
    getgenv().Import = Import

    -- Load UI Library globally
    getgenv().NyroxLib = Import("src/lib/ui_library.lua")
    if not getgenv().NyroxLib then
        error("Nyrox Hub: Could not load the UI Library. The script cannot continue.")
    end

    -- Game detection logic
    local function LoadGameScript()
        if not game then
            warn("Nyrox Hub: 'game' global not found.")
            return
        end
        local GameId = game.PlaceId
        
        -- Game Place IDs from local_loader.lua
        local BloxFruitsIds = {
            [2753915549] = true, -- First Sea
            [85211729168715] = true, -- First Sea (Variant)
            [4442272183] = true, -- Second Sea
            [79091703265657] = true, -- Second Sea (Variant)
            [7449423635] = true, -- Third Sea
            [100117331123089] = true, -- Private Server / Specific Instance
        }
        local TapSimulatorIds = { [18901165922] = true }
        local FPSFlickIds = { [136801880565837] = true }
        local BuildABoatIds = { [537413528] = true }
        
        local gamePath
        if BloxFruitsIds[GameId] then
            print("Detected Game: Blox Fruits")
            gamePath = "src/games/bloxfruits/main.lua"
        elseif TapSimulatorIds[GameId] then
            print("Detected Game: Tap Simulator")
            gamePath = "src/games/tapsimulator/main.lua"
        elseif FPSFlickIds[GameId] then
            print("Detected Game: FPS Flick")
            gamePath = "src/games/fpsflick/main.lua"
        elseif BuildABoatIds[GameId] then
            print("Detected Game: Build A Boat")
            gamePath = "src/games/buildaboat/main.lua"
        end

        if gamePath then
            Import(gamePath)
        else
            warn("Game not supported or PlaceId unknown: " .. tostring(GameId))
        end
    end

    LoadGameScript()
end

return Main