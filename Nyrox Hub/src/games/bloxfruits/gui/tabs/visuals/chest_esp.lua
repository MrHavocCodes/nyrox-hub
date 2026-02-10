local Workspace = game:GetService("Workspace")
local CoreFunctions = getgenv().CoreFunctions

local ChestSettings = {
    ["silver"] = {Color = Color3.fromRGB(200, 200, 200), Label = "Silver"},
    ["gold"] = {Color = Color3.fromRGB(255, 215, 0), Label = "Gold"},
    ["diamond"] = {Color = Color3.fromRGB(0, 191, 255), Label = "Diamond"},
    ["bone"] = {Color = Color3.fromRGB(255, 240, 220), Label = "Bone"},
    ["candy"] = {Color = Color3.fromRGB(255, 105, 180), Label = "Candy"},
}

local function identifyChestInfo(name)
    local n = name:lower()
    if n:find("diamond") or n:find("chest3") then return ChestSettings["diamond"] end
    if n:find("gold") or n:find("chest2") then return ChestSettings["gold"] end
    if n:find("silver") or n:find("chest1") then return ChestSettings["silver"] end
    if n:find("bone") then return ChestSettings["bone"] end
    if n:find("candy") then return ChestSettings["candy"] end
    if n:find("chest") then return ChestSettings["silver"] end
    return nil
end

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
    
    local info = identifyChestInfo(model.Name)
    if not info then return end
    
    local ok, billboard = pcall(function()
        return CoreFunctions.CreateESP(part, {
            Name = info.Label .. " Chest", 
            Color = info.Color, 
            ShowDistance = true, 
            ShowName = true
        })
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
    if not getgenv().ChestESP then
        for m,b in pairs(Created) do pcall(function() CoreFunctions.RemoveESP(b) end) end
        Created = {}
        return
    end

    local success, err = pcall(function()
        local items = Workspace:GetDescendants()
        for i, v in ipairs(items) do
            if i % 500 == 0 then task.wait() end
            if v.Name:lower():find("chest") and (v:IsA("Model") or v:IsA("Part")) then
                createForModel(v)
            end
        end
    end)
    if not success then warn("ESP Refresh Error: " .. tostring(err)) end
end

Workspace.ChildAdded:Connect(function(child)
    task.wait(0.2)
    if getgenv().ChestESP then
        if child.Name:lower():find("chest") then createForModel(child) end
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
        task.wait(3)
    end
end)

return { Refresh = scan }
