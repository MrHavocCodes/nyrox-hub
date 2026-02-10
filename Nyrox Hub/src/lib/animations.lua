local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local Animations = {}

function Animations.PlayLoading()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NyroxLoading"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Blur Effect for Glass-Look
    local Blur = Instance.new("BlurEffect")
    Blur.Enabled = false
    Blur.Size = 0
    Blur.Parent = Lighting

    -- Background Overlay
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Parent = ScreenGui
    Background.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Background.BackgroundTransparency = 1 -- Start transparent
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.ZIndex = 100

    -- Glass Card (Container) - Removed (invisible)
    local Card = Instance.new("Frame")
    Card.Name = "GlassCard"
    Card.Parent = Background
    Card.AnchorPoint = Vector2.new(0.5, 0.5)
    Card.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Card.BackgroundTransparency = 1 -- Stays completely transparent
    Card.Position = UDim2.new(0.5, 0, 0.5, 0) 
    Card.Size = UDim2.new(0, 300, 0, 150)
    Card.BorderSizePixel = 0
    Card.ZIndex = 101

    -- Title: Nyrox
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = Card
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0.35, 0)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Nyrox"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 42
    Title.TextTransparency = 1

    -- Subtitle: by L5ks8
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Author"
    Subtitle.Parent = Card
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0, 0, 0.6, 0)
    Subtitle.Size = UDim2.new(1, 0, 0, 20)
    Subtitle.Font = Enum.Font.GothamMedium
    Subtitle.Text = "by L5ks8"
    Subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    Subtitle.TextSize = 14
    Subtitle.TextTransparency = 1

    -- Ladebalken Container
    local BarBg = Instance.new("Frame")
    BarBg.Name = "BarBg"
    BarBg.Parent = Card
    BarBg.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    BarBg.BackgroundTransparency = 1 -- Ziel 0.5
    BarBg.Position = UDim2.new(0.2, 0, 0.8, 0)
    BarBg.Size = UDim2.new(0.6, 0, 0, 3)
    BarBg.BorderSizePixel = 0
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = BarBg

    -- Ladebalken Füllung
    local BarFill = Instance.new("Frame")
    BarFill.Name = "BarFill"
    BarFill.Parent = BarBg
    BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BarFill.BackgroundTransparency = 0
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = BarFill
    
    -- === ANIMATIONEN ===

    -- 1. Setup (Blur an, Hintergrund leicht dunkel)
    Blur.Enabled = true
    TweenService:Create(Blur, TweenInfo.new(1.5), {Size = 24}):Play()
    TweenService:Create(Background, TweenInfo.new(1), {BackgroundTransparency = 0.4}):Play()
    
    wait(0.5)

    -- 2. Text Fade-In + Slide Up
    TweenService:Create(Title, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0, Position = UDim2.new(0, 0, 0.35, 0)}):Play()
    Title.Position = UDim2.new(0, 0, 0.4, 0) -- Leicht von unten kommen

    wait(0.5)
    TweenService:Create(Subtitle, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0, Position = UDim2.new(0, 0, 0.6, 0)}):Play()
    Subtitle.Position = UDim2.new(0, 0, 0.65, 0)

    wait(0.2)

    -- 3. Bar Fade-In & Fill
    TweenService:Create(BarBg, TweenInfo.new(0.5), {BackgroundTransparency = 0.5}):Play()
    wait(0.2)
    
    TweenService:Create(BarFill, TweenInfo.new(2.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    
    wait(2.8) -- Warte bis Balken voll

    -- 4. Out Animation
    local OutInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    
    TweenService:Create(Blur, OutInfo, {Size = 0}):Play()
    TweenService:Create(Background, OutInfo, {BackgroundTransparency = 1}):Play()
    -- Card war eh unsichtbar, aber Text wegfaden
    TweenService:Create(Title, OutInfo, {TextTransparency = 1, Position = UDim2.new(0, 0, 0.3, 0)}):Play()
    TweenService:Create(Subtitle, OutInfo, {TextTransparency = 1, Position = UDim2.new(0, 0, 0.55, 0)}):Play()
    TweenService:Create(BarBg, OutInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(BarFill, OutInfo, {BackgroundTransparency = 1}):Play()

    wait(0.8)
    
    -- Cleanup
    Blur:Destroy()
    ScreenGui:Destroy()
end

return Animations
