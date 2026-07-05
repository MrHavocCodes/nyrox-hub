local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Assets
if type(getgenv) == "function" and getgenv().Import then
    -- print("[UI Library] Loading Assets via Import...")
    local success, result = pcall(function()
        return getgenv().Import("src/lib/assets.lua")
    end)
    if success and result then
        Assets = result
        -- print("[UI Library] ✓ Assets loaded via Import")
    else
        warn("[UI Library] ✗ Failed to load Assets via Import: " .. tostring(result))
        Assets = {}
    end
else
    -- warn("[UI Library] getgenv().Import not available, trying fallback...")
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/MrHavocCodes/nyrox-hub/refs/heads/main/Nyrox%20Hub/src/lib/assets.lua"))()
    end)
    if success and result then
        Assets = result
        -- print("[UI Library] ✓ Assets loaded via fallback")
    else
        warn("[UI Library] ✗ Failed to load Assets via fallback: " .. tostring(result))
        Assets = {}
    end
end

function Library:CreateWindow(config)
    local Title = config.Title or "UI Library"
    local SubTitle = config.SubTitle or "by Author"
    local OnClose = config.OnClose or function() end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NyroxHub"
    ScreenGui.Parent = game.CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BackgroundTransparency = 0.3
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    MainFrame.Size = UDim2.new(0, 550, 0, 350)
    MainFrame.ClipsDescendants = true

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Parent = MainFrame
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Transparency = 0.8
    MainStroke.Thickness = 1
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    -- Dragging functionality
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)

    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TopBar.BackgroundTransparency = 1
    TopBar.Size = UDim2.new(1, 0, 0, 40)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Parent = TopBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = Title .. "  <font color=\"rgb(150,150,150)\" size=\"14\">" .. SubTitle .. "</font>"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.RichText = true

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "Minimize"
    MinimizeButton.Parent = TopBar
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Position = UDim2.new(1, -80, 0, 0)
    MinimizeButton.Size = UDim2.new(0, 40, 1, 0)
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinimizeButton.TextSize = 24

    local Minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 550, 0, 40)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 550, 0, 350)}):Play()
        end
    end)

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "Close"
    CloseButton.Parent = TopBar
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(1, -40, 0, 0)
    CloseButton.Size = UDim2.new(0, 40, 1, 0)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.TextSize = 24
    CloseButton.MouseButton1Click:Connect(function()
        -- Closing Animation: "Ghost" Pop-Out (Scale Up & Dissolve)
        local AnimationTime = 0.35
        local TweenStyle = TweenInfo.new(AnimationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        -- Calculate centered position for larger size to keep it centered
        local CurrentSize = MainFrame.Size
        local TargetSize = UDim2.new(CurrentSize.X.Scale, CurrentSize.X.Offset + 100, CurrentSize.Y.Scale, CurrentSize.Y.Offset + 60)
        local TargetPos = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset - 50, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset - 30)

        TweenService:Create(MainFrame, TweenStyle, {
            Size = TargetSize,
            Position = TargetPos,
            BackgroundTransparency = 1
        }):Play()

        -- Fade out UIStroke if applied
        if MainFrame:FindFirstChild("UIStroke") then
            TweenService:Create(MainFrame.UIStroke, TweenStyle, {Transparency = 1}):Play()
        end
        
        -- Fade out all contents quickly
        for _, v in pairs(MainFrame:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                TweenService:Create(v, TweenStyle, {TextTransparency = 1, BackgroundTransparency = 1}):Play()
            elseif v:IsA("Frame") or v:IsA("ScrollingFrame") then
                TweenService:Create(v, TweenStyle, {BackgroundTransparency = 1}):Play()
            elseif v:IsA("UIStroke") then
                TweenService:Create(v, TweenStyle, {Transparency = 1}):Play()
            elseif v:IsA("ImageLabel") then
                 TweenService:Create(v, TweenStyle, {ImageTransparency = 1}):Play()
            end
        end
        
        wait(AnimationTime)
        
        -- Clean up tooltips
        if getgenv().currentTooltipText then
            getgenv().currentTooltipText = nil
        end
        if getgenv().NyroxTooltipConnection then
            getgenv().NyroxTooltipConnection:Disconnect()
            getgenv().NyroxTooltipConnection = nil
        end
        
        -- Find and destroy tooltip GUI
        local coreGui = game:GetService("CoreGui")
        local tooltipGui = coreGui:FindFirstChild("NyroxTooltip")
        if tooltipGui then
            tooltipGui:Destroy()
        end
        
        OnClose() -- Trigger callback before destroying
        ScreenGui:Destroy()
    end)

    -- Sidebar
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.Active = true
    Sidebar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Position = UDim2.new(0, 0, 0, 50)
    Sidebar.Size = UDim2.new(0, 150, 1, -50)
    Sidebar.ScrollBarThickness = 0
    
    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Parent = Sidebar
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Padding = UDim.new(0, 5)

    -- Auto-CanvasSize for Sidebar
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 20)
    end)


    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.Parent = Sidebar
    SidebarPadding.PaddingLeft = UDim.new(0, 10)
    SidebarPadding.PaddingTop = UDim.new(0, 10)

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Parent = MainFrame
    ContentArea.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 160, 0, 50)
    ContentArea.Size = UDim2.new(1, -170, 1, -60)

    local Window = {}
    local FirstTab = true

    function Window:CreateTab(nameOrConfig)
        -- Support both string and config object
        local name, icon
        if type(nameOrConfig) == "table" then
            name = nameOrConfig.Name or "Tab"
            icon = nameOrConfig.Icon or nil
        else
            name = nameOrConfig
            icon = nil
        end
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "Button"
        TabButton.Parent = Sidebar
        TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(1, -20, 0, 35)
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.Text = icon and (icon .. " " .. name) or name
        TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabButton.TextSize = 14
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        local TabPadding = Instance.new("UIPadding")
        TabPadding.Parent = TabButton
        TabPadding.PaddingLeft = UDim.new(0, 10)

        -- Tab Content Frame
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "Content"
        TabContent.Parent = ContentArea
        TabContent.Active = true
        TabContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.ScrollBarThickness = 2
        TabContent.Visible = false

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Parent = TabContent
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 5)

        -- Auto-CanvasSize for Tab Content
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
        end)


        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.Parent = TabContent
        ContentPadding.PaddingLeft = UDim.new(0, 10)
        ContentPadding.PaddingRight = UDim.new(0, 10)
        ContentPadding.PaddingTop = UDim.new(0, 10)
        ContentPadding.PaddingBottom = UDim.new(0, 10)

        if FirstTab then
            TabContent.Visible = true
            TabButton.BackgroundTransparency = 0.9
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            FirstTab = false
        end

        TabButton.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentArea:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            for _, v in pairs(Sidebar:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                end
            end
            TabContent.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundTransparency = 0.9, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end)

        local Tab = {}

        function Tab:AddSection(config)
            local name = type(config) == "table" and config.Name or config
            if not Assets or not Assets.CreateSection then
                warn("[UI Library] Assets.CreateSection not available!")
                return nil
            end
            return Assets.CreateSection(TabContent, name)
        end

        function Tab:AddLabel(config)
            local name = type(config) == "table" and config.Name or config
            local textColor = type(config) == "table" and config.TextColor or nil
            if not Assets or not Assets.CreateLabel then
                warn("[UI Library] Assets.CreateLabel not available!")
                return nil
            end
            local label = Assets.CreateLabel(TabContent, name)
            if textColor and label and label:IsA("TextLabel") then
                label.TextColor3 = textColor
            end
            return label
        end

        function Tab:AddButton(config)
            if not Assets or not Assets.CreateButton then
                warn("[UI Library] Assets.CreateButton not available!")
                return nil
            end
            local buttonConfig = {
                Title = config.Name or config.Title or "Button",
                Callback = config.Callback or function() end,
                Tooltip = config.Description or config.Tooltip
            }
            return Assets.CreateButton(TabContent, buttonConfig)
        end

        function Tab:AddToggle(config)
            if not Assets or not Assets.CreateToggle then
                warn("[UI Library] Assets.CreateToggle not available!")
                return nil
            end
            local toggleConfig = {
                Title = config.Name or config.Title or "Toggle",
                Default = config.Default or false,
                Callback = config.Callback or function() end,
                Tooltip = config.Description or config.Tooltip
            }
            return Assets.CreateToggle(TabContent, toggleConfig)
        end

        function Tab:AddSlider(config)
            if not Assets or not Assets.CreateValidSlider then
                warn("[UI Library] Assets.CreateValidSlider not available!")
                return nil
            end
            local sliderConfig = {
                Title = config.Name or config.Title or "Slider",
                Min = config.Min or 0,
                Max = config.Max or 100,
                Default = config.Default or 50,
                Increment = config.Increment or 1,
                Callback = config.Callback or function() end,
                Tooltip = config.Description or config.Tooltip
            }
            return Assets.CreateValidSlider(TabContent, sliderConfig)
        end

        function Tab:AddDropdown(config)
            if not Assets or not Assets.CreateDropdown then
                warn("[UI Library] Assets.CreateDropdown not available!")
                return nil
            end
            local dropdownConfig = {
                Title = config.Name or config.Title or "Dropdown",
                Options = config.Options or {},
                Default = config.Default or nil,
                Callback = config.Callback or function() end,
                Tooltip = config.Description or config.Tooltip
            }
            return Assets.CreateDropdown(TabContent, dropdownConfig)
        end

        -- Legacy/Alternative API
        function Tab:CreateSection(text)
            return Assets.CreateSection(TabContent, text)
        end

        function Tab:CreateLabel(text)
            return Assets.CreateLabel(TabContent, text)
        end

        function Tab:CreateImage(config)
            return Assets.CreateImage(TabContent, config)
        end

        function Tab:CreateToggle(config)
            return Assets.CreateToggle(TabContent, config)
        end

        function Tab:CreateButton(config)
            return Assets.CreateButton(TabContent, config)
        end

        function Tab:Create3Buttons(config)
            return Assets.Create3Buttons(TabContent, config)
        end

        function Tab:CreateValidSlider(config)
             return Assets.CreateValidSlider(TabContent, config)
        end

        function Tab:CreateDropdown(config)
            return Assets.CreateDropdown(TabContent, config)
        end
        
        function Tab:CreateChatBox(config)
            return Assets.CreateChatBox(TabContent, config)
        end
        
        function Tab:CreateResponseDisplay(config)
            return Assets.CreateResponseDisplay(TabContent, config)
        end
        
        return Tab
    end

    -- AddTab wrapper for compatibility
    function Window:AddTab(config)
        return self:CreateTab(config)
    end

    return Window
end

return Library
