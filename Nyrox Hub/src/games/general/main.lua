-- General Script - Main Entry Point
-- Universal Script with Default Functions for All Games

local GeneralScript = {}

-- ========================================
-- IMPORTS
-- ========================================

local CoreFunctions = getgenv().Import("src/shared/utils/core_functions.lua")
local ConfigSystem = getgenv().Import("src/shared/services/config_system.lua")
local UILib = getgenv().NyroxLib

-- ========================================
-- VARIABLES
-- ========================================

GeneralScript.GameName = "General"
GeneralScript.Version = "1.0.0"
GeneralScript.Config = {}

-- ========================================
-- INITIALIZATION
-- ========================================

function GeneralScript.Init()
    print("========================================")
    print("Nyrox Hub - General Script")
    print("Version: " .. GeneralScript.Version)
    print("Universal Features for All Games")
    print("========================================")
    
    -- Wait for Character
    CoreFunctions.WaitForCharacter()
    
    -- Load GUI
    local CreateMainWindow = getgenv().Import("src/games/general/gui/main_window.lua")
    if CreateMainWindow then
        CreateMainWindow()
    else
        error("[General] Failed to load GUI!")
    end
    
    CoreFunctions.Notify("General Script", "Loaded!", 3)
end

-- ========================================
-- CLEANUP
-- ========================================

function GeneralScript.Cleanup()
    CoreFunctions.Cleanup()
    print("General Script stopped!")
end

-- ========================================
-- START
-- ========================================

GeneralScript.Init()

return GeneralScript
