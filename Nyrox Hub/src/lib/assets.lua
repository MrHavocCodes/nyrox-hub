local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Assets = {}

-- Tooltip Management (Global to allow cleanup from outside)
local tooltipGui = nil
if not getgenv().currentTooltipText then
    getgenv().currentTooltipText = nil
end

local function getTooltipFrame()
    if not (tooltipGui and tooltipGui.Parent) then
        tooltipGui = game:GetService("CoreGui"):FindFirstChild("NyroxTooltipGui")
        if not tooltipGui then
            tooltipGui = Instance.new("ScreenGui")
            tooltipGui.Name = "NyroxTooltipGui"
            tooltipGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            tooltipGui.DisplayOrder = 999
            tooltipGui.Parent = game:GetService("CoreGui")
        end
    end

    local tooltipFrame = tooltipGui:FindFirstChild("TooltipFrame")
    if tooltipFrame then
        return tooltipFrame
    end

    tooltipFrame = Instance.new("Frame")
    tooltipFrame.Name = "TooltipFrame"
    tooltipFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    tooltipFrame.BackgroundTransparency = 0.2
    tooltipFrame.BorderSizePixel = 0
    tooltipFrame.Size = UDim2.fromOffset(0, 0)
    tooltipFrame.AutomaticSize = Enum.AutomaticSize.XY
    tooltipFrame.Visible = false
    tooltipFrame.ZIndex = 10
    tooltipFrame.Parent = tooltipGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = tooltipFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.8
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = tooltipFrame

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)
    padding.Parent = tooltipFrame

    local label = Instance.new("TextLabel")
    label.Name = "TooltipLabel"
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 13
    label.Text = ""
    label.AutomaticSize = Enum.AutomaticSize.XY
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 11
    label.Parent = tooltipFrame

    return tooltipFrame
end

if getgenv().NyroxTooltipConnection then
    getgenv().NyroxTooltipConnection:Disconnect()
    getgenv().NyroxTooltipConnection = nil
end

getgenv().NyroxTooltipConnection = RunService.RenderStepped:Connect(function()
    if getgenv().currentTooltipText then
        local tooltip = getTooltipFrame()
        local mousePos = UserInputService:GetMouseLocation()
        local targetPos = UDim2.fromOffset(mousePos.X + 20, mousePos.Y)
        local currentPos = tooltip.Position
        local lerp = 0.25

        tooltip.Position = UDim2.fromOffset(
            currentPos.X.Offset + (targetPos.X.Offset - currentPos.X.Offset) * lerp,
            currentPos.Y.Offset + (targetPos.Y.Offset - currentPos.Y.Offset) * lerp
        )
        
        local label = tooltip:FindFirstChild("TooltipLabel")
        if label then label.Text = getgenv().currentTooltipText end
        tooltip.Visible = true
    else
        if tooltipGui then
            local tooltip = tooltipGui:FindFirstChild("TooltipFrame")
            if tooltip then tooltip.Visible = false end
        end
    end
end)

function Assets.CreateSection(Parent, text)
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Name = "Section"
    SectionLabel.Parent = Parent
    SectionLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Size = UDim2.new(1, -20, 0, 30)
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.Text = text
    SectionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SectionLabel.TextSize = 14
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local SectionPadding = Instance.new("UIPadding")
    SectionPadding.Parent = SectionLabel
    SectionPadding.PaddingLeft = UDim.new(0, 5)
    
    return SectionLabel
end

function Assets.CreateLabel(Parent, text)
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Parent = Parent
    Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Font = Enum.Font.GothamMedium
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextWrapped = true
    
    Label.AutomaticSize = Enum.AutomaticSize.Y
    
    local LabelPadding = Instance.new("UIPadding")
    LabelPadding.Parent = Label
    LabelPadding.PaddingLeft = UDim.new(0, 10)
    LabelPadding.PaddingRight = UDim.new(0, 10)
    LabelPadding.PaddingTop = UDim.new(0, 5)
    LabelPadding.PaddingBottom = UDim.new(0, 5)
    
    return Label
end

function Assets.CreateImage(Parent, config)
    local ImageUrl = config.Image or ""
    local Height = config.Height or 120

    if ImageUrl == "" then return end

    local ImageFrame = Instance.new("Frame")
    ImageFrame.Name = "ImageFrame"
    ImageFrame.Parent = Parent
    ImageFrame.BackgroundTransparency = 1
    ImageFrame.Size = UDim2.new(1, -20, 0, Height)
    ImageFrame.ClipsDescendants = true

    local ImageLabel = Instance.new("ImageLabel")
    ImageLabel.Name = "BannerImage"
    ImageLabel.Parent = ImageFrame
    ImageLabel.BackgroundTransparency = 1
    ImageLabel.Size = UDim2.new(1, 0, 1, 0)
    ImageLabel.Image = ImageUrl
    ImageLabel.ScaleType = Enum.ScaleType.Fit
    
    return ImageFrame
end

function Assets.CreateToggle(Parent, config)
    local Title = config.Title or "Toggle"
    local Default = config.Default or false
    local Callback = config.Callback or function() end
    local TooltipText = config.Tooltip or nil

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "Toggle"
    ToggleFrame.Parent = Parent
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ToggleFrame.BackgroundTransparency = 0.5
    ToggleFrame.Size = UDim2.new(1, -20, 0, 40)
    
    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Parent = ToggleFrame
    ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
    ToggleStroke.Transparency = 0.9
    ToggleStroke.Thickness = 1

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Parent = ToggleFrame
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.Text = ""
    ToggleButton.ZIndex = 10

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = ToggleFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Font = Enum.Font.GothamMedium
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local SwitchBg = Instance.new("Frame")
    SwitchBg.Name = "SwitchBg"
    SwitchBg.Parent = ToggleFrame
    SwitchBg.BackgroundColor3 = Default and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(60, 60, 60)
    SwitchBg.Position = UDim2.new(1, -50, 0.5, -10)
    SwitchBg.Size = UDim2.new(0, 40, 0, 20)
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchBg
    
    local SwitchCircle = Instance.new("Frame")
    SwitchCircle.Name = "SwitchCircle"
    SwitchCircle.Parent = SwitchBg
    
    SwitchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SwitchCircle.Position = Default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    SwitchCircle.Size = UDim2.new(0, 16, 0, 16)
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = SwitchCircle

    if TooltipText then
        ToggleButton.MouseEnter:Connect(function()
            getgenv().currentTooltipText = TooltipText
        end)

        ToggleButton.MouseLeave:Connect(function()
            if getgenv().currentTooltipText == TooltipText then getgenv().currentTooltipText = nil end
        end)
    end

    local Toggled = Default

    ToggleButton.MouseButton1Click:Connect(function()
        Toggled = not Toggled
        if Toggled then
            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(52, 199, 89)}):Play()
            TweenService:Create(SwitchCircle, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
            TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
            TweenService:Create(SwitchCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
            TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        Callback(Toggled)
    end)
    
    return {
        Set = function(val)
            Toggled = val
            if Toggled then
                TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(52, 199, 89)}):Play()
                TweenService:Create(SwitchCircle, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
                TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
                TweenService:Create(SwitchCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
                TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            Callback(Toggled)
        end
    }
end

function Assets.CreateButton(Parent, config)
    local Title = config.Title or "Button"
    local Callback = config.Callback or function() end
    local TooltipText = config.Tooltip or nil

    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Name = "Button"
    ButtonFrame.Parent = Parent
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ButtonFrame.BackgroundTransparency = 0.5
    ButtonFrame.Size = UDim2.new(1, -20, 0, 40)
    
    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Parent = ButtonFrame
    ButtonStroke.Color = Color3.fromRGB(255, 255, 255)
    ButtonStroke.Transparency = 0.9
    ButtonStroke.Thickness = 1

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = ButtonFrame
    
    local Button = Instance.new("TextButton")
    Button.Parent = ButtonFrame
    Button.BackgroundTransparency = 1
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.Font = Enum.Font.GothamMedium
    Button.Text = Title
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.TextSize = 14
    Button.ZIndex = 10
    
    if TooltipText then
        Button.MouseEnter:Connect(function()
            getgenv().currentTooltipText = TooltipText
        end)
    end

    Button.MouseButton1Down:Connect(function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
    end)
    
    Button.MouseButton1Up:Connect(function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        Callback()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        if TooltipText then
            if getgenv().currentTooltipText == TooltipText then getgenv().currentTooltipText = nil end
        end
    end)
    
    return ButtonFrame
end

function Assets.Create3Buttons(Parent, config)
    local Buttons = config.Buttons or {}
    
    local Container = Instance.new("Frame")
    Container.Name = "3ButtonsContainer"
    Container.Parent = Parent
    Container.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Container.BackgroundTransparency = 0.5
    Container.Size = UDim2.new(1, -20, 0, 40)

    local ContainerStroke = Instance.new("UIStroke")
    ContainerStroke.Parent = Container
    ContainerStroke.Color = Color3.fromRGB(255, 255, 255)
    ContainerStroke.Transparency = 0.9
    ContainerStroke.Thickness = 1

    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 6)
    ContainerCorner.Parent = Container

    local ContainerPadding = Instance.new("UIPadding")
    ContainerPadding.Parent = Container
    ContainerPadding.PaddingLeft = UDim.new(0, 5)
    ContainerPadding.PaddingRight = UDim.new(0, 5)
    ContainerPadding.PaddingTop = UDim.new(0, 5)
    ContainerPadding.PaddingBottom = UDim.new(0, 5)

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = Container
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 5)

    for i = 1, 3 do
        local btnData = Buttons[i] or {}
        local Title = btnData.Title or "Button"
        local Callback = btnData.Callback or function() end
        local TooltipText = btnData.Tooltip or nil

        local ButtonFrame = Instance.new("Frame")
        ButtonFrame.Name = "Button" .. i
        ButtonFrame.Parent = Container
        ButtonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        ButtonFrame.BackgroundTransparency = 0.5
        ButtonFrame.Size = UDim2.new(0.333, -4, 1, 0)
        
        local ButtonStroke = Instance.new("UIStroke")
        ButtonStroke.Parent = ButtonFrame
        ButtonStroke.Color = Color3.fromRGB(255, 255, 255)
        ButtonStroke.Transparency = 0.9
        ButtonStroke.Thickness = 1

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 6)
        ButtonCorner.Parent = ButtonFrame
        
        local Button = Instance.new("TextButton")
        Button.Parent = ButtonFrame
        Button.BackgroundTransparency = 1
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.Font = Enum.Font.GothamMedium
        Button.Text = Title
        Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        Button.TextSize = 13
        Button.ZIndex = 10
        
        if TooltipText then
            Button.MouseEnter:Connect(function()
                getgenv().currentTooltipText = TooltipText
            end)
        end

        Button.MouseButton1Down:Connect(function()
            TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
        end)
        
        Button.MouseButton1Up:Connect(function()
            TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            Callback()
        end)

        Button.MouseLeave:Connect(function()
            TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            if TooltipText then
                if getgenv().currentTooltipText == TooltipText then getgenv().currentTooltipText = nil end
            end
        end)
    end
    
    return Container
end

function Assets.CreateValidSlider(Parent, config)
    local Title = config.Title or "Slider"
    local Min = config.Min or 0
    local Max = config.Max or 100
    local Default = config.Default or Min
    local Increment = config.Increment or 1
    local Callback = config.Callback or function() end
    local TooltipText = config.Tooltip or nil

    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = "Slider"
    SliderFrame.Parent = Parent
    SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SliderFrame.BackgroundTransparency = 0.5
    SliderFrame.Size = UDim2.new(1, -20, 0, 50)
    SliderFrame.Active = true

    local SliderStroke = Instance.new("UIStroke")
    SliderStroke.Parent = SliderFrame
    SliderStroke.Color = Color3.fromRGB(255, 255, 255)
    SliderStroke.Transparency = 0.9
    SliderStroke.Thickness = 1

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 6)
    SliderCorner.Parent = SliderFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = SliderFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 10, 0, 5)
    TitleLabel.Size = UDim2.new(0, 200, 0, 20)
    TitleLabel.Font = Enum.Font.GothamMedium
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Parent = SliderFrame
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Position = UDim2.new(1, -60, 0, 5)
    ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    ValueLabel.Font = Enum.Font.GothamMedium
    ValueLabel.Text = tostring(Default)
    ValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local SliderBar = Instance.new("Frame")
    SliderBar.Name = "SliderBar"
    SliderBar.Parent = SliderFrame
    SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SliderBar.Position = UDim2.new(0, 10, 0, 35)
    SliderBar.Size = UDim2.new(1, -20, 0, 4)
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = SliderBar

    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "SliderFill"
    SliderFill.Parent = SliderBar
    SliderFill.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
    SliderFill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill

    local TriggerButton = Instance.new("TextButton")
    TriggerButton.Parent = SliderBar
    TriggerButton.BackgroundTransparency = 1
    TriggerButton.Position = UDim2.new(0, 0, 0.5, -10)
    TriggerButton.Size = UDim2.new(1, 0, 0, 20)
    TriggerButton.Text = ""

    if TooltipText then
        SliderFrame.MouseEnter:Connect(function()
            getgenv().currentTooltipText = TooltipText
        end)

        SliderFrame.MouseLeave:Connect(function()
            if getgenv().currentTooltipText == TooltipText then getgenv().currentTooltipText = nil end
        end)
    end

    local dragging = false
    
    local function UpdateSlider(input)
        local pos = UDim2.new(math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1), 0, 1, 0)
        TweenService:Create(SliderFill, TweenInfo.new(0.1), {Size = pos}):Play()
        local rawValue = (pos.X.Scale * (Max - Min)) + Min
        local value = math.floor(rawValue / Increment + 0.5) * Increment
        value = math.clamp(value, Min, Max)
        ValueLabel.Text = tostring(value)
        Callback(value)
    end

    TriggerButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return {
        Set = function(val)
            local pos = UDim2.new((val - Min) / (Max - Min), 0, 1, 0)
            TweenService:Create(SliderFill, TweenInfo.new(0.1), {Size = pos}):Play()
            ValueLabel.Text = tostring(val)
            Callback(val)
        end
    }
end

function Assets.CreateDropdown(Parent, config)
    local Title = config.Title or "Dropdown"
    local Options = config.Options or {}
    local Default = config.Default or Options[1]
    local Callback = config.Callback or function() end
    local TooltipText = config.Tooltip or nil

    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = "Dropdown"
    DropdownFrame.Parent = Parent
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    DropdownFrame.BackgroundTransparency = 0.5
    DropdownFrame.Size = UDim2.new(1, -20, 0, 40)
    DropdownFrame.ClipsDescendants = true
    
    local DropdownStroke = Instance.new("UIStroke")
    DropdownStroke.Parent = DropdownFrame
    DropdownStroke.Color = Color3.fromRGB(255, 255, 255)
    DropdownStroke.Transparency = 0.9
    DropdownStroke.Thickness = 1

    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 6)
    DropdownCorner.Parent = DropdownFrame
    
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Parent = DropdownFrame
    DropdownBtn.BackgroundTransparency = 1
    DropdownBtn.Size = UDim2.new(1, 0, 0, 40)
    DropdownBtn.Text = ""
    DropdownBtn.ZIndex = 10

    if TooltipText then
        DropdownBtn.MouseEnter:Connect(function()
            getgenv().currentTooltipText = TooltipText
        end)

        DropdownFrame.MouseLeave:Connect(function()
            if getgenv().currentTooltipText == TooltipText then getgenv().currentTooltipText = nil end
        end)
    end
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = DropdownFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Size = UDim2.new(0, 150, 0, 40)
    TitleLabel.Font = Enum.Font.GothamMedium
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local SelectedLabel = Instance.new("TextLabel")
    SelectedLabel.Parent = DropdownFrame
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.Position = UDim2.new(1, -140, 0, 0)
    SelectedLabel.Size = UDim2.new(0, 100, 0, 40)
    SelectedLabel.Font = Enum.Font.GothamMedium
    SelectedLabel.Text = Default
    SelectedLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    SelectedLabel.TextSize = 14
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right

    local Arrow = Instance.new("TextLabel")
    Arrow.Parent = DropdownFrame
    Arrow.BackgroundTransparency = 1
    Arrow.Position = UDim2.new(1, -30, 0, 0)
    Arrow.Size = UDim2.new(0, 30, 0, 40)
    Arrow.Font = Enum.Font.GothamBold
    Arrow.Text = "v"
    Arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
    Arrow.TextSize = 14

    -- Search Bar Frame
    local SearchFrame = Instance.new("Frame")
    SearchFrame.Name = "SearchFrame"
    SearchFrame.Parent = DropdownFrame
    SearchFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SearchFrame.BackgroundTransparency = 0.5
    SearchFrame.Position = UDim2.new(0, 10, 0, 45)
    SearchFrame.Size = UDim2.new(1, -20, 0, 30)
    SearchFrame.Visible = false

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 4)
    SearchCorner.Parent = SearchFrame

    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Name = "Icon"
    SearchIcon.Parent = SearchFrame
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Position = UDim2.new(0, 8, 0.5, -8) -- Centered vertically better
    SearchIcon.Size = UDim2.new(0, 16, 0, 16)
    SearchIcon.Image = "rbxassetid://6031154871" -- Modern "Lucide" style thinner icon
    SearchIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)

    local SearchBar = Instance.new("TextBox")
    SearchBar.Name = "SearchBar"
    SearchBar.Parent = SearchFrame
    SearchBar.BackgroundTransparency = 1
    SearchBar.Position = UDim2.new(0, 32, 0, 0) -- Adjusted for new icon padding
    SearchBar.Size = UDim2.new(1, -35, 1, 0)
    SearchBar.Font = Enum.Font.GothamMedium
    SearchBar.PlaceholderText = "Search"
    SearchBar.Text = ""
    SearchBar.TextColor3 = Color3.fromRGB(200, 200, 200)
    SearchBar.PlaceholderColor3 = Color3.fromRGB(120, 120, 120) -- Darker placeholder
    SearchBar.TextSize = 13
    SearchBar.TextXAlignment = Enum.TextXAlignment.Left

    local OptionList = Instance.new("ScrollingFrame")
    OptionList.Parent = DropdownFrame
    OptionList.BackgroundTransparency = 1
    OptionList.Position = UDim2.new(0, 0, 0, 80)
    OptionList.Size = UDim2.new(1, 0, 1, -80)
    OptionList.ScrollBarThickness = 2
    OptionList.CanvasSize = UDim2.new(0, 0, 0, 0) -- Init to 0
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Parent = OptionList
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 5)

    local Padding = Instance.new("UIPadding")
    Padding.Parent = OptionList
    Padding.PaddingLeft = UDim.new(0, 10)
    
    local isOpened = false

    local function RefreshOptions(filterText)
        -- Clear existing
        for _, v in pairs(OptionList:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        
        local count = 0
        for _, opt in pairs(Options) do
            if not filterText or filterText == "" or string.find(string.lower(tostring(opt)), string.lower(filterText)) then
                count = count + 1
                local OptBtn = Instance.new("TextButton")
                OptBtn.Parent = OptionList
                OptBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                OptBtn.BackgroundTransparency = 0.5
                OptBtn.Size = UDim2.new(1, -10, 0, 30)
                OptBtn.Font = Enum.Font.GothamMedium
                OptBtn.Text = tostring(opt) -- Ensure string
                OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                OptBtn.TextSize = 14
                
                local OptCorner = Instance.new("UICorner")
                OptCorner.CornerRadius = UDim.new(0, 4)
                OptCorner.Parent = OptBtn
                
                OptBtn.MouseButton1Click:Connect(function()
                    isOpened = false
                    SelectedLabel.Text = tostring(opt)
                    SearchFrame.Visible = false
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -20, 0, 40)}):Play()
                    TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                    Callback(opt)
                end)
            end
        end
        
        -- Force Canvas Update Calculation immediately
        OptionList.CanvasSize = UDim2.new(0, 0, 0, (count * 35) + 5)
    end
    
    RefreshOptions()

    SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
        RefreshOptions(SearchBar.Text)
    end)

    DropdownBtn.MouseButton1Click:Connect(function()
        isOpened = not isOpened
        if isOpened then
                SearchBar.Text = ""
                SearchFrame.Visible = true
                RefreshOptions()
                local listHeight = math.min(#Options * 35 + 10, 150)
                TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -20, 0, 80 + listHeight)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 180}):Play()
        else
                SearchFrame.Visible = false
                TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -20, 0, 40)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
        end
    end)
    
    local DropdownObject = {}
    function DropdownObject:Refresh(NewOptions)
        Options = NewOptions or Options
        RefreshOptions()
    end
    function DropdownObject:Set(option)
        SelectedLabel.Text = option
        Callback(option)
    end
    
    return DropdownObject
end

-- ========================================
-- CHAT INPUT BOX WITH SEND BUTTON
-- ========================================
function Assets.CreateChatBox(parent, config)
    local Title = config.Title or "Chat"
    local Placeholder = config.Placeholder or "Type your message..."
    local SendCallback = config.OnSend or function(text) end
    local MaxHeight = config.MaxHeight or 150

    -- Main Container
    local ChatContainer = Instance.new("Frame")
    ChatContainer.Name = "ChatContainer"
    ChatContainer.Parent = parent
    ChatContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ChatContainer.BackgroundTransparency = 0.3
    ChatContainer.Size = UDim2.new(1, -20, 0, 100)

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = ChatContainer

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(80, 80, 80)
    Stroke.Thickness = 1
    Stroke.Parent = ChatContainer

    -- Title Label
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Parent = ChatContainer
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 10, 0, 5)
    TitleLabel.Size = UDim2.new(1, -20, 0, 20)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Input Frame (with TextBox)
    local InputFrame = Instance.new("Frame")
    InputFrame.Name = "InputFrame"
    InputFrame.Parent = ChatContainer
    InputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    InputFrame.BackgroundTransparency = 0.3
    InputFrame.Position = UDim2.new(0, 10, 0, 30)
    InputFrame.Size = UDim2.new(1, -90, 0, 60)

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = InputFrame

    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Color3.fromRGB(60, 60, 60)
    InputStroke.Thickness = 1
    InputStroke.Parent = InputFrame

    -- TextBox (Multi-line)
    local TextBox = Instance.new("TextBox")
    TextBox.Name = "ChatInput"
    TextBox.Parent = InputFrame
    TextBox.BackgroundTransparency = 1
    TextBox.Position = UDim2.new(0, 10, 0, 5)
    TextBox.Size = UDim2.new(1, -20, 1, -10)
    TextBox.Font = Enum.Font.Gotham
    TextBox.PlaceholderText = Placeholder
    TextBox.Text = ""
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    TextBox.TextSize = 13
    TextBox.TextXAlignment = Enum.TextXAlignment.Left
    TextBox.TextYAlignment = Enum.TextYAlignment.Top
    TextBox.TextWrapped = true
    TextBox.MultiLine = true
    TextBox.ClearTextOnFocus = false

    -- Send Button
    local SendButton = Instance.new("TextButton")
    SendButton.Name = "SendButton"
    SendButton.Parent = ChatContainer
    SendButton.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    SendButton.BackgroundTransparency = 0
    SendButton.Position = UDim2.new(1, -70, 0, 30)
    SendButton.Size = UDim2.new(0, 60, 0, 60)
    SendButton.Font = Enum.Font.GothamBold
    SendButton.Text = "Send"
    SendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SendButton.TextSize = 14

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = SendButton

    -- Button hover effect
    SendButton.MouseEnter:Connect(function()
        TweenService:Create(SendButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(90, 150, 255)
        }):Play()
    end)

    SendButton.MouseLeave:Connect(function()
        TweenService:Create(SendButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(70, 130, 255)
        }):Play()
    end)

    -- Send function
    local function Send()
        local message = TextBox.Text
        if message and message ~= "" then
            SendCallback(message)
            TextBox.Text = ""
        end
    end

    -- Click to send
    SendButton.MouseButton1Click:Connect(Send)

    -- Enter to send (Shift+Enter for new line)
    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            Send()
        end
    end)

    local ChatBoxObject = {}
    function ChatBoxObject:SetText(text)
        TextBox.Text = text
    end
    
    function ChatBoxObject:GetText()
        return TextBox.Text
    end
    
    function ChatBoxObject:Clear()
        TextBox.Text = ""
    end
    
    function ChatBoxObject:SetPlaceholder(text)
        TextBox.PlaceholderText = text
    end

    return ChatBoxObject
end

-- ========================================
-- RESPONSE DISPLAY (Scrollable Text Display)
-- ========================================
function Assets.CreateResponseDisplay(parent, config)
    local Title = config.Title or "Response"
    local Height = config.Height or 200

    local DisplayFrame = Instance.new("Frame")
    DisplayFrame.Name = "ResponseDisplay"
    DisplayFrame.Parent = parent
    DisplayFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DisplayFrame.BackgroundTransparency = 0.3
    DisplayFrame.Size = UDim2.new(1, -20, 0, Height)

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = DisplayFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(80, 80, 80)
    Stroke.Thickness = 1
    Stroke.Parent = DisplayFrame

    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Parent = DisplayFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 10, 0, 5)
    TitleLabel.Size = UDim2.new(1, -60, 0, 25)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Copy Button
    local CopyButton = Instance.new("TextButton")
    CopyButton.Name = "CopyButton"
    CopyButton.Parent = DisplayFrame
    CopyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    CopyButton.Position = UDim2.new(1, -50, 0, 5)
    CopyButton.Size = UDim2.new(0, 40, 0, 25)
    CopyButton.Font = Enum.Font.GothamBold
    CopyButton.Text = "Copy"
    CopyButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    CopyButton.TextSize = 12

    local CopyCorner = Instance.new("UICorner")
    CopyCorner.CornerRadius = UDim.new(0, 4)
    CopyCorner.Parent = CopyButton

    -- Scrolling Frame for text
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "ContentScroll"
    ScrollFrame.Parent = DisplayFrame
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ScrollFrame.BackgroundTransparency = 0.5
    ScrollFrame.Position = UDim2.new(0, 10, 0, 35)
    ScrollFrame.Size = UDim2.new(1, -20, 1, -45)
    ScrollFrame.ScrollBarThickness = 4
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

    local ScrollCorner = Instance.new("UICorner")
    ScrollCorner.CornerRadius = UDim.new(0, 6)
    ScrollCorner.Parent = ScrollFrame

    -- Text Label
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Name = "ResponseText"
    TextLabel.Parent = ScrollFrame
    TextLabel.BackgroundTransparency = 1
    TextLabel.Position = UDim2.new(0, 8, 0, 8)
    TextLabel.Size = UDim2.new(1, -16, 1, 0)
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.Text = "AI responses will appear here..."
    TextLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    TextLabel.TextSize = 13
    TextLabel.TextWrapped = true
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.TextYAlignment = Enum.TextYAlignment.Top
    TextLabel.RichText = true

    -- Auto-resize text
    local function UpdateSize()
        local textBounds = TextLabel.TextBounds
        TextLabel.Size = UDim2.new(1, -16, 0, math.max(textBounds.Y + 16, ScrollFrame.AbsoluteSize.Y))
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, textBounds.Y + 24)
    end

    TextLabel:GetPropertyChangedSignal("Text"):Connect(UpdateSize)
    ScrollFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)

    -- Copy button functionality
    CopyButton.MouseButton1Click:Connect(function()
        pcall(function()
            setclipboard(TextLabel.Text:gsub("<[^>]+>", "")) -- Remove rich text tags
        end)
        
        CopyButton.Text = "Copied!"
        CopyButton.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
        task.wait(1)
        CopyButton.Text = "Copy"
        CopyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)

    local DisplayObject = {}
    
    function DisplayObject:SetText(text)
        TextLabel.Text = text
        UpdateSize()
    end
    
    function DisplayObject:AppendText(text)
        TextLabel.Text = TextLabel.Text .. "\n" .. text
        UpdateSize()
        -- Scroll to bottom
        ScrollFrame.CanvasPosition = Vector2.new(0, ScrollFrame.CanvasSize.Y.Offset)
    end
    
    function DisplayObject:Clear()
        TextLabel.Text = ""
        UpdateSize()
    end
    
    function DisplayObject:SetTitle(title)
        TitleLabel.Text = title
    end

    return DisplayObject
end

return Assets