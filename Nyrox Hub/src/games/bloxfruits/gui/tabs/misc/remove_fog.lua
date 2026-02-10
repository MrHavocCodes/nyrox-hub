-- Remove Fog Script exklusiv für Blox Fruits (vereinfacht)
-- Entfernt nur Nebel/Atmosphäre und macht die Welt heller

local Lighting = game:GetService("Lighting")

local function applyRemoveFog()
    -- Basis-Lichtanpassungen
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.Brightness = 3
    Lighting.TimeOfDay = "12:00:00"
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    Lighting.GlobalShadows = false

    -- Atmosphere minimal setzen, falls vorhanden
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmosphere then
        pcall(function()
            atmosphere.Density = 0
        end)
    end
end

-- Reapply when Lighting children change (e.g., scripts reset values)
Lighting.ChildAdded:Connect(function()
    task.wait(0.05)
    applyRemoveFog()
end)

-- Sofort anwenden
applyRemoveFog()
