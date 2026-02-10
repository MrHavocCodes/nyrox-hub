getgenv().NyroxRunning = true 

local function LoadModule(path)
    if getgenv().Import then
        return getgenv().Import(path)
    else
        warn("Import not found, cannot load window")
        return {}
    end
end

local MainWindow = LoadModule("src/games/buildaboat/gui/main_window.lua")

if getgenv().NyroxConnections then
    for _, connection in pairs(getgenv().NyroxConnections) do
        if connection then connection:Disconnect() end
    end
end
getgenv().NyroxConnections = {}

return MainWindow
