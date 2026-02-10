local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Safe environment access
local function GetEnv()
    if type(getgenv) == "function" then
        return getgenv()
    end
    return shared
end

local env = GetEnv()

local AlivePlayers = {}

function AlivePlayers.Get()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                table.insert(list, player.Name)
            end
        end
    end
    return list
end

function AlivePlayers.StartAutoRefresh(Dropdown)
    task.spawn(function()
        while env.NyroxRunning do
            if Dropdown and Dropdown.Refresh then
                Dropdown:Refresh(AlivePlayers.Get())
            end
            task.wait(2)
        end
    end)
end

return AlivePlayers