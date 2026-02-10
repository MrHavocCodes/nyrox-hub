local Library
if getgenv and getgenv().NyroxLib then
    Library = getgenv().NyroxLib
else
    -- Fallback path might be deep, but ideally we rely on NyroxLib being global
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/username/repo/main/src/lib/ui_library.lua"))() 
end

-- Set Running State True
getgenv().NyroxRunning = true

local Window = Library:CreateWindow({
    Title = "Nyrox Hub - Tap Simulator",
    SubTitle = "by L5ks8",
    OnClose = function()
        if getgenv().Import then
            local Settings = getgenv().Import("src/utils/script_settings.lua")
            if Settings then Settings.Cleanup() end
        end
    end
})

-- Helper Function to load modules (using Import function)
local function LoadModule(path)
    if getgenv().Import then
        return getgenv().Import(path)
    else
        warn("Import function not found via loader. Features might not work locally without loader.")
        return {} 
    end
end


local UpdatesTab = Window:CreateTab("Updates")
local HomeTab = Window:CreateTab("Home")
local SettingsTab = Window:CreateTab("Settings")


-- === UPDATES TAB ===
UpdatesTab:CreateSection("Community")
UpdatesTab:CreateButton({
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

UpdatesTab:CreateSection("Version 1.0.0")
UpdatesTab:CreateLabel("- Initial Release for Tap Simulator")
UpdatesTab:CreateLabel("- Added Glass UI Design")


-- === HOME TAB ===
HomeTab:CreateSection("Main Features")
HomeTab:CreateLabel("Coming Soon...")


-- === SETTINGS TAB ===
SettingsTab:CreateSection("UI Settings")

-- Note: White Screen script is currently located in bloxfruits folder. 
-- You might want to move it to src/utils/ or src/lib/ if you want to share it, or duplicate it.
-- For now, pointing to the existing one in bloxfruits if compatible, or commenting out.
SettingsTab:CreateToggle({
    Title = "Toggle White Screen",
    Default = false,
    Callback = function(Value)
        -- Ideally move white_screen.lua to a shared folder like src/gui/shared/ or src/lib/
        -- For now using the one we have or creating a new one in tapsimulator folder would be better practice.
        -- Let's assume we want to use a shared one or a local one.
        -- Using a local one for safety.
        local SettingsScript = LoadModule("src/games/tapsimulator/gui/tabs/settings/white_screen.lua") 
        if SettingsScript and SettingsScript.ToggleWhiteScreen then
            SettingsScript.ToggleWhiteScreen(Value)
        else
             warn("White Screen module not found for Tap Simulator")
        end
    end
})

return Window
