local Library
-- 1. UI Library laden
if getgenv and getgenv().NyroxLib then
    Library = getgenv().NyroxLib
else
    if getgenv and getgenv().Import then
        Library = getgenv().Import("src/lib/ui_library.lua")
    end
    if not Library then
        pcall(function()
            -- Prüfe, ob dein GitHub-Link korrekt ist!
            Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/MrHavocCodes/repo/main/src/lib/ui_library.lua"))() 
        end)
    end
end

if not Library then return warn("Nyrox Hub: UI Library failed to load.") end

-- 2. Globaler Stop-Schalter (Kill-Switch) & Cleanup Module
getgenv().NyroxRunning = true

-- Initialisierung von Standard-Werten (Fix für Default=true)
getgenv().AutoAura = true
getgenv().AttackMethod = "Melee"
getgenv().TweenSpeed = 200
getgenv().BringMobs = true
getgenv().MagnetRange = 300
getgenv().BypassTP = true
getgenv().AntiAFK = true

-- Store loaded modules for cleanup
local LoadedModules = {}

local CloseHandler = nil
-- Versuche complete_close.lua zu laden, falls vorhanden
pcall(function()
    if getgenv().Import then
        CloseHandler = getgenv().Import("src/games/bloxfruits/utils/complete_close.lua")
    end
end)

local function Shutdown()
    getgenv().NyroxRunning = false
    getgenv().AutoFarm = false
    getgenv().AutoFarmNear = false
    
    -- Stop all loaded modules
    for name, module in pairs(LoadedModules) do
        if module and type(module.Stop) == "function" then
            pcall(function()
                module.Stop()
                print("[Shutdown] Stopped module:", name)
            end)
        end
    end
    
    -- Nutze CloseHandler falls verfügbar
    if CloseHandler and CloseHandler.StopAll then
        CloseHandler.StopAll()
    end
end

-- 3. Hauptfenster erstellen
local Window = Library:CreateWindow({
    Title = "Nyrox Hub - Blox Fruits",
    SubTitle = "by L5ks8",
    OnClose = function()
        Shutdown()
    end
})

-- Hilfsfunktion zum Laden von Modulen
local function LoadModule(path, storeName)
    if not getgenv().Import then
        warn("Nyrox Hub: Import-Funktion nicht gefunden. Modul konnte nicht geladen werden: " .. path)
        return nil
    end

    local success, result = pcall(function()
        return getgenv().Import(path)
    end)

    if success then
        -- Store module reference if name provided
        if storeName and result then
            LoadedModules[storeName] = result
        end
        return result
    else
        warn("Nyrox Hub: Fehler beim Laden von Modul: " .. path)
        warn(tostring(result)) -- Zeigt den genauen Fehler in der Konsole an (F9)
        return nil
    end
end

-- 4. Tabs erstellen und Variablen zuweisen
local UpdatesTab  = Window:CreateTab("Updates")
local FarmTab     = Window:CreateTab("Farm")
local PvpTab      = Window:CreateTab("PvP")
local VisualsTab  = Window:CreateTab("Visuals")
local TeleportTab = Window:CreateTab("Teleport")
local RaidTab     = Window:CreateTab("Raid")
local FruitTab    = Window:CreateTab("Fruit")
local ShopTab     = Window:CreateTab("Shop")
local MiscTab     = Window:CreateTab("Misc")
local SettingsTab  = Window:CreateTab("Settings")
--- -----------------------------------------------------------
--- UPDATES TAB 
--- -----------------------------------------------------------
UpdatesTab:CreateSection("Discord")
UpdatesTab:CreateButton({
    Title = "Join Discord Server",
    Tooltip = "Click to copy the Discord invite link!",
    Callback = function()
        setclipboard("https://discord.gg/9SKA7sYg")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Nyrox Hub",
            Text = "Discord link copied to clipboard!",
            Duration = 5,
        })
    end
})

-- Load update logs from external file for cleaner main_window.lua
local UpdateLogs = LoadModule("src/games/bloxfruits/gui/tabs/updates/update_logs.lua")
if UpdateLogs then
    UpdateLogs(UpdatesTab)
end

--- -----------------------------------------------------------
--- FARM TAB 
--- -----------------------------------------------------------
FarmTab:CreateSection("Farm Settings")
FarmTab:CreateToggle({
    Title = "Auto Aura",
    Tooltip = "Automatically Turns Aura on",
    Default = true,
    Callback = function(Value)
        getgenv().AutoAura = Value
    end
})

FarmTab:CreateDropdown({
    Title = "Attack Method",
    Tooltip = nil,
    Options = {"Melee", "Blox Fruit", "Sword", "Gun"},
    Default = "Melee",
    Callback = function(Value)
        getgenv().AttackMethod = Value
    end
})

-- Weapon Select System laden und starten
local WeaponSelect = LoadModule("src/games/bloxfruits/gui/tabs/farm/farm_settings.lua")
if WeaponSelect and WeaponSelect.StartLoop then
    WeaponSelect.StartLoop()
end

FarmTab:CreateValidSlider({
    Title = "Tween Speed",
    Tooltip = "Changes the speed of tweens used for farming (Higher is faster, but more likely to cause desync or teleport issues)",
    Min = 200,
    Max = 800,
    Default = 400,
    Callback = function(Value)
        getgenv().TweenSpeed = Value
    end
})

FarmTab:CreateToggle({
    Title = "Bring Mobs",
    Tooltip = "Magnets all nearby NPCs to your position while farming",
    Default = true,
    Callback = function(Value)
        getgenv().BringMobs = Value
    end
})

FarmTab:CreateValidSlider({
    Title = "Magnet Range",
    Tooltip = "Range to pull mobs (only works with Bring Mobs enabled)",
    Min = 50,
    Max = 500,
    Default = 300,
    Callback = function(Value)
        getgenv().MagnetRange = Value
    end
})

FarmTab:CreateSection("Auto Stats")
FarmTab:CreateToggle({
    Title = "Auto Stats",
    Tooltip = "Automatically upgrades selected stat",
    Default = false,
    Callback = function(Value)
        getgenv().AutoStats = Value
    end
})

FarmTab:CreateDropdown({
    Title = "Stat Priority",
    Tooltip = nil,
    Options = {"Melee", "Defense", "Sword", "Gun", "Blox Fruit"},
    Default = "Melee",
    Callback = function(Value)
        getgenv().StatPriority = Value
    end
})

FarmTab:CreateValidSlider({
    Title = "Points Per Upgrade",
    Tooltip = nil,
    Min = 1,
    Max = 10,
    Default = 1,
    Callback = function(Value)
        getgenv().StatsPointsPerUpgrade = Value
    end
})


FarmTab:CreateSection("Main Farm")

FarmTab:CreateToggle({
    Title = "Auto Farm",
    Tooltip = "Automatically Farm Level",
    Default = false,
    Callback = function(Value)
        getgenv().AutoFarm = Value
    end
})

local AutoFarm = LoadModule("src/games/bloxfruits/gui/tabs/farm/auto_farm.lua", "AutoFarm")
if AutoFarm and AutoFarm.StartLoop then
    AutoFarm.StartLoop()
end

FarmTab:CreateToggle({
Title = "Auto Farm Near",
     Tooltip = "Automatically Farm Npcs near you",
     Default = false,
     Callback = function(Value)
         getgenv().AutoFarmNear = Value
     end
    })

local AutoFarmNear = LoadModule("src/games/bloxfruits/gui/tabs/farm/auto_farm_near.lua", "AutoFarmNear")
if AutoFarmNear and AutoFarmNear.StartLoop then
    AutoFarmNear.StartLoop()
end

FarmTab:CreateToggle({
    Title = "Bypass TP",
    Tooltip = "Automatically Resets Character when Player near Target",
    Default = true,
    Callback = function(Value)
        getgenv().BypassTP = Value
    end
})

FarmTab:CreateToggle({
    Title = "Chest Farm",
    Tooltip = "Automatically farms all chests on the map",
    Default = false,
    Callback = function(Value)
        getgenv().ChestFarm = Value
    end
})

local ChestFarm = LoadModule("src/games/bloxfruits/gui/tabs/farm/chest_farm.lua", "ChestFarm")
if ChestFarm and ChestFarm.StartLoop then
    ChestFarm.StartLoop()
end

FarmTab:CreateSection("Boss Farm")

FarmTab:CreateToggle({
    Title = "Auto Boss Farm",
    Tooltip = "Automatically farms selected boss",
    Default = false,
    Callback = function(Value)
        getgenv().AutoBossFarm = Value
    end
})

FarmTab:CreateDropdown({
    Title = "Select Boss",
    Tooltip = "Choose which boss to farm",
    Options = {"None", "Gorilla King", "Thunder God", "Saber Expert", "Wysper", "Diamond", "Jeremy", "Fajita", "Don Swan", "Cake Queen", "Longma", "Dough King", "rip_indra"},
    Default = "None",
    Callback = function(Value)
        getgenv().SelectedBoss = Value
    end
})

local BossFarm = LoadModule("src/games/bloxfruits/gui/tabs/farm/boss_farm.lua", "BossFarm")
if BossFarm and BossFarm.StartLoop then
    BossFarm.StartLoop()
end

FarmTab:CreateSection("Material & Factory Farm")

FarmTab:CreateToggle({
    Title = "Auto Material Farm",
    Tooltip = "Automatically farms selected material",
    Default = false,
    Callback = function(Value)
        getgenv().AutoMaterialFarm = Value
    end
})

FarmTab:CreateDropdown({
    Title = "Select Material",
    Tooltip = "Choose which material to farm",
    Options = {"None", "Radioactive Material", "Mystic Droplet", "Vampire Fang", "Conjured Cocoa", "Dragon Scale", "Gunpowder", "Fish Tail", "Mini Tusk", "Scrap Metal", "Leather", "Angel Wings", "Magma Ore", "Demonic Wisp"},
    Default = "None",
    Callback = function(Value)
        getgenv().SelectedMaterial = Value
    end
})

local MaterialFarm = LoadModule("src/games/bloxfruits/gui/tabs/farm/material_farm.lua", "MaterialFarm")
if MaterialFarm and MaterialFarm.StartLoop then
    MaterialFarm.StartLoop()
end

FarmTab:CreateToggle({
    Title = "Auto Factory Farm",
    Tooltip = "Automatically farms factory area (Sea 2)",
    Default = false,
    Callback = function(Value)
        getgenv().AutoFactoryFarm = Value
    end
})

local FactoryFarm = LoadModule("src/games/bloxfruits/gui/tabs/farm/factory_farm.lua", "FactoryFarm")
if FactoryFarm and FactoryFarm.StartLoop then
    FactoryFarm.StartLoop()
end

--- -----------------------------------------------------------
--- PVP TAB 
--- -----------------------------------------------------------
PvpTab:CreateSection("Rage PVP")

local AlivePlayers = LoadModule("src/games/bloxfruits/gui/tabs/pvp/alive_players.lua")

local PlayerDropdown = PvpTab:CreateDropdown({
    Title = "Target Player",
    Tooltip = "Targets selected Player",
    Options = {},
    Default = "None",
    Callback = function(Value)
        getgenv().TargetPlayer = Value
    end
})

if AlivePlayers and AlivePlayers.StartAutoRefresh then
    AlivePlayers.StartAutoRefresh(PlayerDropdown)
end

local SpectatePlayer = LoadModule("src/games/bloxfruits/gui/tabs/pvp/spectate_player.lua")
if SpectatePlayer and SpectatePlayer.StartLoop then
    SpectatePlayer.StartLoop()
end

PvpTab:CreateToggle({
    Title = "Spectate Player",
    Tooltip = "Automatically Spectate Target Player",
    Default = false,
    Callback = function(Value)
        getgenv().AutoSpectate = Value
    end
})

PvpTab:CreateToggle({
    Title = "Auto Kill Player",
    Tooltip = "Automatically kills the target player",
    Default = false,
    Callback = function(Value)
        getgenv().AutoKillPlayer = Value
    end
})

PvpTab:CreateToggle({
    Title = "Auto TP to Player",
    Tooltip = "Automatically teleports to target player",
    Default = false,
    Callback = function(Value)
        getgenv().AutoTPToPlayer = Value
    end
})

local AutoTPPlayer = LoadModule("src/games/bloxfruits/gui/tabs/pvp/auto_tp_tp_player.lua")
if AutoTPPlayer and AutoTPPlayer.StartLoop then
    AutoTPPlayer.StartLoop()
end

PvpTab:CreateSection("Auto Abilities")

PvpTab:CreateToggle({
    Title = "Auto Activate V3",
    Tooltip = "Automatically activates V3 ability in combat",
    Default = false,
    Callback = function(Value)
        getgenv().AutoActivateV3 = Value
    end
})

local AutoV3 = LoadModule("src/games/bloxfruits/gui/tabs/pvp/auto_activate_v3.lua")
if AutoV3 and AutoV3.StartLoop then
    AutoV3.StartLoop()
end

PvpTab:CreateToggle({
    Title = "Auto Activate V4",
    Tooltip = "Automatically activates V4 ability in combat",
    Default = false,
    Callback = function(Value)
        getgenv().AutoActivateV4 = Value
    end
})

local AutoV4 = LoadModule("src/games/bloxfruits/gui/tabs/pvp/auto_activate_v4.lua")
if AutoV4 and AutoV4.StartLoop then
    AutoV4.StartLoop()
end

PvpTab:CreateSection("Aimbot")

PvpTab:CreateToggle({
    Title = "Aimbot",
    Tooltip = "Automatically aims at nearest player (Hold RMB)",
    Default = false,
    Callback = function(Value)
        getgenv().Aimbot = Value
    end
})

PvpTab:CreateValidSlider({
    Title = "Aimbot FOV",
    Tooltip = "Field of view for aimbot",
    Min = 50,
    Max = 500,
    Default = 200,
    Callback = function(Value)
        getgenv().AimbotFOV = Value
    end
})

PvpTab:CreateToggle({
    Title = "Aimbot Prediction",
    Tooltip = "Predicts player movement",
    Default = true,
    Callback = function(Value)
        getgenv().AimbotPrediction = Value
    end
})

PvpTab:CreateSection("Movement")

PvpTab:CreateToggle({
    Title = "No Clip",
    Tooltip = "Walk through walls",
    Default = false,
    Callback = function(Value)
        getgenv().NoClip = Value
    end
})

PvpTab:CreateToggle({
    Title = "Infinite Stamina",
    Tooltip = "Never run out of stamina",
    Default = false,
    Callback = function(Value)
        getgenv().InfStamina = Value
    end
})

PvpTab:CreateToggle({
    Title = "Infinite Sky Jump",
    Tooltip = "Jump infinitely in the air",
    Default = false,
    Callback = function(Value)
        getgenv().InfSkyJump = Value
    end
})

PvpTab:CreateValidSlider({
    Title = "Dash length",
    Tooltip = "Changes your dash length",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(Value)
        getgenv().DashLength = Value
    end
})
--- -----------------------------------------------------------
--- VISUALS TAB 
--- -----------------------------------------------------------
VisualsTab:CreateSection("ESP Settings")

VisualsTab:CreateToggle({
    Title = "Player ESP",
    Tooltip = "Shows player boxes, names, health and distance",
    Default = false,
    Callback = function(Value)
        getgenv().PlayerESP = Value
    end
})
local PlayerESP = LoadModule("src/games/bloxfruits/gui/tabs/visuals/player_esp.lua")

VisualsTab:CreateToggle({
    Title = "Fruit ESP",
    Tooltip = "Shows fruits on the map",
    Default = false,
    Callback = function(Value)
        getgenv().FruitESP = Value
    end
})
local FruitESP = LoadModule("src/games/bloxfruits/gui/tabs/visuals/fruit_esp.lua")

VisualsTab:CreateToggle({
    Title = "Island ESP",
    Tooltip = "Shows all islands",
    Default = false,
    Callback = function(Value)
        getgenv().IslandESP = Value
    end
})
local IslandESP = LoadModule("src/games/bloxfruits/gui/tabs/visuals/island_esp.lua")

VisualsTab:CreateToggle({
    Title = "Berry/Flower ESP",
    Tooltip = "Shows Flowers (Blue/Red/Yellow)",
    Default = false,
    Callback = function(Value)
        getgenv().BerryESP = Value
    end
})
local BerryESP = LoadModule("src/games/bloxfruits/gui/tabs/visuals/berry_esp.lua")

VisualsTab:CreateToggle({
    Title = "Chest ESP",
    Tooltip = "Shows all chests",
    Default = false,
    Callback = function(Value)
        getgenv().ChestESP = Value
    end
})
local ChestESP = LoadModule("src/games/bloxfruits/gui/tabs/visuals/chest_esp.lua")

--- -----------------------------------------------------------
--- TELEPORT TAB 
--- -----------------------------------------------------------
TeleportTab:CreateSection("Teleport World")

local Seas = LoadModule("src/games/bloxfruits/gui/tabs/teleport/seas.lua")

TeleportTab:Create3Buttons({
    Buttons = {
        {
            Title = "Sea 1",
            Tooltip = "Teleport to First Sea",
            Callback = function()
                if Seas and Seas.TeleportToSea1 then Seas.TeleportToSea1() end
            end
        },
        {
            Title = "Sea 2",
            Tooltip = "Teleport to Second Sea",
            Callback = function()
                if Seas and Seas.TeleportToSea2 then Seas.TeleportToSea2() end
            end
        },
        {
            Title = "Sea 3",
            Tooltip = "Teleport to Third Sea",
            Callback = function()
                if Seas and Seas.TeleportToSea3 then Seas.TeleportToSea3() end
            end
        }
    }
})

TeleportTab:CreateSection("Teleport Islands")

local Islands = LoadModule("src/games/bloxfruits/gui/tabs/teleport/islands.lua")
local IslandOptions = Islands and Islands.IslandNames or {"Loading..."}
local SelectedIsland = IslandOptions[1]

TeleportTab:CreateDropdown({
    Title = "Islands",
    Tooltip = "Select an island",
    Options = IslandOptions,
    Default = IslandOptions[1],
    Callback = function(Value)
        SelectedIsland = Value
    end
})

TeleportTab:CreateButton({
    Title = "Start Tween",
    Tooltip = "Teleport to the selected island",
    Callback = function()
        if Islands and Islands.Teleport then
            Islands.Teleport(SelectedIsland)
        end
    end
})

TeleportTab:CreateSection("Teleport NPCs")

local NPCs = LoadModule("src/games/bloxfruits/gui/tabs/teleport/npc_tp.lua")
local NPCOptions = NPCs and NPCs.NPCNames or {"Loading..."}
local SelectedNPC = NPCOptions[1]

TeleportTab:CreateDropdown({
    Title = "NPCs",
    Tooltip = "Select an NPC",
    Options = NPCOptions,
    Default = NPCOptions[1],
    Callback = function(Value)        SelectedNPC = Value
    end
})

TeleportTab:CreateButton({
    Title = "Start Tween",
    Tooltip = "Teleport to the selected NPC",
    Callback = function()        if NPCs and NPCs.Teleport then
            NPCs.Teleport(SelectedNPC)
        end
    end
})

--- -----------------------------------------------------------
--- RAID TAB
--- -----------------------------------------------------------
RaidTab:CreateSection("Main Raid")

RaidTab:CreateDropdown({
    Title = "Select Raid",
    Tooltip = "Choose which raid to start",
    Options = {"Flame", "Ice", "Quake", "Light", "Dark", "Spider", "Rumble", "Magma", "Buddha", "Sand", "Dough"},
    Default = "Flame",
    Callback = function(Value)
        getgenv().SelectedRaid = Value
    end
})

RaidTab:CreateToggle({
    Title = "Auto Raid",
    Tooltip = "Starts and farms the selected raid",
    Callback = function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("RaidsNpc", "Select", getgenv().SelectedRaid or "Flame")
        end)
    end
})

RaidTab:CreateToggle({
    Title = "Force Kill Aura (Island 5)",
    Tooltip = "Enables force kill aura on Island 5",
    Default = false,
    Callback = function(Value)
        getgenv().ForceKillAura = Value
    end
})

RaidTab:CreateSection("Main Raid Settings")
RaidTab:CreateValidSlider({
    Title = "Max Fruit Value",
    Tooltip = "Maximum value of fruits to use for raids",
    Min = 100000,
    Max = 5000000,
    Default = 1000000,
    Callback = function(Value)
        getgenv().MaxFruitValue = Value
    end
})

RaidTab:CreateToggle({
    Title = "Auto Unstore Fruit",
    Tooltip = "Automatically unstores fruits from inventory",
    Default = false,
    Callback = function(Value)
        getgenv().AutoUnstoreFruit = Value
    end
})


--- -----------------------------------------------------------
--- SHOP TAB
--- -----------------------------------------------------------
ShopTab:CreateSection("Quick Shop Access")

ShopTab:CreateButton({
    Title = "Open Blox Fruit Dealer",
    Tooltip = "Opens the Blox Fruit shop menu",
    Callback = function()
        pcall(function()
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("GetBloxFruits")
        end)
    end
})

ShopTab:CreateButton({
    Title = "Open Ability Teacher",
    Tooltip = "Opens the Fighting Style shop",
    Callback = function()
        pcall(function()
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuySkill")
        end)
    end
})

--- -----------------------------------------------------------
--- FRUIT TAB
--- -----------------------------------------------------------
--- -----------------------------------------------------------
--- MISC TAB
--- -----------------------------------------------------------
MiscTab:CreateSection("Teleporters")

local AccessTeleporters = LoadModule("src/games/bloxfruits/gui/tabs/misc/access_teleporters.lua")
MiscTab:CreateButton({
    Title = "Unlock All Teleporters",
    Tooltip = "Unlocks all teleporter locations",
    Callback = function()
        if AccessTeleporters and AccessTeleporters.UnlockAll then
            AccessTeleporters.UnlockAll()
        end
    end
})

MiscTab:CreateSection("Movement")

local WalkOnWaterScript = LoadModule("src/games/bloxfruits/gui/tabs/misc/walk_on_water.lua")
MiscTab:CreateToggle({
    Title = "Walk on Water",
    Tooltip = "Walk on water and in the air",
    Default = true,
    Callback = function(Value)
        getgenv().WalkOnWater = Value
    end
})

MiscTab:CreateToggle({
    Title = "Fly",
    Tooltip = "Fly around the map (WASD to move, Space/Shift for up/down)",
    Default = false,
    Callback = function(Value)
        getgenv().Fly = Value
    end
})

MiscTab:CreateValidSlider({
    Title = "Fly Speed",
    Tooltip = nil,
    Min = 50,
    Max = 300,
    Default = 100,
    Callback = function(Value)
        getgenv().FlySpeed = Value
    end
})

MiscTab:CreateSection("Game Settings")

MiscTab:CreateToggle({
    Title = "Remove Fog",
    Tooltip = "Removes fog for better visibility",
    Default = false,
    Callback = function(Value)
        local Lighting = game:GetService("Lighting")
        if Value then
            Lighting.FogEnd = 100000
        else
            Lighting.FogEnd = 2500
        end
    end
})

MiscTab:CreateValidSlider({
    Title = "FOV",
    Tooltip = "Changes your field of view",
    Min = 70,
    Max = 120,
    Default = 70,
    Callback = function(Value)
        workspace.CurrentCamera.FieldOfView = Value
    end
})

MiscTab:CreateSection("Developer Tools")

MiscTab:CreateButton({
    Title = "Copy Position",
    Tooltip = "Copies your current position to clipboard (Vector3)",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            local str = string.format("Vector3.new(%.0f, %.0f, %.0f)", pos.X, pos.Y, pos.Z)
            setclipboard(str)
            
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Nyrox Hub",
                Text = "Position copied: " .. str,
                Duration = 3
            })
        end
    end
})

--- -----------------------------------------------------------
--- SETTINGS TAB 
--- -----------------------------------------------------------
SettingsTab:CreateSection("General")

SettingsTab:CreateDropdown({
    Title = "GUI Size",
    Tooltip = "Change the size of the script window",
    Options = {"Small", "Normal", "Large", "Extra Large"},
    Default = "Normal",
    Callback = function(Value)
        local ScriptSizeModule = LoadModule("src/games/bloxfruits/gui/tabs/settings/script_size.lua")
        if ScriptSizeModule and ScriptSizeModule.SetSize then
            ScriptSizeModule.SetSize(Value)
        end
    end
})

SettingsTab:CreateToggle({
    Title = "White Screen",
    Tooltip = nil,
    Default = false,
    Callback = function(Value)
        getgenv().WhiteScreen = Value
        local WhiteScreenScript = LoadModule("src/games/bloxfruits/gui/tabs/settings/white_screen.lua")
        if WhiteScreenScript and WhiteScreenScript.ToggleWhiteScreen then
            WhiteScreenScript.ToggleWhiteScreen(Value)
        end
    end
})

SettingsTab:CreateToggle({
    Title = "Low Graphics",
    Tooltip = "Reduces graphics quality to improve performance on lower-end devices",
    Default = false,
    Callback = function(Value)
        getgenv().LowGraphics = Value
        local LowGraphicsScript = LoadModule("src/games/bloxfruits/gui/tabs/settings/low_graphics.lua")
        if LowGraphicsScript and LowGraphicsScript.ToggleLowGraphics then
            LowGraphicsScript.ToggleLowGraphics(Value)
        end
    end
})

SettingsTab:CreateToggle({
    Title = "Anti AFK",
    Tooltip = "Prevents you from being kicked for being AFK",
    Default = true,
    Callback = function(Value)
        getgenv().AntiAFK = Value
        local AntiAFKScript = LoadModule("src/games/bloxfruits/gui/tabs/settings/anti_afk.lua")
        if AntiAFKScript and AntiAFKScript.ToggleAntiAFK then
            AntiAFKScript.ToggleAntiAFK(Value)
        end
    end
})
--- -----------------------------------------------------------
--- AUTO-START FEATURES
--- -----------------------------------------------------------
-- Auto-start Anti AFK if enabled
if getgenv().AntiAFK then
    local AntiAFKScript = LoadModule("src/games/bloxfruits/gui/tabs/settings/anti_afk.lua")
    if AntiAFKScript and AntiAFKScript.ToggleAntiAFK then
        AntiAFKScript.ToggleAntiAFK(true)
    end
end
