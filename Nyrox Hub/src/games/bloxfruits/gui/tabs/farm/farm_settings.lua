local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Safe environment access
local function GetEnv()
    if type(getgenv) == "function" then
        return getgenv()
    end
    return shared
end

local env = GetEnv()
local LocalPlayer = Players.LocalPlayer

local WeaponSelect = {}

-- KOMPLETTE LISTE aller Blox Fruits Waffen
local WeaponLists = {
    ["Melee"] = {
        "Combat",
        "Black Leg",
        "Electro",
        "Fishman Karate",
        "Dragon Claw",
        "Superhuman",
        "Death Step",
        "Sharkman Karate",
        "Electric Claw",
        "Dragon Talon",
        "Godhuman",
        "Sanguine Art"
    },
    
    ["Sword"] = {
        "Katana",
        "Cutlass",
        "Dual Katana",
        "Iron Mace",
        "Triple Katana",
        "Pipe",
        "Bisento",
        "Dual-Headed Blade",
        "Soul Cane",
        "Trident",
        "Pole (1st Form)",
        "Saber",
        "Longsword",
        "Wando",
        "Shisui",
        "True Triple Katana",
        "Saddi",
        "Rengoku",
        "Canvander",
        "Dark Blade",
        "Yama",
        "Tushita",
        "Cursed Dual Katana",
        "Hallow Scythe",
        "Dragon Trident"
    },
    
    ["Gun"] = {
        "Flintlock",
        "Musket",
        "Refined Flintlock",
        "Slingshot",
        "Refined Slingshot",
        "Cannon",
        "Kabucha",
        "Bizarre Rifle",
        "Soul Guitar"
    },
    
    ["Blox Fruit"] = {
        "Rocket",
        "Spin",
        "Chop",
        "Spring",
        "Bomb",
        "Smoke",
        "Spike",
        "Flame",
        "Falcon",
        "Ice",
        "Sand",
        "Dark",
        "Diamond",
        "Light",
        "Rubber",
        "Barrier",
        "Ghost",
        "Magma",
        "Quake",
        "Buddha",
        "Love",
        "Spider",
        "Sound",
        "Phoenix",
        "Portal",
        "Rumble",
        "Pain",
        "Blizzard",
        "Gravity",
        "Mammoth",
        "T-Rex",
        "Dough",
        "Shadow",
        "Venom",
        "Control",
        "Spirit",
        "Dragon",
        "Leopard",
        "Kitsune"
    }
}

-- Findet eine Waffe basierend auf dem Attack Method
local function FindWeapon(weaponType)
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local backpack = LocalPlayer.Backpack
    local weaponList = WeaponLists[weaponType]
    
    if not weaponList then return nil end
    
    -- Prüfe ob bereits equipped
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            for _, weaponName in pairs(weaponList) do
                if string.find(tool.Name, weaponName) then
                    return tool
                end
            end
        end
    end
    
    -- Suche im Backpack
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, weaponName in pairs(weaponList) do
                if string.find(tool.Name, weaponName) then
                    return tool
                end
            end
        end
    end
    
    return nil
end

-- Equippt eine Waffe
local function EquipWeapon(weapon)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    -- Wenn Waffe im Character ist, ist sie bereits equipped
    if weapon.Parent == character then
        return true
    end
    
    -- Equippe Waffe aus Backpack
    pcall(function()
        humanoid:EquipTool(weapon)
    end)
    
    return true
end

-- Auto Aura / Buso Logic
local lastAuraCheck = 0
local function AutoActivateAura()
    if tick() - lastAuraCheck < 1 then return end -- Check every 1 second
    lastAuraCheck = tick()
    
    if not env.AutoAura then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    -- Check if Haki is active (HasBuso child in Character)
    if not character:FindFirstChild("HasBuso") then
        pcall(function()
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
        end)
    end
end

local connection

function WeaponSelect.StartLoop()
    if connection then return end
    
    connection = RunService.Heartbeat:Connect(function()
        if not env.NyroxRunning then
            if connection then
                connection:Disconnect()
                connection = nil
            end
            return
        end
        
        -- Run Auto Aura Indepedently
        AutoActivateAura()

        -- Check if any farming mode is active (AutoFarm or AutoFarmNear)
        if env.AutoFarm or env.AutoFarmNear then
            local attackMethod = env.AttackMethod or "Melee"
            local weapon = FindWeapon(attackMethod)
            
            if weapon then
                local character = LocalPlayer.Character
                if character then
                    -- Prüfe, ob die Waffe bereits equipped ist
                    local equippedTool = character:FindFirstChildOfClass("Tool")
                    
                    if not equippedTool or equippedTool ~= weapon then
                        EquipWeapon(weapon)
                    end
                end
            end
        end
    end)
end

-- Manuelle Waffen-Auswahl
function WeaponSelect.EquipSpecific(weaponName)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local weapon = character:FindFirstChild(weaponName) or LocalPlayer.Backpack:FindFirstChild(weaponName)
    
    if weapon and weapon:IsA("Tool") then
        return EquipWeapon(weapon)
    end
    
    return false
end

-- Stoppt die Loop
function WeaponSelect.Stop()
    if connection then
        connection:Disconnect()
        connection = nil
    end
end

return WeaponSelect
