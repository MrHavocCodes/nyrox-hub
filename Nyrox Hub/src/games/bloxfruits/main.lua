-- Entry point for the script
-- Safe environment access
local function GetEnv()
    if type(getgenv) == "function" then
        return getgenv()
    end
    return shared
end

local env = GetEnv()
env.NyroxRunning = true

-- ========================================
-- FIX: Prevent Mobile Detection (AGGRESSIVE)
-- ========================================
local function ForcePC()
    -- Disable Touch Controls
    pcall(function()
        local GuiService = game:GetService("GuiService")
        GuiService.TouchControlsEnabled = false
    end)
    
    -- Disable Touch Input
    pcall(function()
        local UserInputService = game:GetService("UserInputService")
        UserInputService.TouchEnabled = false
    end)
    
    -- Remove Mobile Button
    pcall(function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        if LocalPlayer and LocalPlayer.PlayerGui then
            local TouchGui = LocalPlayer.PlayerGui:FindFirstChild("TouchGui")
            if TouchGui then
                TouchGui:Destroy()
            end
        end
    end)
    
    -- Enable Mouse Lock
    pcall(function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        if LocalPlayer then
            LocalPlayer.DevEnableMouseLock = true
            LocalPlayer.DevComputerMovementMode = Enum.DevComputerMovementMode.UserChoice
        end
    end)
    
    -- Enable Mouse Icon
    pcall(function()
        local UserInputService = game:GetService("UserInputService")
        UserInputService.MouseIconEnabled = true
    end)
end

-- Execute immediately
ForcePC()

-- Hook to prevent other scripts from enabling touch
pcall(function()
    local GuiService = game:GetService("GuiService")
    local mt = getrawmetatable(GuiService)
    local oldNewIndex = mt.__newindex
    
    setreadonly(mt, false)
    mt.__newindex = newcclosure(function(t, k, v)
        if k == "TouchControlsEnabled" and v == true then
            return -- Block enabling touch controls
        end
        return oldNewIndex(t, k, v)
    end)
    setreadonly(mt, true)
end)

-- Keep enforcing PC mode
task.spawn(function()
    while env.NyroxRunning do
        ForcePC()
        task.wait(1)
    end
end)

local function LoadModule(path)
    if env.Import then
        return env.Import(path)
    else
        warn("Import not found, cannot load modules")
        return {}
    end
end

-- Load initialization
-- local Init = LoadModule("src/games/bloxfruits/utils/init.lua")
-- if Init and Init.Start then
--     Init.Start()
-- end

-- Load main window
local MainWindow = LoadModule("src/games/bloxfruits/gui/main_window.lua")

-- Disconnect all functions when script is re-executed
if env.NyroxConnections then
    for _, connection in pairs(env.NyroxConnections) do
        if connection then connection:Disconnect() end
    end
end
env.NyroxConnections = {}

return MainWindow
