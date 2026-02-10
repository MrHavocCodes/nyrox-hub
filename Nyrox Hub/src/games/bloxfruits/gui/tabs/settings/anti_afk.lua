-- Anti-AFK Module für Roblox/Blox Fruits
-- Bietet ToggleAntiAFK(true/false). Startet nach 10 Minuten Inaktivität und simuliert Eingaben.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local module = {}
local enabled = false
local lastInputTime = os.time()
local monitorThread = nil
local inputConn = nil

local function resetTimer()
    lastInputTime = os.time()
end

local function startMonitor()
    if monitorThread then return end
    monitorThread = task.spawn(function()
        while enabled do
            if os.time() - lastInputTime >= 600 then -- 10 Minuten
                -- simulate activity periodically while idle
                local virtualUser = game:GetService("VirtualUser")
                pcall(function()
                    virtualUser:CaptureController()
                    virtualUser:ClickButton2(Vector2.new())
                end)
                -- nach erster Simulation warte etwas länger
                task.wait(60)
            else
                task.wait(1)
            end
        end
        monitorThread = nil
    end)
end

local function stopMonitor()
    enabled = false
    if inputConn then
        inputConn:Disconnect()
        inputConn = nil
    end
    monitorThread = nil
end

function module.ToggleAntiAFK(state)
    if state and not enabled then
        enabled = true
        resetTimer()
        inputConn = UserInputService.InputBegan:Connect(function()
            resetTimer()
            enabled = true -- keep enabled until user toggles off
        end)
        startMonitor()
    elseif (not state) and enabled then
        stopMonitor()
    end
end

function module.IsEnabled()
    return enabled
end

return module
