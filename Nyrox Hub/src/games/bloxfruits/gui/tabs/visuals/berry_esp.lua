local Workspace = game:GetService("Workspace")
local CoreFunctions = getgenv().CoreFunctions

local Targets = {
    ["Flower1"] = {Color = Color3.fromRGB(0, 0, 255), Label = "Blue Flower"},
    ["Flower2"] = {Color = Color3.fromRGB(255, 0, 0), Label = "Red Flower"},
    ["Flower3"] = {Color = Color3.fromRGB(255, 255, 0), Label = "Yellow Flower"},
    ["Money"] = {Color = Color3.fromRGB(50, 205, 50), Label = "Beli Drop"}, -- Green
    ["Beli"] = {Color = Color3.fromRGB(50, 205, 50), Label = "Beli Drop"},
    ["MirageIsland"] = {Color = Color3.fromRGB(255, 0, 255), Label = "Mirage"}, -- Just in case
}

local Created = {} -- model -> billboard

local function getMainPart(model)
    if not model then return nil end
    if model:IsA("BasePart") then return model end
    return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
end

local function createForModel(model)
    if not model or not model.Parent then return end
    if Created[model] then return end
    local part = getMainPart(model)
    if not part then return end
    local key = model.Name
    local info = Targets[model.Name]
    if not info then
        if model.Name:find("Flower1") then info = Targets["Flower1"] end
        if model.Name:find("Flower2") then info = Targets["Flower2"] end
        if model.Name:find("Flower3") then info = Targets["Flower3"] end
    end
    if not info then return end
    local ok, billboard = pcall(function()
        return CoreFunctions.CreateESP(part, {Name = info.Label, Color = info.Color, ShowDistance = true, ShowName = true})
    end)
    if ok and billboard then
        Created[model] = billboard
        model.AncestryChanged:Connect(function(_, parent)
            if not parent and Created[model] then
                pcall(function() CoreFunctions.RemoveESP(Created[model]) end)
                Created[model] = nil
            end
        end)
    end
end

local function scan()
    if not getgenv().BerryESP then
        for m,b in pairs(Created) do pcall(function() CoreFunctions.RemoveESP(b) end) end
        Created = {}
        return
    end

    for _, v in ipairs(Workspace:GetChildren()) do
        if Targets[v.Name] or v.Name:find("Flower") then
            createForModel(v)
        end
    end
end

Workspace.ChildAdded:Connect(function(child)
    task.wait(0.2)
    if getgenv().BerryESP then
        if Targets[child.Name] or child.Name:find("Flower") then
            createForModel(child)
        end
    end
end)

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
