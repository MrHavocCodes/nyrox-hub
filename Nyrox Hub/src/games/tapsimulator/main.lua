-- Entry point for the Tap Simulator script
getgenv().NyroxRunning = true -- Global flag to control execution

local function LoadModule(path)
    if getgenv().Import then
        return getgenv().Import(path)
    else
        warn("Import not found, cannot load window")
        return {}
    end
end

local MainWindow = LoadModule("src/games/tapsimulator/gui/main_window.lua")

-- Disconnect all functions when script is re-executed (basic cleanup)
if getgenv().NyroxConnections then
    for _, connection in pairs(getgenv().NyroxConnections) do
        if connection then connection:Disconnect() end
    end
end
getgenv().NyroxConnections = {}

return MainWindow
