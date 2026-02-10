local WhiteScreen = {}
local ScreenName = "NyroxWhiteScreen"

function WhiteScreen.ToggleWhiteScreen(Value)
    local CoreGui = game:GetService("CoreGui")
    local ExistingGui = CoreGui:FindFirstChild(ScreenName)

    if Value then
        if not ExistingGui then
            local ScreenGui = Instance.new("ScreenGui")
            ScreenGui.Name = ScreenName
            ScreenGui.IgnoreGuiInset = true
            ScreenGui.DisplayOrder = -100 
            ScreenGui.Parent = CoreGui
            
            local Frame = Instance.new("Frame")
            Frame.Name = "WhiteFrame"
            Frame.Size = UDim2.new(1, 0, 1, 0)
            Frame.Position = UDim2.new(0, 0, 0, 0)
            Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Frame.BorderSizePixel = 0
            Frame.ZIndex = 1 
            Frame.Parent = ScreenGui

            local Label = Instance.new("TextLabel")
            Label.Text = "White Screen Mode (Saves CPU/GPU)"
            Label.Size = UDim2.new(0, 300, 0, 30)
            Label.Position = UDim2.new(0.5, -150, 0.5, -15)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(0, 0, 0)
            Label.TextSize = 20
            Label.Font = Enum.Font.SourceSansBold
            Label.Parent = Frame
        end
    else
        if ExistingGui then
            ExistingGui:Destroy()
        end
    end
end

return WhiteScreen
