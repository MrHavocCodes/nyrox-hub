local CoreFunctions = {}

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Variables
local LocalPlayer = Players.LocalPlayer

-- ========================================
-- FAST ATTACK REMOTES (FessHub Method)
-- ========================================

local FastAttackRemotes = {
    RegisterAttack = nil,
    RegisterHit = nil
}

pcall(function()
    local Modules = ReplicatedStorage:WaitForChild("Modules", 5)
    if Modules then
        local Net = Modules:FindFirstChild("Net")
        if Net then
            FastAttackRemotes.RegisterAttack = Net:FindFirstChild("RE/RegisterAttack") or Net:FindFirstChild("RegisterAttack")
            FastAttackRemotes.RegisterHit = Net:FindFirstChild("RE/RegisterHit") or Net:FindFirstChild("RegisterHit")
            
            if FastAttackRemotes.RegisterAttack and FastAttackRemotes.RegisterHit then
                print("[CoreFunctions] ✅ Fast Attack Remotes found!")
            end
        end
    end
end)

-- Auto Haki
spawn(function()
    while wait(2) do
        pcall(function()
            if not LocalPlayer.Character:FindFirstChild("HasBuso") then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
            end
        end)
    end
end)

-- Simulation Radius for BringMobs
spawn(function()
    while wait() do
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            end
        end)
    end
end)

-- Noclip Loop
local NoclipConnection = nil

function CoreFunctions.GetCharacter()
    return LocalPlayer.Character
end

function CoreFunctions.GetHumanoidRootPart()
    local char = CoreFunctions.GetCharacter()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

function CoreFunctions.ToggleNoclip(state)
    if state then
        getgenv().Noclip = true
        if NoclipConnection then return end 
        NoclipConnection = RunService.Stepped:Connect(function()
            if not getgenv().Noclip then 
                if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
                return 
            end
            
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        getgenv().Noclip = false
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
    end
end

-- Safe Tween Function
function CoreFunctions.TweenToPosition(targetPosition, speed)
    local hrp = CoreFunctions.GetHumanoidRootPart()
    if not hrp then return nil, 0 end

    speed = speed or 300
    
    local distance = (targetPosition - hrp.Position).Magnitude
    local timeToTravel = distance / speed
    
    local tweenInfo = TweenInfo.new(
        timeToTravel,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPosition)})
    tween:Play()
    
    return tween, timeToTravel
end

-- ========================================
-- ATTACK SYSTEM (FessHub Method - WORKING!)
-- ========================================

-- Click function using VirtualInputManager (DISABLED - causes Observation toggle)
-- Note: "E" key toggles Observation Haki in Blox Fruits
local function Click()
    -- DISABLED: This was toggling Observation Haki
    -- pcall(function()
    --     VirtualInputManager:SendKeyEvent(true, "E", false, game)
    --     task.wait(0.01)
    --     VirtualInputManager:SendKeyEvent(false, "E", false, game)
    -- end)
end

-- Get nearby enemies for multi-hit
local function GetNearbyEnemies()
    local nearbyEnemies = {}
    local targetPart = nil
    
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local hrp = char.HumanoidRootPart
        local enemies = Workspace:FindFirstChild("Enemies")
        if not enemies then return end
        
        for _, enemy in pairs(enemies:GetChildren()) do
            local head = enemy:FindFirstChild("Head") or enemy:FindFirstChild("HumanoidRootPart")
            local hum = enemy:FindFirstChild("Humanoid")
            
            if head and hum and hum.Health > 0 then
                local distance = (hrp.Position - head.Position).Magnitude
                if distance < 100 then
                    table.insert(nearbyEnemies, {enemy, head})
                    if not targetPart then
                        targetPart = head
                    end
                end
            end
        end
    end)
    
    return targetPart, nearbyEnemies
end

-- Fast Attack using Remotes (FessHub Method)
local function FastAttackRemote()
    pcall(function()
        if FastAttackRemotes.RegisterAttack and FastAttackRemotes.RegisterHit then
            local targetPart, nearbyEnemies = GetNearbyEnemies()
            
            if targetPart and #nearbyEnemies > 0 then
                FastAttackRemotes.RegisterAttack:FireServer(0.1)
                FastAttackRemotes.RegisterHit:FireServer(targetPart, nearbyEnemies)
            end
        end
    end)
end

-- Equip Weapon
function CoreFunctions.EquipWeapon(toolName)
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char.Parent then return end
        
        -- Already equipped?
        if char:FindFirstChild(toolName) then return end
        
        -- Equip from backpack
        local tool = LocalPlayer.Backpack:FindFirstChild(toolName)
        if tool then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:EquipTool(tool)
            end
        end
    end)
end

-- MAIN ATTACK FUNCTION (FessHub Style)
function CoreFunctions.Attack(weaponName)
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char.Parent then return end
        
        -- Equip weapon first
        if weaponName then
            CoreFunctions.EquipWeapon(weaponName)
        end
        
        -- Method 1: Fast Attack Remotes (PRIMARY - WORKING)
        if FastAttackRemotes.RegisterAttack and FastAttackRemotes.RegisterHit then
            FastAttackRemote()
        end
        
        -- Method 2: Tool Activate (Fallback)
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and tool.Activate then
            tool:Activate()
        end
    end)
end

-- Fast Attack wrapper
function CoreFunctions.FastAttack(weaponName)
    CoreFunctions.Attack(weaponName)
end

-- Bring Mobs to position
function CoreFunctions.BringMobs(targetPosition, range)
    range = range or 350
    
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local enemies = Workspace:FindFirstChild("Enemies")
        if not enemies then return end
        
        for _, mob in ipairs(enemies:GetChildren()) do
            if mob.Parent then
                local mobHRP = mob:FindFirstChild("HumanoidRootPart")
                local mobHum = mob:FindFirstChild("Humanoid")
                
                if mobHRP and mobHum and mobHum.Health > 0 then
                    local dist = (hrp.Position - mobHRP.Position).Magnitude
                    
                    if dist <= range then
                        mobHRP.CFrame = targetPosition
                        mobHRP.Velocity = Vector3.new(0, 0, 0)
                        mobHRP.CanCollide = false
                        mobHum.WalkSpeed = 0
                        mobHum.JumpPower = 0
                        
                        -- Destroy animator
                        if mobHum:FindFirstChild("Animator") then
                            mobHum.Animator:Destroy()
                        end
                        
                        -- Lock in position
                        mobHum:ChangeState(11)
                        mobHum:ChangeState(14)
                    end
                end
            end
        end
    end)
end

return CoreFunctions
