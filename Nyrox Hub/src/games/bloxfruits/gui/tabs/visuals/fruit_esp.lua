local Workspace = game:GetService("Workspace")
local CoreFunctions = getgenv().CoreFunctions

local Created = {} -- model -> billboard

local function getMainPart(model)
    if not model then return nil end
    if model:IsA("BasePart") then return model end
    local part = model:FindFirstChild("Handle") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    return part
end

local function createForModel(model)
    if not model or not model.Parent then return end
    if Created[model] then return end
    local part = getMainPart(model)
    if not part then return end
    local name = model.Name:gsub("Fruit", ""):gsub("%s+", " ")
    local ok, billboard = pcall(function()
        return CoreFunctions.CreateESP(part, {Name = name, Color = Color3.fromRGB(255,85,85), ShowDistance = true, ShowName = true})
    end)
    if ok and billboard then
        Created[model] = billboard
        -- cleanup when removed
        model.AncestryChanged:Connect(function(_, parent)
            if not parent and Created[model] then
                pcall(function() CoreFunctions.RemoveESP(Created[model]) end)
                Created[model] = nil
            end
        end)
    end
end

local function scan()
    if not getgenv().FruitESP then
        for m,b in pairs(Created) do pcall(function() CoreFunctions.RemoveESP(b) end) end
        Created = {}
        return
    end

    for _, item in ipairs(Workspace:GetChildren()) do
        if item:IsA("Tool") and (item.Name:match("Fruit") or item:FindFirstChild("Handle")) then
            createForModel(item)
        elseif (item:IsA("Model") or item:IsA("BasePart")) and item.Name:match("Fruit") then
            createForModel(item)
        end
    end
end

Workspace.ChildAdded:Connect(function(child)
    task.wait(0.2)
    if getgenv().FruitESP then
        if child:IsA("Tool") and (child.Name:match("Fruit") or child:FindFirstChild("Handle")) then
            createForModel(child)
        elseif (child:IsA("Model") or child:IsA("BasePart")) and child.Name:match("Fruit") then
            createForModel(child)
        end
    end
end)

-- Periodic scan
task.spawn(function()
    while true do
        if not getgenv().NyroxRunning then
            for m,b in pairs(Created) do pcall(function() CoreFunctions.RemoveESP(b) end) end
            Created = {}
            break
        end
        scan()
        task.wait(2)
    end
end)

return { Refresh = scan }
