local Library
if getgenv and getgenv().NyroxLib then
    Library = getgenv().NyroxLib
else
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/username/repo/main/src/lib/ui_library.lua"))() 
end

-- Set Running State True
getgenv().NyroxRunning = true

local Window = Library:CreateWindow({
    Title = "Nyrox Hub - FPS Flick",
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
local AimbotTab = Window:CreateTab("Aimbot")
local VisualsTab = Window:CreateTab("Visuals")
local SettingsTab = Window:CreateTab("Settings")

HomeTab:CreateSection("Welcome")
HomeTab:CreateLabel("Welcome to FPS Flick Script")
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

-- === AIMBOT TAB ===
local AimbotScript = LoadModule("src/games/fpsflick/gui/tabs/aimbot/aimbot.lua")

AimbotTab:CreateSection("Aimbot Settings")

AimbotTab:CreateToggle({
    Title = "Enable Aimbot",
    Default = false,
    Callback = function(Value)
        if AimbotScript and AimbotScript.SetEnabled then
            AimbotScript.SetEnabled(Value)
        end
    end
})

AimbotTab:CreateValidSlider({
    Title = "FOV Radius",
    Min = 10,
    Max = 500,
    Default = 100,
    Callback = function(Value)
        if AimbotScript and AimbotScript.SetFOV then
            AimbotScript.SetFOV(Value)
        end
    end
})

AimbotTab:CreateToggle({
    Title = "Show FOV Circle",
    Default = true,
    Callback = function(Value)
        if AimbotScript and AimbotScript.ToggleFOV then
            AimbotScript.ToggleFOV(Value)
        end
    end
})

AimbotTab:CreateToggle({
    Title = "Enable Wall Check",
    Default = true,
    Callback = function(Value)
        if AimbotScript and AimbotScript.ToggleWallCheck then
            AimbotScript.ToggleWallCheck(Value)
        end
    end
})

-- === SETTINGS TAB ===
SettingsTab:CreateSection("UI Settings")
SettingsTab:CreateToggle({
    Title = "Toggle White Screen",
    Default = false,
    Callback = function(Value)
        local SettingsScript = LoadModule("src/games/fpsflick/gui/tabs/settings/white_screen.lua") 
        if SettingsScript and SettingsScript.ToggleWhiteScreen then
            SettingsScript.ToggleWhiteScreen(Value)
        else
             warn("White Screen module not found for FPS Flick")
        end
    end
})

return Window
