-- Entry point for the FPS Flick script
getgenv().NyroxRunning = true 

local function LoadModule(path)
    if getgenv().Import then
        return getgenv().Import(path)
    else
        warn("Import not found, cannot load window")
        return {}
    end
end

local MainWindow = LoadModule("src/games/fpsflick/gui/main_window.lua")

if getgenv().NyroxConnections then
    for _, connection in pairs(getgenv().NyroxConnections) do
        if connection then connection:Disconnect() end
    end
end
getgenv().NyroxConnections = {}

-- Clean up previous drawings (fix for persistent circle)
if getgenv().NyroxDrawings then
    for _, drawing in pairs(getgenv().NyroxDrawings) do
        pcall(function() drawing:Remove() end)
    end
end
getgenv().NyroxDrawings = {}

return MainWindow
