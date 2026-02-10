-- Low Graphics Module exklusiv für Blox Fruits
-- Bietet ToggleLowGraphics(true/false) zum Aktivieren/Deaktivieren

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")

local module = {}
local enabled = false

-- Speicherung vorheriger Zustände, um sie wiederherstellen zu können
local prev = {
    lighting = {},
    atmosphere = nil,
    postEffects = {},
    terrain = {},
    modifiedInstances = {}
}

local function storeLighting()
    prev.lighting.Brightness = Lighting.Brightness
    prev.lighting.TimeOfDay = Lighting.TimeOfDay
    prev.lighting.FogStart = Lighting.FogStart
    prev.lighting.FogEnd = Lighting.FogEnd
    prev.lighting.OutdoorAmbient = Lighting.OutdoorAmbient
    prev.lighting.GlobalShadows = Lighting.GlobalShadows
    prev.lighting.ShadowSoftness = Lighting.ShadowSoftness
    prev.atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    -- store post-processing effects states
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") or v:IsA("BlurEffect") then
            prev.postEffects[#prev.postEffects+1] = {inst = v, enabled = v.Enabled}
        end
    end
end

local function applyLowLighting()
    Lighting.Brightness = 1
    Lighting.TimeOfDay = "14:00:00"
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0

    -- disable post processing
    for _, data in pairs(prev.postEffects) do
        pcall(function() data.inst.Enabled = false end)
    end

    -- neutralize atmosphere
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmosphere then
        pcall(function()
            prev.atmosphere = prev.atmosphere or {}
            prev.atmosphere.Density = atmosphere.Density
            prev.atmosphere.Offset = atmosphere.Offset
            prev.atmosphere.Color = atmosphere.Color

            atmosphere.Density = 0
            atmosphere.Offset = 0
            atmosphere.Color = Color3.new(1,1,1)
        end)
    end
end

local function storeTerrain()
    if Terrain then
        prev.terrain.WaterWaveSize = Terrain.WaterWaveSize
        prev.terrain.WaterWaveSpeed = Terrain.WaterWaveSpeed
        prev.terrain.WaterReflectance = Terrain.WaterReflectance
        prev.terrain.WaterTransparency = Terrain.WaterTransparency
    end
end

local function applyLowTerrain()
    if Terrain then
        pcall(function()
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
        end)
    end
end

local function storeAndDisableEffects(root)
    for _, obj in pairs(root:GetDescendants()) do
        -- particle-like
        if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            prev.modifiedInstances[#prev.modifiedInstances+1] = {inst = obj, prop = "Enabled", old = obj.Enabled}
            pcall(function() obj.Enabled = false end)
        end

        -- animation tracks (stop and store play state)
        pcall(function()
            if obj.GetPlayingAnimationTracks then
                for _, track in pairs(obj:GetPlayingAnimationTracks()) do
                    local wasPlaying = false
                    pcall(function() wasPlaying = track.IsPlaying and track.IsPlaying() end)
                    prev.modifiedInstances[#prev.modifiedInstances+1] = {inst = track, prop = "playing", old = wasPlaying}
                    pcall(function() track:Stop() end)
                end
            end
            if obj:IsA("AnimationTrack") then
                local wasPlaying = false
                pcall(function() wasPlaying = obj.IsPlaying and obj.IsPlaying() end)
                prev.modifiedInstances[#prev.modifiedInstances+1] = {inst = obj, prop = "playing", old = wasPlaying}
                pcall(function() obj:Stop() end)
            end
        end)

        -- special fog parts
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("fog") or name:find("mist") or name:find("haze") or name:find("vfx") then
                prev.modifiedInstances[#prev.modifiedInstances+1] = {inst = obj, prop = "Transparency", old = obj.Transparency}
                prev.modifiedInstances[#prev.modifiedInstances+1] = {inst = obj, prop = "CanCollide", old = obj.CanCollide}
                prev.modifiedInstances[#prev.modifiedInstances+1] = {inst = obj, prop = "CastShadow", old = obj.CastShadow}
                pcall(function()
                    obj.Transparency = 1
                    obj.CanCollide = false
                    obj.CastShadow = false
                end)
            end
        end
    end
end

local function restoreModifiedInstances()
    for _, data in pairs(prev.modifiedInstances) do
        pcall(function()
            if data.prop == "Enabled" then
                data.inst.Enabled = data.old
            elseif data.prop == "playing" then
                if data.old then
                    pcall(function() data.inst:Play() end)
                else
                    pcall(function() data.inst:Stop() end)
                end
            else
                data.inst[data.prop] = data.old
            end
        end)
    end
    prev.modifiedInstances = {}
end

local function restoreLighting()
    pcall(function()
        Lighting.Brightness = prev.lighting.Brightness
        Lighting.TimeOfDay = prev.lighting.TimeOfDay
        Lighting.FogStart = prev.lighting.FogStart
        Lighting.FogEnd = prev.lighting.FogEnd
        Lighting.OutdoorAmbient = prev.lighting.OutdoorAmbient
        Lighting.GlobalShadows = prev.lighting.GlobalShadows
        Lighting.ShadowSoftness = prev.lighting.ShadowSoftness

        -- restore atmosphere
        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere and prev.atmosphere then
            atmosphere.Density = prev.atmosphere.Density or atmosphere.Density
            atmosphere.Offset = prev.atmosphere.Offset or atmosphere.Offset
            atmosphere.Color = prev.atmosphere.Color or atmosphere.Color
        end

        -- restore post effects
        for _, data in pairs(prev.postEffects) do
            pcall(function() data.inst.Enabled = data.enabled end)
        end
        prev.postEffects = {}
    end)
end

local function restoreTerrain()
    if Terrain then
        pcall(function()
            Terrain.WaterWaveSize = prev.terrain.WaterWaveSize or Terrain.WaterWaveSize
            Terrain.WaterWaveSpeed = prev.terrain.WaterWaveSpeed or Terrain.WaterWaveSpeed
            Terrain.WaterReflectance = prev.terrain.WaterReflectance or Terrain.WaterReflectance
            Terrain.WaterTransparency = prev.terrain.WaterTransparency or Terrain.WaterTransparency
        end)
    end
end

local function optimizeBloxFruits()
    -- target typical objects: Bosses, NPCs, Fruits, Chests
    for _, obj in pairs(Workspace:GetChildren()) do
        local name = obj.Name:lower()
        if name:find("boss") or name:find("npc") or name:find("fruit") or name:find("chest") then
            storeAndDisableEffects(obj)
        end
    end
    -- also apply globally
    storeAndDisableEffects(Workspace)
end

function module.ToggleLowGraphics(state)
    if state and not enabled then
        -- enable
        enabled = true
        storeLighting()
        storeTerrain()
        -- Clear prev.modifiedInstances just in case
        prev.modifiedInstances = {}
        applyLowLighting()
        applyLowTerrain()
        optimizeBloxFruits()
        -- listen for newly added instances and disable if they match
        if not module._conn then
            module._conn = Workspace.DescendantAdded:Connect(function(obj)
                wait(0.05)
                -- disable if it matches particle/fog patterns
                pcall(function()
                    if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                        prev.modifiedInstances[#prev.modifiedInstances+1] = {inst = obj, prop = "Enabled", old = obj.Enabled}
                        obj.Enabled = false
                    end
                    if obj:IsA("BasePart") then
                        local nm = obj.Name:lower()
                        if nm:find("fog") or nm:find("mist") or nm:find("haze") or nm:find("vfx") then
                            prev.modifiedInstances[#prev.modifiedInstances+1] = {inst = obj, prop = "Transparency", old = obj.Transparency}
                            prev.modifiedInstances[#prev.modifiedInstances+1] = {inst = obj, prop = "CanCollide", old = obj.CanCollide}
                            prev.modifiedInstances[#prev.modifiedInstances+1] = {inst = obj, prop = "CastShadow", old = obj.CastShadow}
                            obj.Transparency = 1
                            obj.CanCollide = false
                            obj.CastShadow = false
                        end
                    end
                end)
            end)
        end
    elseif not state and enabled then
        -- disable
        enabled = false
        if module._conn then
            module._conn:Disconnect()
            module._conn = nil
        end
        restoreModifiedInstances()
        restoreLighting()
        restoreTerrain()
    end
end

function module.IsEnabled()
    return enabled
end

return module
