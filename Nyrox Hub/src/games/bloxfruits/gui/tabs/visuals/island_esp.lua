local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local ESP_HOLDER_NAME = "NyroxIslandESP_Holder"

local Holder = Instance.new("Folder")
Holder.Name = ESP_HOLDER_NAME
Holder.Parent = CoreGui

local function CreateIslandESP(part, name)
    if Holder:FindFirstChild(name) then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = name
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 20, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = Holder
    
    -- Simple Text Label (No Frame/Box)
    local label = Instance.new("TextLabel")
    label.Parent = billboard
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(34, 139, 34) -- Forest Green
    label.TextStrokeTransparency = 0 -- Strong Outline
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBlack
    
    local distLabel = Instance.new("TextLabel")
    distLabel.Parent = billboard
    distLabel.Position = UDim2.new(0, 0, 0.8, 0)
    distLabel.Size = UDim2.new(1, 0, 0.2, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distLabel.TextStrokeTransparency = 0
    distLabel.TextSize = 12
    distLabel.Font = Enum.Font.GothamBold
    
    task.spawn(function()
        while billboard.Parent do
             if not getgenv().IslandESP then
                if billboard then billboard:Destroy() end
                break
             end
             
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude
                distLabel.Text = string.format("%.0f m", dist)
                billboard.Enabled = dist < 25000 
            end
            task.wait(1)
        end
    end)
end

local function ScanIslands()
    if not getgenv().IslandESP then
        Holder:ClearAllChildren()
        return
    end

    -- Attempt 1: Look for Locations folder
    if Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations") then
        local locations = Workspace._WorldOrigin.Locations
        for _, loc in ipairs(locations:GetChildren()) do
            CreateIslandESP(loc, loc.Name)
        end
    elseif Workspace:FindFirstChild("Map") then
        -- Attempt Scan Map folder directly (Sea 1/Sea 2 common structure)
        -- Looking for sub-folders/models that are islands
        for _, v in ipairs(Workspace.Map:GetChildren()) do
             if v:FindFirstChild("SpawnLocation") then
                  CreateIslandESP(v, v.Name)
             end
        end
    end
    
    -- Additional Sea 2/3 Checks
    if Workspace:FindFirstChild("Island") then
        for _, loc in ipairs(Workspace.Island:GetChildren()) do
             CreateIslandESP(loc, loc.Name)
        end
    end
    
    -- Attempt 3: Floating Turtle / Sea 3 structures
    if Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Turtle") then
        CreateIslandESP(Workspace.Map.Turtle, "Floating Turtle")
    end
end

-- Refresh loop
task.spawn(function()
    while true do
        if not getgenv().NyroxRunning then 
            Holder:Destroy()
            break 
        end
        
        if getgenv().IslandESP then
            ScanIslands()
            task.wait(3) 
        else
            Holder:ClearAllChildren()
            task.wait(0.5) -- Check fast so it turns on instantly
        end
    end
end)

return { Refresh = ScanIslands }
