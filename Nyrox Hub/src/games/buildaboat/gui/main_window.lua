local Library
if getgenv and getgenv().NyroxLib then
    Library = getgenv().NyroxLib
else
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/username/repo/main/src/lib/ui_library.lua"))() 
end

getgenv().NyroxRunning = true

local Window = Library:CreateWindow({
    Title = "Nyrox Hub - Build A Boat",
    SubTitle = "by L5ks8",
    OnClose = function()
        if getgenv().Import then
            local Settings = getgenv().Import("src/utils/script_settings.lua")
            if Settings then Settings.Cleanup() end
        end
    end
})

local function LoadModule(path)
    if getgenv().Import then
        return getgenv().Import(path)
    else
        warn("Import function not found via loader.")
        return {} 
    end
end

local HomeTab = Window:CreateTab("Home")
local FarmTab = Window:CreateTab("Farm")
local MiscTab = Window:CreateTab("Misc")
local SettingsTab = Window:CreateTab("Settings")

-- === CONFIGURATION DATA ===
local ConfigData = {
    AutoFarm = false,
    Fly = false,
    FlySpeed = 50,
    Chest = "Common Chest",
    AutoChest = false,
    WaterGod = false,
    WalkSpeedEnabled = false,
    WalkSpeed = 16,
    WhiteScreen = false
}

local UIControllers = {}

-- === HOME TAB ===
HomeTab:CreateSection("Welcome")
HomeTab:CreateLabel("Welcome to Build A Boat Script")
HomeTab:CreateButton({
    Title = "Join Discord Server",
    Callback = function()
        setclipboard("https://discord.gg/9SKA7sYg")
        game.StarterGui:SetCore("SendNotification", {
            Title = "Nyrox Hub";
            Text = "Discord Link copied to clipboard!";
            Duration = 5;
        })
    end
})

-- === FARM TAB ===
local AutoFarmScript = LoadModule("src/games/buildaboat/gui/tabs/farms/auto_farm.lua")

FarmTab:CreateSection("Auto Farm")

UIControllers.AutoFarm = FarmTab:CreateToggle({
    Title = "Enable Auto Farm",
    Default = false,
    Callback = function(Value)
        ConfigData.AutoFarm = Value
        if AutoFarmScript and AutoFarmScript.ToggleAutoFarm then
            AutoFarmScript.ToggleAutoFarm(Value)
        end
    end
})

-- === MISC TAB ===
local FlyScript = LoadModule("src/games/buildaboat/gui/tabs/misc/fly.lua")
local ChestScript = LoadModule("src/games/buildaboat/gui/tabs/misc/chest_opener.lua")
local WaterGodScript = LoadModule("src/games/buildaboat/gui/tabs/misc/water_god.lua")
local WalkSpeedScript = LoadModule("src/games/buildaboat/gui/tabs/misc/walkspeed.lua")

MiscTab:CreateSection("Character")

UIControllers.WaterGod = MiscTab:CreateToggle({
    Title = "Water God Mode",
    Default = false,
    Callback = function(Value)
        ConfigData.WaterGod = Value
        if WaterGodScript and WaterGodScript.Toggle then
            WaterGodScript.Toggle(Value)
        end
    end
})

UIControllers.WalkSpeedEnabled = MiscTab:CreateToggle({
    Title = "Enable WalkSpeed",
    Default = false,
    Callback = function(Value)
        ConfigData.WalkSpeedEnabled = Value
        if WalkSpeedScript and WalkSpeedScript.Toggle then
            WalkSpeedScript.Toggle(Value)
        end
    end
})

UIControllers.WalkSpeed = MiscTab:CreateValidSlider({
    Title = "Walk Speed",
    Min = 16,
    Max = 300,
    Default = 16,
    Callback = function(Value)
         ConfigData.WalkSpeed = Value
         if WalkSpeedScript and WalkSpeedScript.SetSpeed then
             WalkSpeedScript.SetSpeed(Value)
         end
    end
})

MiscTab:CreateSection("Fly Settings")

UIControllers.Fly = MiscTab:CreateToggle({
    Title = "Enable Fly",
    Default = false,
    Callback = function(Value)
        ConfigData.Fly = Value
        if FlyScript and FlyScript.ToggleFly then
             FlyScript.ToggleFly(Value)
        end
    end
})

UIControllers.FlySpeed = MiscTab:CreateValidSlider({
    Title = "Fly Speed",
    Min = 10,
    Max = 300,
    Default = 50,
    Callback = function(Value)
         ConfigData.FlySpeed = Value
         if FlyScript and FlyScript.SetFlySpeed then
             FlyScript.SetFlySpeed(Value)
         end
    end
})

MiscTab:CreateSection("Chest Opener")

UIControllers.Chest = MiscTab:CreateDropdown({
    Title = "Select Chest",
    Default = "Common Chest",
    Options = {"Common Chest", "Uncommon Chest", "Rare Chest", "Epic Chest", "Legendary Chest"},
    Callback = function(Option)
        ConfigData.Chest = Option
        if ChestScript and ChestScript.SetChest then
            ChestScript.SetChest(Option)
        end
    end
})

UIControllers.AutoChest = MiscTab:CreateToggle({
    Title = "Auto Open Chest",
    Default = false,
    Callback = function(Value)
        ConfigData.AutoChest = Value
        if ChestScript and ChestScript.ToggleAutoOpen then
            ChestScript.ToggleAutoOpen(Value)
        end
    end
})


-- === SETTINGS TAB ===
SettingsTab:CreateSection("Configuration System")

local ConfigSystem = LoadModule("src/games/buildaboat/gui/tabs/settings/config_system.lua")
local ConfigNameInput = ""

SettingsTab:CreateButton({
    Title = "Refresh Config List",
    Callback = function()
        if ConfigSystem and UIControllers.ConfigDropdown then
            local configs = ConfigSystem.GetConfigs()
            UIControllers.ConfigDropdown:Refresh(configs)
        end
    end
})

UIControllers.ConfigDropdown = SettingsTab:CreateDropdown({
    Title = "Select Config",
    Default = "Select...",
    Options = ConfigSystem and ConfigSystem.GetConfigs() or {},
    Callback = function(Option)
        ConfigNameInput = Option
    end
})

SettingsTab:CreateButton({
    Title = "Load Config",
    Callback = function()
        if ConfigSystem and ConfigNameInput ~= "" and ConfigNameInput ~= "Select..." then
            local data = ConfigSystem.LoadConfig(ConfigNameInput)
            if data then
                -- Restore Settings
                if UIControllers.AutoFarm and data.AutoFarm ~= nil then UIControllers.AutoFarm.Set(data.AutoFarm) end
                if UIControllers.Fly and data.Fly ~= nil then UIControllers.Fly.Set(data.Fly) end
                if UIControllers.FlySpeed and data.FlySpeed ~= nil then UIControllers.FlySpeed.Set(data.FlySpeed) end
                if UIControllers.Chest and data.Chest then UIControllers.Chest.Set(data.Chest) end
                if UIControllers.AutoChest and data.AutoChest ~= nil then UIControllers.AutoChest.Set(data.AutoChest) end
                if UIControllers.WaterGod and data.WaterGod ~= nil then UIControllers.WaterGod.Set(data.WaterGod) end
                if UIControllers.WalkSpeedEnabled and data.WalkSpeedEnabled ~= nil then UIControllers.WalkSpeedEnabled.Set(data.WalkSpeedEnabled) end
                if UIControllers.WalkSpeed and data.WalkSpeed ~= nil then UIControllers.WalkSpeed.Set(data.WalkSpeed) end
                if UIControllers.WhiteScreen and data.WhiteScreen ~= nil then UIControllers.WhiteScreen.Set(data.WhiteScreen) end
                
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Nyrox Hub",
                    Text = "Config Loaded: " .. ConfigNameInput,
                    Duration = 5
                })
            end
        end
    end
})

-- We need a Textbox input for creating new configs. 
-- Assuming UI Library supports CreateTextbox, but it wasn't in my quick read. 
-- I'll use a Button approach with a generated name if input is hard, OR check library again.
-- Let's check library briefly.

SettingsTab:CreateSection("Save Config")

-- Placeholder for input (Standard UI Lib usually has it, I'll add if missing)
-- For now, saving current selected is easiest, or just "default".
-- Let's try adding CreateInput to library if not there, BUT for now I'll create a simple "Save as 'ConfigNameInput'"
-- If ConfigNameInput is empty, I'll prompt (or just fail).

SettingsTab:CreateButton({
    Title = "Save Config (Overwrite Selected)",
    Callback = function()
        if ConfigSystem and ConfigNameInput ~= "" and ConfigNameInput ~= "Select..." then
             ConfigSystem.SaveConfig(ConfigNameInput, ConfigData)
             game.StarterGui:SetCore("SendNotification", {
                Title = "Nyrox Hub",
                Text = "Config Saved: " .. ConfigNameInput,
                Duration = 5
            })
             -- Refresh list
             if UIControllers.ConfigDropdown then
                UIControllers.ConfigDropdown:Refresh(ConfigSystem.GetConfigs())
             end
        else
             warn("No config selected to overwrite.")
        end
    end
})

-- Temporary: Create New Config Button
SettingsTab:CreateButton({
    Title = "Create New 'Default' Config",
    Callback = function()
        if ConfigSystem then
             ConfigSystem.SaveConfig("Default", ConfigData)
             if UIControllers.ConfigDropdown then
                UIControllers.ConfigDropdown:Refresh(ConfigSystem.GetConfigs())
             end
             game.StarterGui:SetCore("SendNotification", {
                Title = "Nyrox Hub",
                Text = "Created Default Config",
                Duration = 5
            })
        end
    end
})

SettingsTab:CreateSection("UI Settings")
UIControllers.WhiteScreen = SettingsTab:CreateToggle({
    Title = "Toggle White Screen",
    Default = false,
    Callback = function(Value)
        ConfigData.WhiteScreen = Value
        -- Assuming we reuse the one from FPS Flick or Blox Fruits or move it to utils
        -- For now, I'll refer to a generic location or duplicate if needed. 
        -- Based on file list, fpsflick/gui/tabs/settings/white_screen.lua exists.
        -- Ideally this should be in src/utils/ or similar if shared.
        -- I'll try to load it from fpsflick path if common utils are not separate, or just create one locally later.
        local SettingsScript = LoadModule("src/games/fpsflick/gui/tabs/settings/white_screen.lua") 
        if SettingsScript and SettingsScript.ToggleWhiteScreen then
            SettingsScript.ToggleWhiteScreen(Value)
        end
    end
})

return Window
