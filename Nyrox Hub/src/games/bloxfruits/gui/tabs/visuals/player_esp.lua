local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local ESP_HOLDER_NAME = "NyroxPlayerESP_Holder"

-- Cleanup old holder
if CoreGui:FindFirstChild(ESP_HOLDER_NAME) then
    CoreGui:FindFirstChild(ESP_HOLDER_NAME):Destroy()
end

local Holder = Instance.new("Folder")
Holder.Name = ESP_HOLDER_NAME
Holder.Parent = CoreGui

local function GetTeamColor(player)
    if player.Team then
        return player.TeamColor.Color
    end
    return Color3.fromRGB(255, 255, 255)
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local function AddESP()
        local char = player.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local humanoid = char:FindFirstChild("Humanoid")
        
        if not hrp or not head or not humanoid then return end
        
        -- Prevent duplicates
        if Holder:FindFirstChild(player.Name) then
            Holder:FindFirstChild(player.Name):Destroy()
        end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = player.Name
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = Holder
        
        -- Name Label
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = billboard
        nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.DisplayName
        nameLabel.TextColor3 = GetTeamColor(player)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextSize = 12
        nameLabel.Font = Enum.Font.GothamBold
        
        -- Health Label
        local hpLabel = Instance.new("TextLabel")
        hpLabel.Parent = billboard
        hpLabel.Position = UDim2.new(0, 0, 0.4, 0)
        hpLabel.Size = UDim2.new(1, 0, 0.3, 0)
        hpLabel.BackgroundTransparency = 1
        hpLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        hpLabel.TextStrokeTransparency = 0
        hpLabel.TextSize = 10
        hpLabel.Font = Enum.Font.Gotham
        
        -- Distance Label
        local distLabel = Instance.new("TextLabel")
        distLabel.Parent = billboard
        distLabel.Position = UDim2.new(0, 0, 0.7, 0)
        distLabel.Size = UDim2.new(1, 0, 0.3, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        distLabel.TextStrokeTransparency = 0
        distLabel.TextSize = 10
        distLabel.Font = Enum.Font.Gotham
        
        -- Box ESP Use Highlights for modern look
        local highlight = Instance.new("Highlight")
        highlight.Name = player.Name .. "_Highlight"
        highlight.Adornee = char
        highlight.FillColor = GetTeamColor(player)
        highlight.FillTransparency = 0.8
        highlight.OutlineColor = GetTeamColor(player)
        highlight.OutlineTransparency = 0.2
        highlight.Parent = Holder
        
        -- Update Loop
        task.spawn(function()
            while player.Parent and char.Parent and billboard.Parent do
                if humanoid then
                    local hp = math.floor(humanoid.Health)
                    local maxHp = math.floor(humanoid.MaxHealth)
                    hpLabel.Text = "HP: " .. hp .. " / " .. maxHp
                end
                
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                    distLabel.Text = string.format("[%.0f m]", dist)
                end
                 task.wait(0.1)
            end
            if billboard then billboard:Destroy() end
            if highlight then highlight:Destroy() end
        end)
    end
    
    AddESP()
    player.CharacterAdded:Connect(AddESP)
end

-- Init
local function RefreshESP()
    if not getgenv().PlayerESP then
        Holder:ClearAllChildren()
        return
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        CreateESP(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if getgenv().PlayerESP then
        CreateESP(p)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if Holder:FindFirstChild(p.Name) then
        Holder:FindFirstChild(p.Name):Destroy()
    end
    if Holder:FindFirstChild(p.Name .. "_Highlight") then
        Holder:FindFirstChild(p.Name .. "_Highlight"):Destroy()
    end
end)

-- Loop Monitor
task.spawn(function()
    while true do
        if not getgenv().NyroxRunning then 
            Holder:Destroy()
            break 
        end
        
        if getgenv().PlayerESP then
            -- Verify if highlights are missing (sometimes removed by death)
            for _, p in ipairs(Players:GetPlayers()) do
                 if p ~= LocalPlayer and p.Character and not Holder:FindFirstChild(p.Name) then
                     CreateESP(p)
                 end
            end
        else
            Holder:ClearAllChildren()
        end
        
        task.wait(1)
    end
end)

return { Refresh = RefreshESP }
