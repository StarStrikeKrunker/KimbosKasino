-- Military Tycoon Freelo by Kimbo
-- Universal Auto Build Script with Aimbot & ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

-- Configuration
local CONFIG = {
    autoBuild = {
        enabled = false,
        buildDelay = 0.5,
        autoClaim = true,
    },
    aimbot = {
        enabled = false,
        fov = 100,
        smoothness = 0.1,
        targetPart = "Head",
        showFOV = true,
        teamCheck = true,
    },
    esp = {
        enabled = false,
        boxes = true,
        names = true,
        health = true,
        distance = true,
        teamCheck = true,
        maxDistance = 1000,
    }
}

-- State tracking
local building = false
local processedButtons = {}
local stats = {
    purchased = 0,
    failed = 0,
    kills = 0,
}
local espObjects = {}
local fovCircle = nil
local currentTarget = nil

-- Create FOV Circle
local function createFOVCircle()
    local circle = Drawing.new("Circle")
    circle.Thickness = 2
    circle.NumSides = 50
    circle.Radius = CONFIG.aimbot.fov
    circle.Color = Color3.fromRGB(255, 255, 255)
    circle.Transparency = 0.5
    circle.Visible = CONFIG.aimbot.showFOV
    circle.Filled = false
    return circle
end

-- Create ESP for player
local function createESP(targetPlayer)
    if espObjects[targetPlayer] then return end
    
    local esp = {
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        health = Drawing.new("Text"),
        distance = Drawing.new("Text"),
        tracer = Drawing.new("Line")
    }
    
    -- Box
    esp.box.Thickness = 2
    esp.box.Filled = false
    esp.box.Color = Color3.fromRGB(255, 255, 255)
    esp.box.Transparency = 1
    
    -- Name
    esp.name.Size = 14
    esp.name.Center = true
    esp.name.Outline = true
    esp.name.Color = Color3.fromRGB(255, 255, 255)
    esp.name.Transparency = 1
    
    -- Health
    esp.health.Size = 12
    esp.health.Center = true
    esp.health.Outline = true
    esp.health.Color = Color3.fromRGB(0, 255, 0)
    esp.health.Transparency = 1
    
    -- Distance
    esp.distance.Size = 12
    esp.distance.Center = true
    esp.distance.Outline = true
    esp.distance.Color = Color3.fromRGB(200, 200, 200)
    esp.distance.Transparency = 1
    
    -- Tracer
    esp.tracer.Thickness = 1
    esp.tracer.Color = Color3.fromRGB(255, 255, 255)
    esp.tracer.Transparency = 0.5
    
    espObjects[targetPlayer] = esp
end

-- Remove ESP
local function removeESP(targetPlayer)
    if espObjects[targetPlayer] then
        for _, drawing in pairs(espObjects[targetPlayer]) do
            drawing:Remove()
        end
        espObjects[targetPlayer] = nil
    end
end

-- Update ESP
local function updateESP()
    if not CONFIG.esp.enabled then
        for _, esp in pairs(espObjects) do
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
        end
        return
    end
    
    for targetPlayer, esp in pairs(espObjects) do
        if targetPlayer and targetPlayer ~= player and targetPlayer.Character then
            local char = targetPlayer.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChild("Humanoid")
            local head = char:FindFirstChild("Head")
            
            if hrp and humanoid and humanoid.Health > 0 then
                -- Team check
                if CONFIG.esp.teamCheck and targetPlayer.Team == player.Team then
                    for _, drawing in pairs(esp) do
                        drawing.Visible = false
                    end
                    goto continue
                end
                
                local distance = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
                
                if distance > CONFIG.esp.maxDistance then
                    for _, drawing in pairs(esp) do
                        drawing.Visible = false
                    end
                    goto continue
                end
                
                local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    -- Calculate box size
                    local headPos = Camera:WorldToViewportPoint(head.Position)
                    local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height / 2
                    
                    -- Update box
                    if CONFIG.esp.boxes then
                        esp.box.Size = Vector2.new(width, height)
                        esp.box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
                        esp.box.Visible = true
                        
                        -- Color based on team
                        if targetPlayer.Team == player.Team then
                            esp.box.Color = Color3.fromRGB(0, 255, 0)
                        else
                            esp.box.Color = Color3.fromRGB(255, 0, 0)
                        end
                    else
                        esp.box.Visible = false
                    end
                    
                    -- Update name
                    if CONFIG.esp.names then
                        esp.name.Text = targetPlayer.Name
                        esp.name.Position = Vector2.new(vector.X, vector.Y - height / 2 - 15)
                        esp.name.Visible = true
                    else
                        esp.name.Visible = false
                    end
                    
                    -- Update health
                    if CONFIG.esp.health then
                        local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                        esp.health.Text = healthPercent .. "%"
                        esp.health.Position = Vector2.new(vector.X, vector.Y + height / 2 + 5)
                        esp.health.Color = Color3.fromRGB(255 - (healthPercent * 2.55), healthPercent * 2.55, 0)
                        esp.health.Visible = true
                    else
                        esp.health.Visible = false
                    end
                    
                    -- Update distance
                    if CONFIG.esp.distance then
                        esp.distance.Text = math.floor(distance) .. " studs"
                        esp.distance.Position = Vector2.new(vector.X, vector.Y + height / 2 + 20)
                        esp.distance.Visible = true
                    else
                        esp.distance.Visible = false
                    end
                    
                    -- Update tracer
                    esp.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    esp.tracer.To = Vector2.new(vector.X, vector.Y)
                    esp.tracer.Visible = true
                else
                    for _, drawing in pairs(esp) do
                        drawing.Visible = false
                    end
                end
            else
                for _, drawing in pairs(esp) do
                    drawing.Visible = false
                end
            end
        else
            for _, drawing in pairs(esp) do
                drawing.Visible = false
            end
        end
        ::continue::
    end
end

-- Get closest player to crosshair
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = CONFIG.aimbot.fov
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local char = targetPlayer.Character
            local humanoid = char:FindFirstChild("Humanoid")
            local targetPart = char:FindFirstChild(CONFIG.aimbot.targetPart)
            
            if humanoid and humanoid.Health > 0 and targetPart then
                -- Team check
                if CONFIG.aimbot.teamCheck and targetPlayer.Team == player.Team then
                    goto continue
                end
                
                local vector, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local mousePos = Vector2.new(mouse.X, mouse.Y)
                    local targetPos = Vector2.new(vector.X, vector.Y)
                    local distance = (mousePos - targetPos).Magnitude
                    
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = targetPlayer
                    end
                end
            end
        end
        ::continue::
    end
    
    return closestPlayer
end

-- Aimbot function
local function aimAt(target)
    if not target or not target.Character then return end
    
    local char = target.Character
    local targetPart = char:FindFirstChild(CONFIG.aimbot.targetPart)
    
    if targetPart then
        local targetPos = targetPart.Position
        local cameraCFrame = Camera.CFrame
        local direction = (targetPos - cameraCFrame.Position).Unit
        local newCFrame = CFrame.new(cameraCFrame.Position, cameraCFrame.Position + direction)
        
        -- Smooth aiming
        Camera.CFrame = cameraCFrame:Lerp(newCFrame, CONFIG.aimbot.smoothness)
    end
end

-- Create GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MilitaryTycoonFreelo"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Intro Frame
    local introFrame = Instance.new("Frame")
    introFrame.Name = "IntroFrame"
    introFrame.Size = UDim2.new(0, 400, 0, 250)
    introFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    introFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    introFrame.BorderSizePixel = 0
    introFrame.Parent = screenGui
    
    local introCorner = Instance.new("UICorner")
    introCorner.CornerRadius = UDim.new(0, 15)
    introCorner.Parent = introFrame
    
    local introGradient = Instance.new("UIGradient")
    introGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 100)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 50, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 150, 255))
    }
    introGradient.Rotation = 45
    introGradient.Parent = introFrame
    
    local introTitle = Instance.new("TextLabel")
    introTitle.Size = UDim2.new(1, -40, 0, 60)
    introTitle.Position = UDim2.new(0, 20, 0, 40)
    introTitle.BackgroundTransparency = 1
    introTitle.Text = "Military Tycoon"
    introTitle.Font = Enum.Font.GothamBold
    introTitle.TextSize = 32
    introTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    introTitle.Parent = introFrame
    
    local introSubtitle = Instance.new("TextLabel")
    introSubtitle.Size = UDim2.new(1, -40, 0, 40)
    introSubtitle.Position = UDim2.new(0, 20, 0, 100)
    introSubtitle.BackgroundTransparency = 1
    introSubtitle.Text = "FREELO"
    introSubtitle.Font = Enum.Font.GothamBold
    introSubtitle.TextSize = 48
    introSubtitle.TextColor3 = Color3.fromRGB(255, 255, 100)
    introSubtitle.Parent = introFrame
    
    local introCredit = Instance.new("TextLabel")
    introCredit.Size = UDim2.new(1, -40, 0, 30)
    introCredit.Position = UDim2.new(0, 20, 0, 160)
    introCredit.BackgroundTransparency = 1
    introCredit.Text = "by Kimbo"
    introCredit.Font = Enum.Font.Gotham
    introCredit.TextSize = 20
    introCredit.TextColor3 = Color3.fromRGB(200, 200, 200)
    introCredit.Parent = introFrame
    
    local introLoading = Instance.new("TextLabel")
    introLoading.Size = UDim2.new(1, -40, 0, 25)
    introLoading.Position = UDim2.new(0, 20, 0, 200)
    introLoading.BackgroundTransparency = 1
    introLoading.Text = "Loading..."
    introLoading.Font = Enum.Font.Gotham
    introLoading.TextSize = 16
    introLoading.TextColor3 = Color3.fromRGB(150, 150, 150)
    introLoading.Parent = introFrame
    
    -- Main GUI Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 340, 0, 520)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -260)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
    }
    gradient.Rotation = 90
    gradient.Parent = mainFrame
    
    -- Make draggable
    local dragging, dragInput, dragStart, startPos
    
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 50, 255))
    }
    headerGradient.Rotation = 45
    headerGradient.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "Military Tycoon FREELO"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local credit = Instance.new("TextLabel")
    credit.Size = UDim2.new(1, -20, 0, 20)
    credit.Position = UDim2.new(0, 10, 0, 35)
    credit.BackgroundTransparency = 1
    credit.Text = "by Kimbo"
    credit.Font = Enum.Font.Gotham
    credit.TextSize = 12
    credit.TextColor3 = Color3.fromRGB(255, 255, 255)
    credit.TextTransparency = 0.3
    credit.TextXAlignment = Enum.TextXAlignment.Left
    credit.Parent = header
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 15)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 18
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    -- Tab Buttons
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, -20, 0, 35)
    tabFrame.Position = UDim2.new(0, 10, 0, 70)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = mainFrame
    
    local buildTab = Instance.new("TextButton")
    buildTab.Size = UDim2.new(0.31, 0, 1, 0)
    buildTab.Position = UDim2.new(0, 0, 0, 0)
    buildTab.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    buildTab.BorderSizePixel = 0
    buildTab.Text = "Build"
    buildTab.Font = Enum.Font.GothamBold
    buildTab.TextSize = 14
    buildTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    buildTab.Parent = tabFrame
    
    local buildCorner = Instance.new("UICorner")
    buildCorner.CornerRadius = UDim.new(0, 8)
    buildCorner.Parent = buildTab
    
    local aimbotTab = Instance.new("TextButton")
    aimbotTab.Size = UDim2.new(0.31, 0, 1, 0)
    aimbotTab.Position = UDim2.new(0.345, 0, 0, 0)
    aimbotTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    aimbotTab.BorderSizePixel = 0
    aimbotTab.Text = "Aimbot"
    aimbotTab.Font = Enum.Font.GothamBold
    aimbotTab.TextSize = 14
    aimbotTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimbotTab.Parent = tabFrame
    
    local aimbotCorner = Instance.new("UICorner")
    aimbotCorner.CornerRadius = UDim.new(0, 8)
    aimbotCorner.Parent = aimbotTab
    
    local espTab = Instance.new("TextButton")
    espTab.Size = UDim2.new(0.31, 0, 1, 0)
    espTab.Position = UDim2.new(0.69, 0, 0, 0)
    espTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    espTab.BorderSizePixel = 0
    espTab.Text = "ESP"
    espTab.Font = Enum.Font.GothamBold
    espTab.TextSize = 14
    espTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    espTab.Parent = tabFrame
    
    local espCorner = Instance.new("UICorner")
    espCorner.CornerRadius = UDim.new(0, 8)
    espCorner.Parent = espTab
    
    -- BUILD TAB CONTENT
    local buildContent = Instance.new("Frame")
    buildContent.Name = "BuildContent"
    buildContent.Size = UDim2.new(1, -20, 1, -120)
    buildContent.Position = UDim2.new(0, 10, 0, 115)
    buildContent.BackgroundTransparency = 1
    buildContent.Visible = true
    buildContent.Parent = mainFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 0, 30)
    statusLabel.Position = UDim2.new(0, 0, 0, 0)
    statusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    statusLabel.BorderSizePixel = 0
    statusLabel.Text = "Status: Idle"
    statusLabel.Font = Enum.Font.GothamMedium
    statusLabel.TextSize = 14
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    statusLabel.Parent = buildContent
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 8)
    statusCorner.Parent = statusLabel
    
    local statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(1, 0, 0, 80)
    statsFrame.Position = UDim2.new(0, 0, 0, 40)
    statsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    statsFrame.BorderSizePixel = 0
    statsFrame.Parent = buildContent
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 8)
    statsCorner.Parent = statsFrame
    
    local purchasedLabel = Instance.new("TextLabel")
    purchasedLabel.Name = "PurchasedLabel"
    purchasedLabel.Size = UDim2.new(1, -20, 0, 25)
    purchasedLabel.Position = UDim2.new(0, 10, 0, 10)
    purchasedLabel.BackgroundTransparency = 1
    purchasedLabel.Text = "✓ Purchased: 0"
    purchasedLabel.Font = Enum.Font.Gotham
    purchasedLabel.TextSize = 13
    purchasedLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    purchasedLabel.TextXAlignment = Enum.TextXAlignment.Left
    purchasedLabel.Parent = statsFrame
    
    local failedLabel = Instance.new("TextLabel")
    failedLabel.Name = "FailedLabel"
    failedLabel.Size = UDim2.new(1, -20, 0, 25)
    failedLabel.Position = UDim2.new(0, 10, 0, 35)
    failedLabel.BackgroundTransparency = 1
    failedLabel.Text = "✗ Failed: 0"
    failedLabel.Font = Enum.Font.Gotham
    failedLabel.TextSize = 13
    failedLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    failedLabel.TextXAlignment = Enum.TextXAlignment.Left
    failedLabel.Parent = statsFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(1, 0, 0, 45)
    toggleButton.Position = UDim2.new(0, 0, 0, 130)
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "START AUTO BUILD"
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 16
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Parent = buildContent
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggleButton
    
    local claimToggle = Instance.new("TextButton")
    claimToggle.Name = "ClaimToggle"
    claimToggle.Size = UDim2.new(1, 0, 0, 35)
    claimToggle.Position = UDim2.new(0, 0, 0, 185)
    claimToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    claimToggle.BorderSizePixel = 0
    claimToggle.Text = "Auto Claim: ON"
    claimToggle.Font = Enum.Font.GothamMedium
    claimToggle.TextSize = 14
    claimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    claimToggle.Parent = buildContent
    
    local claimCorner = Instance.new("UICorner")
    claimCorner.CornerRadius = UDim.new(0, 8)
    claimCorner.Parent = claimToggle
    
    local resetButton = Instance.new("TextButton")
    resetButton.Name = "ResetButton"
    resetButton.Size = UDim2.new(1, 0, 0, 35)
    resetButton.Position = UDim2.new(0, 0, 0, 230)
    resetButton.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
    resetButton.BorderSizePixel = 0
    resetButton.Text = "Reset Stats"
    resetButton.Font = Enum.Font.GothamMedium
    resetButton.TextSize = 14
    resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetButton.Parent = buildContent
    
    local resetCorner = Instance.new("UICorner")
    resetCorner.CornerRadius = UDim.new(0, 8)
    resetCorner.Parent = resetButton
    
    -- AIMBOT TAB CONTENT
    local aimbotContent = Instance.new("Frame")
    aimbotContent.Name = "AimbotContent"
    aimbotContent.Size = UDim2.new(1, -20, 1, -120)
    aimbotContent.Position = UDim2.new(0, 10, 0, 115)
    aimbotContent.BackgroundTransparency = 1
    aimbotContent.Visible = false
    aimbotContent.Parent = mainFrame
    
    local aimbotToggle = Instance.new("TextButton")
    aimbotToggle.Name = "AimbotToggle"
    aimbotToggle.Size = UDim2.new(1, 0, 0, 45)
    aimbotToggle.Position = UDim2.new(0, 0, 0, 0)
    aimbotToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    aimbotToggle.BorderSizePixel = 0
    aimbotToggle.Text = "ENABLE AIMBOT"
    aimbotToggle.Font = Enum.Font.GothamBold
    aimbotToggle.TextSize = 16
    aimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimbotToggle.Parent = aimbotContent
    
    local aimbotToggleCorner = Instance.new("UICorner")
    aimbotToggleCorner.CornerRadius = UDim.new(0, 10)
    aimbotToggleCorner.Parent = aimbotToggle
    
    local fovLabel = Instance.new("TextLabel")
    fovLabel.Size = UDim2.new(1, 0, 0, 25)
    fovLabel.Position = UDim2.new(0, 0, 0, 55)
    fovLabel.BackgroundTransparency = 1
    fovLabel.Text = "FOV Size: 100"
    fovLabel.Font = Enum.Font.GothamMedium
    fovLabel.TextSize = 14
    fovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovLabel.Parent = aimbotContent
    
    local fovSlider = Instance.new("TextButton")
    fovSlider.Size = UDim2.new(1, 0, 0, 30)
    fovSlider.Position = UDim2.new(0, 0, 0, 85)
    fovSlider.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    fovSlider.BorderSizePixel = 0
    fovSlider.Text = ""
    fovSlider.Parent = aimbotContent
    
    local fovSliderCorner = Instance.new("UICorner")
    fovSliderCorner.CornerRadius = UDim.new(0, 8)
    fovSliderCorner.Parent = fovSlider
    
    local fovFill = Instance.new("Frame")
    fovFill.Name = "Fill"
    fovFill.Size = UDim2.new(0.5, 0, 1, 0)
    fovFill.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
    fovFill.BorderSizePixel = 0
    fovFill.Parent = fovSlider
    
    local fovFillCorner = Instance.new("UICorner")
    fovFillCorner.CornerRadius = UDim.new(0, 8)
    fovFillCorner.Parent = fovFill
    
    local showFOVToggle = Instance.new("TextButton")
    showFOVToggle.Size = UDim2.new(1, 0, 0, 35)
    showFOVToggle.Position = UDim2.new(0, 0, 0, 125)
    showFOVToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    showFOVToggle.BorderSizePixel = 0
    showFOVToggle.Text = "Show FOV Circle: ON"
    showFOVToggle.Font = Enum.Font.GothamMedium
    showFOVToggle.TextSize = 14
    showFOVToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    showFOVToggle.Parent = aimbotContent
    
    local showFOVCorner = Instance.new("UICorner")
    showFOVCorner.CornerRadius = UDim.new(0, 8)
    showFOVCorner.Parent = showFOVToggle
    
    local teamCheckToggle = Instance.new("TextButton")
    teamCheckToggle.Size = UDim2.new(1, 0, 0, 35)
    teamCheckToggle.Position = UDim2.new(0, 0, 0, 170)
    teamCheckToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    teamCheckToggle.BorderSizePixel = 0
    teamCheckToggle.Text = "Team Check: ON"
    teamCheckToggle.Font = Enum.Font.GothamMedium
    teamCheckToggle.TextSize = 14
    teamCheckToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    teamCheckToggle.Parent = aimbotContent
    
    local teamCheckCorner = Instance.new("UICorner")
    teamCheckCorner.CornerRadius = UDim.new(0, 8)
    teamCheckCorner.Parent = teamCheckToggle
    
    local targetPartLabel = Instance.new("TextLabel")
    targetPartLabel.Size = UDim2.new(1, 0, 0, 25)
    targetPartLabel.Position = UDim2.new(0, 0, 0, 215)
    targetPartLabel.BackgroundTransparency = 1
    targetPartLabel.Text = "Target Part:"
    targetPartLabel.Font = Enum.Font.GothamMedium
    targetPartLabel.TextSize = 14
    targetPartLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetPartLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetPartLabel.Parent = aimbotContent
    
    local headButton = Instance.new("TextButton")
    headButton.Size = UDim2.new(0.48, 0, 0, 35)
    headButton.Position = UDim2.new(0, 0, 0, 245)
    headButton.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
    headButton.BorderSizePixel = 0
    headButton.Text = "Head"
    headButton.Font = Enum.Font.GothamBold
    headButton.TextSize = 14
    headButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    headButton.Parent = aimbotContent
    
    local headCorner = Instance.new("UICorner")
    headCorner.CornerRadius = UDim.new(0, 8)
    headCorner.Parent = headButton
    
    local torsoButton = Instance.new("TextButton")
    torsoButton.Size = UDim2.new(0.48, 0, 0, 35)
    torsoButton.Position = UDim2.new(0.52, 0, 0, 245)
    torsoButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    torsoButton.BorderSizePixel = 0
    torsoButton.Text = "Torso"
    torsoButton.Font = Enum.Font.GothamBold
    torsoButton.TextSize = 14
    torsoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    torsoButton.Parent = aimbotContent
    
    local torsoCorner = Instance.new("UICorner")
    torsoCorner.CornerRadius = UDim.new(0, 8)
    torsoCorner.Parent = torsoButton
    
    -- ESP TAB CONTENT
    local espContent = Instance.new("Frame")
    espContent.Name = "ESPContent"
    espContent.Size = UDim2.new(1, -20, 1, -120)
    espContent.Position = UDim2.new(0, 10, 0, 115)
    espContent.BackgroundTransparency = 1
    espContent.Visible = false
    espContent.Parent = mainFrame
    
    local espToggle = Instance.new("TextButton")
    espToggle.Name = "ESPToggle"
    espToggle.Size = UDim2.new(1, 0, 0, 45)
    espToggle.Position = UDim2.new(0, 0, 0, 0)
    espToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    espToggle.BorderSizePixel = 0
    espToggle.Text = "ENABLE ESP"
    espToggle.Font = Enum.Font.GothamBold
    espToggle.TextSize = 16
    espToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    espToggle.Parent = espContent
    
    local espToggleCorner = Instance.new("UICorner")
    espToggleCorner.CornerRadius = UDim.new(0, 10)
    espToggleCorner.Parent = espToggle
    
    local boxesToggle = Instance.new("TextButton")
    boxesToggle.Size = UDim2.new(1, 0, 0, 35)
    boxesToggle.Position = UDim2.new(0, 0, 0, 55)
    boxesToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    boxesToggle.BorderSizePixel = 0
    boxesToggle.Text = "Boxes: ON"
    boxesToggle.Font = Enum.Font.GothamMedium
    boxesToggle.TextSize = 14
    boxesToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    boxesToggle.Parent = espContent
    
    local boxesCorner = Instance.new("UICorner")
    boxesCorner.CornerRadius = UDim.new(0, 8)
    boxesCorner.Parent = boxesToggle
    
    local namesToggle = Instance.new("TextButton")
    namesToggle.Size = UDim2.new(1, 0, 0, 35)
    namesToggle.Position = UDim2.new(0, 0, 0, 100)
    namesToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    namesToggle.BorderSizePixel = 0
    namesToggle.Text = "Names: ON"
    namesToggle.Font = Enum.Font.GothamMedium
    namesToggle.TextSize = 14
    namesToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    namesToggle.Parent = espContent
    
    local namesCorner = Instance.new("UICorner")
    namesCorner.CornerRadius = UDim.new(0, 8)
    namesCorner.Parent = namesToggle
    
    local healthToggle = Instance.new("TextButton")
    healthToggle.Size = UDim2.new(1, 0, 0, 35)
    healthToggle.Position = UDim2.new(0, 0, 0, 145)
    healthToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    healthToggle.BorderSizePixel = 0
    healthToggle.Text = "Health: ON"
    healthToggle.Font = Enum.Font.GothamMedium
    healthToggle.TextSize = 14
    healthToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthToggle.Parent = espContent
    
    local healthCorner = Instance.new("UICorner")
    healthCorner.CornerRadius = UDim.new(0, 8)
    healthCorner.Parent = healthToggle
    
    local distanceToggle = Instance.new("TextButton")
    distanceToggle.Size = UDim2.new(1, 0, 0, 35)
    distanceToggle.Position = UDim2.new(0, 0, 0, 190)
    distanceToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    distanceToggle.BorderSizePixel = 0
    distanceToggle.Text = "Distance: ON"
    distanceToggle.Font = Enum.Font.GothamMedium
    distanceToggle.TextSize = 14
    distanceToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    distanceToggle.Parent = espContent
    
    local distanceCorner = Instance.new("UICorner")
    distanceCorner.CornerRadius = UDim.new(0, 8)
    distanceCorner.Parent = distanceToggle
    
    local espTeamToggle = Instance.new("TextButton")
    espTeamToggle.Size = UDim2.new(1, 0, 0, 35)
    espTeamToggle.Position = UDim2.new(0, 0, 0, 235)
    espTeamToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    espTeamToggle.BorderSizePixel = 0
    espTeamToggle.Text = "Team Check: ON"
    espTeamToggle.Font = Enum.Font.GothamMedium
    espTeamToggle.TextSize = 14
    espTeamToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    espTeamToggle.Parent = espContent
    
    local espTeamCorner = Instance.new("UICorner")
    espTeamCorner.CornerRadius = UDim.new(0, 8)
    espTeamCorner.Parent = espTeamToggle
    
    screenGui.Parent = playerGui
    
    return {
        gui = screenGui,
        intro = introFrame,
        main = mainFrame,
        -- Build tab
        buildContent = buildContent,
        status = statusLabel,
        purchased = purchasedLabel,
        failed = failedLabel,
        toggle = toggleButton,
        claim = claimToggle,
        reset = resetButton,
        -- Aimbot tab
        aimbotContent = aimbotContent,
        aimbotToggle = aimbotToggle,
        fovLabel = fovLabel,
        fovSlider = fovSlider,
        fovFill = fovFill,
        showFOV = showFOVToggle,
        teamCheck = teamCheckToggle,
        headBtn = headButton,
        torsoBtn = torsoButton,
        -- ESP tab
        espContent = espContent,
        espToggle = espToggle,
        boxes = boxesToggle,
        names = namesToggle,
        health = healthToggle,
        distance = distanceToggle,
        espTeam = espTeamToggle,
        -- Tabs
        buildTab = buildTab,
        aimbotTab = aimbotTab,
        espTab = espTab,
        close = closeButton
    }
end

-- Animate intro
local function playIntro(gui)
    local intro = gui.intro
    intro.Size = UDim2.new(0, 0, 0, 0)
    intro.Visible = true
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local tween = TweenService:Create(intro, tweenInfo, {Size = UDim2.new(0, 400, 0, 250)})
    tween:Play()
    
    wait(2.5)
    
    local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local fadeTween = TweenService:Create(intro, fadeInfo, {Size = UDim2.new(0, 0, 0, 0)})
    fadeTween:Play()
    fadeTween.Completed:Wait()
    
    intro.Visible = false
    gui.main.Visible = true
    gui.main.Size = UDim2.new(0, 0, 0, 0)
    
    local mainTween = TweenService:Create(gui.main, tweenInfo, {Size = UDim2.new(0, 340, 0, 520)})
    mainTween:Play()
end

-- Update GUI stats
local function updateGUI(gui)
    gui.purchased.Text = "✓ Purchased: " .. stats.purchased
    gui.failed.Text = "✗ Failed: " .. stats.failed
end

-- Find player's tycoon
local function findPlayerTycoon()
    local tycoons = workspace:FindFirstChild("Tycoons") or workspace:FindFirstChild("Tycoon")
    if not tycoons then
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:FindFirstChild("Owner") or obj:FindFirstChild("OwnerName") then
                local owner = obj:FindFirstChild("Owner") or obj:FindFirstChild("OwnerName")
                if owner.Value == player.Name or owner.Value == player then
                    return obj
                end
            end
        end
        return nil
    end
    
    for _, tycoon in pairs(tycoons:GetChildren()) do
        local owner = tycoon:FindFirstChild("Owner") or tycoon:FindFirstChild("OwnerName")
        if owner and (owner.Value == player.Name or owner.Value == player) then
            return tycoon
        end
    end
    return nil
end

-- Claim tycoon
local function claimTycoon()
    if not CONFIG.autoBuild.autoClaim then return false end
    
    local tycoons = workspace:FindFirstChild("Tycoons") or workspace:FindFirstChild("Tycoon") or workspace
    
    for _, tycoon in pairs(tycoons:GetChildren()) do
        local claimButton = tycoon:FindFirstChild("Claim") or 
                           tycoon:FindFirstChild("ClaimButton") or
                           tycoon:FindFirstChild("Button")
        
        if claimButton then
            local head = claimButton:FindFirstChild("Head") or claimButton:FindFirstChild("Button")
            if head and head:FindFirstChild("ClickDetector") then
                fireclickdetector(head.ClickDetector)
                wait(1)
                return true
            end
        end
    end
    return false
end

-- Find purchase buttons
local function findPurchaseButtons(tycoon)
    local buttons = {}
    
    for _, obj in pairs(tycoon:GetDescendants()) do
        if obj.Name:lower():find("button") or 
           obj.Name:lower():find("purchase") or
           obj.Name:lower():find("buy") then
            
            local clickDetector = obj:FindFirstChildOfClass("ClickDetector") or
                                 obj:FindFirstChild("ClickDetector")
            
            if not clickDetector and obj:IsA("Model") then
                clickDetector = obj:FindFirstChild("Head") and 
                               obj.Head:FindFirstChildOfClass("ClickDetector")
            end
            
            if clickDetector and not processedButtons[obj] then
                table.insert(buttons, {
                    button = obj,
                    detector = clickDetector
                })
            end
        end
    end
    
    return buttons
end

-- Click button
local function clickButton(buttonData, gui)
    local success = pcall(function()
        fireclickdetector(buttonData.detector)
        processedButtons[buttonData.button] = true
        stats.purchased = stats.purchased + 1
    end)
    
    if not success then
        stats.failed = stats.failed + 1
    end
    
    updateGUI(gui)
    return success
end

-- Main auto-build loop
local function autoBuildLoop(gui)
    if building then return end
    building = true
    
    gui.status.Text = "Status: Starting..."
    
    claimTycoon()
    wait(2)
    
    while CONFIG.autoBuild.enabled do
        local tycoon = findPlayerTycoon()
        
        if not tycoon then
            gui.status.Text = "Status: No tycoon found"
            wait(5)
            claimTycoon()
        else
            gui.status.Text = "Status: Building..."
            local buttons = findPurchaseButtons(tycoon)
            
            if #buttons == 0 then
                gui.status.Text = "Status: Waiting for items..."
                wait(5)
            else
                for _, btnData in pairs(buttons) do
                    if not CONFIG.autoBuild.enabled then break end
                    clickButton(btnData, gui)
                    wait(CONFIG.autoBuild.buildDelay)
                end
                
                processedButtons = {}
                wait(2)
            end
        end
        
        wait(1)
    end
    
    gui.status.Text = "Status: Stopped"
    building = false
end

-- Initialize
local gui = createGUI()
fovCircle = createFOVCircle()

playIntro(gui)

-- Create ESP for all players
for _, p in pairs(Players:GetPlayers()) do
    if p ~= player then
        createESP(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    createESP(p)
end)

Players.PlayerRemoving:Connect(function(p)
    removeESP(p)
end)

-- Tab switching
local function switchTab(tab)
    gui.buildContent.Visible = (tab == "build")
    gui.aimbotContent.Visible = (tab == "aimbot")
    gui.espContent.Visible = (tab == "esp")
    
    gui.buildTab.BackgroundColor3 = (tab == "build") and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 80)
    gui.aimbotTab.BackgroundColor3 = (tab == "aimbot") and Color3.fromRGB(255, 100, 150) or Color3.fromRGB(60, 60, 80)
    gui.espTab.BackgroundColor3 = (tab == "esp") and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(60, 60, 80)
end

gui.buildTab.MouseButton1Click:Connect(function() switchTab("build") end)
gui.aimbotTab.MouseButton1Click:Connect(function() switchTab("aimbot") end)
gui.espTab.MouseButton1Click:Connect(function() switchTab("esp") end)

-- Build tab buttons
gui.toggle.MouseButton1Click:Connect(function()
    CONFIG.autoBuild.enabled = not CONFIG.autoBuild.enabled
    
    if CONFIG.autoBuild.enabled then
        gui.toggle.Text = "STOP AUTO BUILD"
        gui.toggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        spawn(function() autoBuildLoop(gui) end)
    else
        gui.toggle.Text = "START AUTO BUILD"
        gui.toggle.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    end
end)

gui.claim.MouseButton1Click:Connect(function()
    CONFIG.autoBuild.autoClaim = not CONFIG.autoBuild.autoClaim
    gui.claim.Text = "Auto Claim: " .. (CONFIG.autoBuild.autoClaim and "ON" or "OFF")
    gui.claim.BackgroundColor3 = CONFIG.autoBuild.autoClaim and Color3.fromRGB(50, 150, 255) or Color3.fromRGB(100, 100, 120)
end)

gui.reset.MouseButton1Click:Connect(function()
    stats.purchased = 0
    stats.failed = 0
    stats.kills = 0
    updateGUI(gui)
end)

-- Aimbot tab buttons
gui.aimbotToggle.MouseButton1Click:Connect(function()
    CONFIG.aimbot.enabled = not CONFIG.aimbot.enabled
    
    if CONFIG.aimbot.enabled then
        gui.aimbotToggle.Text = "DISABLE AIMBOT"
        gui.aimbotToggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    else
        gui.aimbotToggle.Text = "ENABLE AIMBOT"
        gui.aimbotToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    end
end)

-- FOV Slider
local draggingFOV = false
gui.fovSlider.MouseButton1Down:Connect(function()
    draggingFOV = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFOV = false
    end
end)

RunService.RenderStepped:Connect(function()
    if draggingFOV then
        local mousePos = UserInputService:GetMouseLocation()
        local sliderPos = gui.fovSlider.AbsolutePosition
        local sliderSize = gui.fovSlider.AbsoluteSize
        
        local relativeX = math.clamp(mousePos.X - sliderPos.X, 0, sliderSize.X)
        local percentage = relativeX / sliderSize.X
        
        CONFIG.aimbot.fov = math.floor(percentage * 200) + 50
        gui.fovLabel.Text = "FOV Size: " .. CONFIG.aimbot.fov
        gui.fovFill.Size = UDim2.new(percentage, 0, 1, 0)
        fovCircle.Radius = CONFIG.aimbot.fov
    end
end)

gui.showFOV.MouseButton1Click:Connect(function()
    CONFIG.aimbot.showFOV = not CONFIG.aimbot.showFOV
    gui.showFOV.Text = "Show FOV Circle: " .. (CONFIG.aimbot.showFOV and "ON" or "OFF")
    gui.showFOV.BackgroundColor3 = CONFIG.aimbot.showFOV and Color3.fromRGB(50, 150, 255) or Color3.fromRGB(100, 100, 120)
    fovCircle.Visible = CONFIG.aimbot.showFOV
end)

gui.teamCheck.MouseButton1Click:Connect(function()
    CONFIG.aimbot.teamCheck = not CONFIG.aimbot.teamCheck
    gui.teamCheck.Text = "Team Check: " .. (CONFIG.aimbot.teamCheck and "ON" or "OFF")
    gui.teamCheck.BackgroundColor3 = CONFIG.aimbot.teamCheck and Color3.fromRGB(50, 150, 255) or Color3.fromRGB(100, 100, 120)
end)

gui.headBtn.MouseButton1Click:Connect(function()
    CONFIG.aimbot.targetPart = "Head"
    gui.headBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
    gui.torsoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
end)

gui.torsoBtn.MouseButton1Click:Connect(function()
    CONFIG.aimbot.targetPart = "HumanoidRootPart"
    gui.headBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    gui.torsoBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
end)

-- ESP tab buttons
gui.espToggle.MouseButton1Click:Connect(function()
    CONFIG.esp.enabled = not CONFIG.esp.enabled
    
    if CONFIG.esp.enabled then
        gui.espToggle.Text = "DISABLE ESP"
        gui.espToggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    else
        gui.espToggle.Text = "ENABLE ESP"
        gui.espToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    end
end)

gui.boxes.MouseButton1Click:Connect(function()
    CONFIG.esp.boxes = not CONFIG.esp.boxes
    gui.boxes.Text = "Boxes: " .. (CONFIG.esp.boxes and "ON" or "OFF")
    gui.boxes.BackgroundColor3 = CONFIG.esp.boxes and Color3.fromRGB(50, 150, 255) or Color3.fromRGB(100, 100, 120)
end)

gui.names.MouseButton1Click:Connect(function()
    CONFIG.esp.names = not CONFIG.esp.names
    gui.names.Text = "Names: " .. (CONFIG.esp.names and "ON" or "OFF")
    gui.names.BackgroundColor3 = CONFIG.esp.names and Color3.fromRGB(50, 150, 255) or Color3.fromRGB(100, 100, 120)
end)

gui.health.MouseButton1Click:Connect(function()
    CONFIG.esp.health = not CONFIG.esp.health
    gui.health.Text = "Health: " .. (CONFIG.esp.health and "ON" or "OFF")
    gui.health.BackgroundColor3 = CONFIG.esp.health and Color3.fromRGB(50, 150, 255) or Color3.fromRGB(100, 100, 120)
end)

gui.distance.MouseButton1Click:Connect(function()
    CONFIG.esp.distance = not CONFIG.esp.distance
    gui.distance.Text = "Distance: " .. (CONFIG.esp.distance and "ON" or "OFF")
    gui.distance.BackgroundColor3 = CONFIG.esp.distance and Color3.fromRGB(50, 150, 255) or Color3.fromRGB(100, 100, 120)
end)

gui.espTeam.MouseButton1Click:Connect(function()
    CONFIG.esp.teamCheck = not CONFIG.esp.teamCheck
    gui.espTeam.Text = "Team Check: " .. (CONFIG.esp.teamCheck and "ON" or "OFF")
    gui.espTeam.BackgroundColor3 = CONFIG.esp.teamCheck and Color3.fromRGB(50, 150, 255) or Color3.fromRGB(100, 100, 120)
end)

-- Close button
gui.close.MouseButton1Click:Connect(function()
    CONFIG.autoBuild.enabled = false
    CONFIG.aimbot.enabled = false
    CONFIG.esp.enabled = false
    
    for _, esp in pairs(espObjects) do
        for _, drawing in pairs(esp) do
            drawing:Remove()
        end
    end
    
    if fovCircle then
        fovCircle:Remove()
    end
    
    gui.gui:Destroy()
end)

-- Main loops
RunService.RenderStepped:Connect(function()
    -- Update FOV circle position
    if fovCircle then
        fovCircle.Position = Vector2.new(mouse.X, mouse.Y + 36)
        fovCircle.Visible = CONFIG.aimbot.showFOV and CONFIG.aimbot.enabled
    end
    
    -- Aimbot
    if CONFIG.aimbot.enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        currentTarget = getClosestPlayer()
        if currentTarget then
            aimAt(currentTarget)
        end
    end
    
    -- ESP
    updateESP()
end)

print("[Freelo] Military Tycoon Freelo by Kimbo loaded!")
print("[Freelo] Features: Auto Build, Aimbot, ESP")
print("[Freelo] Press INSERT to toggle GUI visibility")
