local ScriptSize = {}

local TweenService = game:GetService("TweenService")

local sizePresets = {
    ["Small"] = {width = 440, height = 280},
    ["Normal"] = {width = 550, height = 350},
    ["Large"] = {width = 660, height = 420},
    ["Extra Large"] = {width = 770, height = 490}
}

function ScriptSize.SetSize(sizeName)
    local preset = sizePresets[sizeName]
    if not preset then
        warn("Invalid size preset: " .. tostring(sizeName))
        return
    end
    
    -- Find MainFrame
    local coreGui = game:GetService("CoreGui")
    local nyroxHub = coreGui:FindFirstChild("NyroxHub")
    if not nyroxHub then
        warn("NyroxHub ScreenGui not found")
        return
    end
    
    local mainFrame = nyroxHub:FindFirstChild("MainFrame")
    if not mainFrame then
        warn("MainFrame not found")
        return
    end
    
    -- Calculate centered position
    local halfWidth = preset.width / 2
    local halfHeight = preset.height / 2
    
    local newSize = UDim2.new(0, preset.width, 0, preset.height)
    local newPosition = UDim2.new(0.5, -halfWidth, 0.5, -halfHeight)
    
    -- Check if window is minimized
    local topBar = mainFrame:FindFirstChild("TopBar")
    local isMinimized = false
    if topBar then
        local currentHeight = mainFrame.Size.Y.Offset
        if currentHeight < 100 then -- Minimized state
            isMinimized = true
        end
    end
    
    -- Animate the change
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    if isMinimized then
        -- Only change width when minimized, keep height at 40
        TweenService:Create(mainFrame, tweenInfo, {
            Size = UDim2.new(0, preset.width, 0, 40),
            Position = UDim2.new(0.5, -halfWidth, 0.5, -20)
        }):Play()
    else
        TweenService:Create(mainFrame, tweenInfo, {
            Size = newSize,
            Position = newPosition
        }):Play()
    end
    
    -- Store the current size preset for minimize/maximize functionality
    getgenv().NyroxCurrentSize = {
        width = preset.width,
        height = preset.height,
        name = sizeName
    }
end

return ScriptSize
