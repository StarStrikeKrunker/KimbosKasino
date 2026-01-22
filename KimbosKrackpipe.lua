-- Kimbo's Krackpipe - Jailbreak 2026
-- Version: 4.0.0 - "Welcome to Agartha"

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

-- Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- Settings
local Settings = {
    AutoRob = false,
    AutoEscape = true,
    AutoFarm = false,
    AutoArrest = false,
    UseVehicles = true,
    FlightHeight = 150,
    FlightSpeed = 50,
    AntiAFK = true,
}

local CurrentVehicle = nil
local ConfigFile = "KimbosKrackpipe_Config.json"

-- Status tracking
local Status = {
    CurrentAction = "Idle",
    RobberiesCompleted = 0,
    ArrestsMade = 0,
    EscapesMade = 0,
    LastUpdate = "Ready",
}

-- Locations
local Locations = {
    Robberies = {},
    Stores = {},
    VehicleSpawns = {},
    Prison = nil,
}

--[[ UTILITIES ]]--

local function Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3,
        })
    end)
end

local function SaveConfig()
    pcall(function()
        local json = HttpService:JSONEncode(Settings)
        writefile(ConfigFile, json)
        Notify("💾 Config Saved", "Your degen settings are safe")
    end)
end

local function LoadConfig()
    if isfile and isfile(ConfigFile) then
        pcall(function()
            local json = readfile(ConfigFile)
            local loaded = HttpService:JSONDecode(json)
            for key, value in pairs(loaded) do
                if Settings[key] ~= nil then
                    Settings[key] = value
                end
            end
            Notify("📁 Config Loaded", "Back to your usual chaos")
        end)
        return true
    end
    return false
end

--[[ ANTI-AFK ]]--

task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        if Settings.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end)

--[[ LOCATION SCANNER ]]--

local function ScanLocations()
    Locations.Robberies = {}
    Locations.Stores = {}
    Locations.VehicleSpawns = {}
    
    local robberyPatterns = {"Bank", "Museum", "Jewelry", "Power", "Casino", "Cargo", "Tomb", "Train", "Nuclear", "Refinery", "Gallery", "Mansion", "Space", "Submarine", "Skyscraper"}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = obj.Name
        
        for _, pattern in pairs(robberyPatterns) do
            if name:match(pattern) and (obj:IsA("Model") or obj:IsA("Part")) then
                table.insert(Locations.Robberies, obj)
                break
            end
        end
        
        if name:match("Store") or name:match("Gas") or name:match("Donut") then
            table.insert(Locations.Stores, obj)
        end
        
        if name:match("VehicleSpawn") then
            table.insert(Locations.VehicleSpawns, obj)
        end
        
        if name:match("Prison") or name:match("Jail") then
            Locations.Prison = obj
        end
    end
end

--[[ MOVEMENT ]]--

local function FlyTo(position)
    if not HumanoidRootPart then return end
    
    local waypoints = {
        Vector3.new(HumanoidRootPart.Position.X, Settings.FlightHeight, HumanoidRootPart.Position.Z),
        Vector3.new(position.X, Settings.FlightHeight, position.Z),
        position
    }
    
    for _, waypoint in ipairs(waypoints) do
        local distance = (waypoint - HumanoidRootPart.Position).Magnitude
        local duration = distance / Settings.FlightSpeed
        
        local tween = TweenService:Create(
            HumanoidRootPart,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {CFrame = CFrame.new(waypoint)}
        )
        
        tween:Play()
        tween.Completed:Wait()
    end
end

--[[ JAILBREAK FUNCTIONS ]]--

local function IsInJail()
    if LocalPlayer.Team and LocalPlayer.Team.Name == "Prisoner" then
        return true
    end
    
    if Locations.Prison and HumanoidRootPart then
        local dist = (Locations.Prison.Position - HumanoidRootPart.Position).Magnitude
        return dist < 300
    end
    
    return false
end

local function Escape()
    if not IsInJail() then return end
    
    Status.CurrentAction = "Escaping Jail"
    Notify("🚨 Prison Break", "Time to dip, they can't hold us")
    
    local escapePos = HumanoidRootPart.Position + Vector3.new(500, 100, 500)
    FlyTo(escapePos)
    
    wait(2)
    Status.EscapesMade = Status.EscapesMade + 1
    Status.CurrentAction = "Idle"
    Notify("✅ Free", "Welcome back to the streets")
end

local function RobLocation(location)
    if not location then return end
    
    local targetPos = nil
    if location:IsA("Model") and location.PrimaryPart then
        targetPos = location.PrimaryPart.Position
    elseif location:IsA("Part") then
        targetPos = location.Position
    end
    
    if not targetPos then return end
    
    Status.CurrentAction = "Robbing: " .. location.Name
    FlyTo(targetPos)
    wait(1)
    
    -- Try to activate robbery
    for _, obj in pairs(location:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            fireproximityprompt(obj)
        elseif obj:IsA("ClickDetector") then
            fireclickdetector(obj)
        end
    end
    
    Status.RobberiesCompleted = Status.RobberiesCompleted + 1
    wait(0.5)
end

local function FindCriminals()
    local criminals = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team then
            if player.Team.Name:match("Criminal") or player.Team.Name:match("Prisoner") then
                table.insert(criminals, player)
            end
        end
    end
    return criminals
end

local function ArrestPlayer(criminal)
    if not criminal.Character or not criminal.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    Status.CurrentAction = "Arresting: " .. criminal.Name
    local crimPos = criminal.Character.HumanoidRootPart.Position
    FlyTo(crimPos)
    
    wait(0.5)
    
    -- Try to arrest
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool.Name:lower():match("cuff") or tool.Name:lower():match("arrest") then
            Character.Humanoid:EquipTool(tool)
            tool:Activate()
        end
    end
    
    Status.ArrestsMade = Status.ArrestsMade + 1
end

--[[ AUTO FUNCTIONS ]]--

task.spawn(function()
    while true do
        wait(1)
        if Settings.AutoRob then
            pcall(function()
                if IsInJail() and Settings.AutoEscape then
                    Escape()
                    wait(5)
                    return
                end
                
                if LocalPlayer.Team and (LocalPlayer.Team.Name == "Police" or LocalPlayer.Team.Name == "Cop") then
                    Status.CurrentAction = "Idle (Police Team)"
                    wait(5)
                    return
                end
                
                for _, robbery in pairs(Locations.Robberies) do
                    if not Settings.AutoRob then 
                        Status.CurrentAction = "Idle"
                        break 
                    end
                    RobLocation(robbery)
                    wait(3)
                end
                
                for _, store in pairs(Locations.Stores) do
                    if not Settings.AutoRob then 
                        Status.CurrentAction = "Idle"
                        break 
                    end
                    RobLocation(store)
                    wait(2)
                end
                
                Status.CurrentAction = "Idle"
            end)
        else
            if Status.CurrentAction:match("Robbing") then
                Status.CurrentAction = "Idle"
            end
        end
    end
end)

task.spawn(function()
    while true do
        wait(1)
        if Settings.AutoArrest then
            pcall(function()
                local criminals = FindCriminals()
                if #criminals == 0 then
                    Status.CurrentAction = "Searching for Criminals"
                end
                
                for _, criminal in pairs(criminals) do
                    if not Settings.AutoArrest then 
                        Status.CurrentAction = "Idle"
                        break 
                    end
                    ArrestPlayer(criminal)
                    wait(3)
                end
                
                if Settings.AutoArrest then
                    Status.CurrentAction = "Idle"
                end
            end)
        else
            if Status.CurrentAction:match("Arresting") or Status.CurrentAction:match("Searching") then
                Status.CurrentAction = "Idle"
            end
        end
    end
end)

task.spawn(function()
    while true do
        wait(5)
        if Settings.AutoEscape and IsInJail() then
            Escape()
        end
    end
end)

--[[ GUI ]]--

local function CreateGUI()
    -- Destroy existing GUI
    if game.CoreGui:FindFirstChild("KimbosKasinoGUI") then
        game.CoreGui:FindFirstChild("KimbosKasinoGUI"):Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KimbosKasinoGUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
    MainFrame.Size = UDim2.new(0, 450, 0, 500)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame
    
    -- Minimize Button (small icon when minimized)
    local MinimizeIcon = Instance.new("TextButton")
    MinimizeIcon.Name = "MinimizeIcon"
    MinimizeIcon.Parent = ScreenGui
    MinimizeIcon.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    MinimizeIcon.Position = UDim2.new(0, 10, 0.5, -25)
    MinimizeIcon.Size = UDim2.new(0, 50, 0, 50)
    MinimizeIcon.Font = Enum.Font.GothamBold
    MinimizeIcon.Text = "💊"
    MinimizeIcon.TextSize = 24
    MinimizeIcon.Visible = false
    MinimizeIcon.Active = true
    MinimizeIcon.Draggable = true
    
    local MinimizeIconCorner = Instance.new("UICorner")
    MinimizeIconCorner.CornerRadius = UDim.new(0, 10)
    MinimizeIconCorner.Parent = MinimizeIcon
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = TitleBar
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TitleBar
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "💊 KIMBO'S KRACKPIPE"
    Title.TextColor3 = Color3.fromRGB(0, 0, 0)
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Position = UDim2.new(0, 15, 0, 0)
    
    -- Minimize Button
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Parent = TitleBar
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
    MinimizeBtn.Position = UDim2.new(1, -80, 0, 10)
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Text = "_"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.TextSize = 16
    
    local MinimizeBtnCorner = Instance.new("UICorner")
    MinimizeBtnCorner.CornerRadius = UDim.new(0, 6)
    MinimizeBtnCorner.Parent = MinimizeBtn
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = TitleBar
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Position = UDim2.new(1, -40, 0, 10)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 16
    
    local CloseBtnCorner = Instance.new("UICorner")
    CloseBtnCorner.CornerRadius = UDim.new(0, 6)
    CloseBtnCorner.Parent = CloseBtn
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 0, 0, 50)
    TabContainer.Size = UDim2.new(1, 0, 0, 45)
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 0, 0, 95)
    ContentContainer.Size = UDim2.new(1, 0, 1, -95)
    
    -- Helper function to create buttons
    local function CreateButton(parent, text, position, size, color, callback)
        local button = Instance.new("TextButton")
        button.Parent = parent
        button.BackgroundColor3 = color
        button.Position = position
        button.Size = size
        button.Font = Enum.Font.GothamBold
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        button.AutoButtonColor = false
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = button
        
        if callback then
            button.MouseButton1Click:Connect(callback)
        end
        
        -- Hover effect
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(
                math.min(color.R * 255 + 20, 255),
                math.min(color.G * 255 + 20, 255),
                math.min(color.B * 255 + 20, 255)
            )}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        end)
        
        return button
    end
    
    -- Helper to create toggle button
    local function CreateToggle(parent, text, position, settingKey)
        local isOn = Settings[settingKey]
        local button = CreateButton(
            parent, 
            text .. ": " .. (isOn and "ON" or "OFF"), 
            position, 
            UDim2.new(0, 380, 0, 40), 
            isOn and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(60, 60, 70),
            nil
        )
        
        button.MouseButton1Click:Connect(function()
            Settings[settingKey] = not Settings[settingKey]
            local newState = Settings[settingKey]
            button.Text = text .. ": " .. (newState and "ON" or "OFF")
            
            -- Animate color change
            TweenService:Create(button, TweenInfo.new(0.3), {
                BackgroundColor3 = newState and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(60, 60, 70)
            }):Play()
            
            print("[KIMBO] " .. text .. " set to: " .. tostring(newState))
        end)
        
        return button
    end
    
    -- Create content pages
    local pages = {}
    
    -- HOME PAGE (with live status)
    local HomePage = Instance.new("Frame")
    HomePage.Name = "HomePage"
    HomePage.Parent = ContentContainer
    HomePage.BackgroundTransparency = 1
    HomePage.Size = UDim2.new(1, 0, 1, 0)
    HomePage.Visible = true
    pages["Home"] = HomePage
    
    -- Live Status Display
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Parent = HomePage
    StatusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    StatusFrame.Position = UDim2.new(0, 30, 0, 20)
    StatusFrame.Size = UDim2.new(0, 380, 0, 180)
    
    local StatusFrameCorner = Instance.new("UICorner")
    StatusFrameCorner.CornerRadius = UDim.new(0, 8)
    StatusFrameCorner.Parent = StatusFrame
    
    local StatusTitle = Instance.new("TextLabel")
    StatusTitle.Parent = StatusFrame
    StatusTitle.BackgroundTransparency = 1
    StatusTitle.Position = UDim2.new(0, 15, 0, 10)
    StatusTitle.Size = UDim2.new(1, -30, 0, 25)
    StatusTitle.Font = Enum.Font.GothamBold
    StatusTitle.Text = "📊 LIVE STATUS"
    StatusTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
    StatusTitle.TextSize = 16
    StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Parent = StatusFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 15, 0, 40)
    StatusLabel.Size = UDim2.new(1, -30, 1, -50)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "Initializing..."
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.TextSize = 13
    StatusLabel.TextWrapped = true
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Update status label continuously
    task.spawn(function()
        while true do
            wait(0.5)
            if StatusLabel and StatusLabel.Parent then
                local text = string.format(
                    "Current Action: %s\n\n" ..
                    "Statistics:\n" ..
                    "  • Robberies: %d\n" ..
                    "  • Arrests: %d\n" ..
                    "  • Escapes: %d\n\n" ..
                    "Active Features:\n" ..
                    "  • Auto Rob: %s\n" ..
                    "  • Auto Arrest: %s\n" ..
                    "  • Auto Escape: %s",
                    Status.CurrentAction,
                    Status.RobberiesCompleted,
                    Status.ArrestsMade,
                    Status.EscapesMade,
                    Settings.AutoRob and "✓" or "✗",
                    Settings.AutoArrest and "✓" or "✗",
                    Settings.AutoEscape and "✓" or "✗"
                )
                StatusLabel.Text = text
            else
                break
            end
        end
    end)
    
    -- Quick Actions
    CreateButton(HomePage, "💀 Respawn", UDim2.new(0, 30, 0, 220), UDim2.new(0, 180, 0, 40), Color3.fromRGB(192, 57, 43), function()
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.Health = 0
        end
        Notify("💀 Self Delete", "Respawning your broken avatar")
    end)
    
    CreateButton(HomePage, "🔄 Rescan", UDim2.new(0, 230, 0, 220), UDim2.new(0, 180, 0, 40), Color3.fromRGB(155, 89, 182), function()
        ScanLocations()
        Notify("🔍 Scanning", "Finding new licks...")
    end)
    
    CreateButton(HomePage, "🚨 Escape Now", UDim2.new(0, 30, 0, 280), UDim2.new(0, 380, 0, 40), Color3.fromRGB(230, 126, 34), function()
        Escape()
    end)
    
    -- Criminal Page
    local CriminalPage = Instance.new("Frame")
    CriminalPage.Name = "CriminalPage"
    CriminalPage.Parent = ContentContainer
    CriminalPage.BackgroundTransparency = 1
    CriminalPage.Size = UDim2.new(1, 0, 1, 0)
    CriminalPage.Visible = false
    pages["Criminal"] = CriminalPage
    
    CreateToggle(CriminalPage, "Auto Rob", UDim2.new(0, 30, 0, 20), "AutoRob")
    CreateToggle(CriminalPage, "Auto Escape", UDim2.new(0, 30, 0, 70), "AutoEscape")
    CreateToggle(CriminalPage, "Auto Farm Items", UDim2.new(0, 30, 0, 120), "AutoFarm")
    
    local crimInfo = Instance.new("TextLabel")
    crimInfo.Parent = CriminalPage
    crimInfo.BackgroundTransparency = 1
    crimInfo.Position = UDim2.new(0, 30, 0, 180)
    crimInfo.Size = UDim2.new(0, 380, 0, 100)
    crimInfo.Font = Enum.Font.Gotham
    crimInfo.Text = "🏴 Criminal Features\n\nAuto Rob hits every location automatically.\nGet that bag while you AFK.\n\nAuto Escape gets you out when the cops show up."
    crimInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
    crimInfo.TextSize = 13
    crimInfo.TextWrapped = true
    crimInfo.TextYAlignment = Enum.TextYAlignment.Top
    crimInfo.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Police Page
    local PolicePage = Instance.new("Frame")
    PolicePage.Name = "PolicePage"
    PolicePage.Parent = ContentContainer
    PolicePage.BackgroundTransparency = 1
    PolicePage.Size = UDim2.new(1, 0, 1, 0)
    PolicePage.Visible = false
    pages["Police"] = PolicePage
    
    CreateToggle(PolicePage, "Auto Arrest", UDim2.new(0, 30, 0, 20), "AutoArrest")
    
    local policeInfo = Instance.new("TextLabel")
    policeInfo.Parent = PolicePage
    policeInfo.BackgroundTransparency = 1
    policeInfo.Position = UDim2.new(0, 30, 0, 80)
    policeInfo.Size = UDim2.new(0, 380, 0, 100)
    policeInfo.Font = Enum.Font.Gotham
    policeInfo.Text = "👮 Police Features\n\nAuto Arrest hunts down criminals\nand cuffs them automatically.\n\nBe a hero or just farm arrests. Your choice."
    policeInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
    policeInfo.TextSize = 13
    policeInfo.TextWrapped = true
    policeInfo.TextYAlignment = Enum.TextYAlignment.Top
    policeInfo.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Settings Page
    local SettingsPage = Instance.new("Frame")
    SettingsPage.Name = "SettingsPage"
    SettingsPage.Parent = ContentContainer
    SettingsPage.BackgroundTransparency = 1
    SettingsPage.Size = UDim2.new(1, 0, 1, 0)
    SettingsPage.Visible = false
    pages["Settings"] = SettingsPage
    
    CreateToggle(SettingsPage, "Use Vehicles", UDim2.new(0, 30, 0, 20), "UseVehicles")
    CreateToggle(SettingsPage, "Anti-AFK", UDim2.new(0, 30, 0, 70), "AntiAFK")
    
    CreateButton(SettingsPage, "💾 Save Config", UDim2.new(0, 30, 0, 140), UDim2.new(0, 180, 0, 40), Color3.fromRGB(39, 174, 96), function()
        SaveConfig()
    end)
    
    CreateButton(SettingsPage, "📁 Load Config", UDim2.new(0, 230, 0, 140), UDim2.new(0, 180, 0, 40), Color3.fromRGB(52, 152, 219), function()
        LoadConfig()
    end)
    
    local settingsInfo = Instance.new("TextLabel")
    settingsInfo.Parent = SettingsPage
    settingsInfo.BackgroundTransparency = 1
    settingsInfo.Position = UDim2.new(0, 30, 0, 200)
    settingsInfo.Size = UDim2.new(0, 380, 0, 150)
    settingsInfo.Font = Enum.Font.Gotham
    settingsInfo.Text = string.format(
        "⚙️ Configuration\n\n" ..
        "Flight Height: %dm (Anti-Cheat Safe)\n" ..
        "Flight Speed: %d studs/s\n\n" ..
        "Version: 4.0.0 - JB2026\n" ..
        "Locations: %d robberies, %d stores",
        Settings.FlightHeight,
        Settings.FlightSpeed,
        #Locations.Robberies,
        #Locations.Stores
    )
    settingsInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
    settingsInfo.TextSize = 12
    settingsInfo.TextWrapped = true
    settingsInfo.TextYAlignment = Enum.TextYAlignment.Top
    settingsInfo.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Create tabs
    local tabs = {"Home", "Criminal", "Police", "Settings"}
    local currentTab = "Home"
    
    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Parent = TabContainer
        tabButton.BackgroundColor3 = tabName == currentTab and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(50, 50, 60)
        tabButton.Position = UDim2.new((i-1) * 0.25, 0, 0, 5)
        tabButton.Size = UDim2.new(0.24, 0, 0, 35)
        tabButton.Font = Enum.Font.GothamBold
        tabButton.Text = tabName
        tabButton.TextColor3 = tabName == currentTab and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        tabButton.TextSize = 13
        tabButton.AutoButtonColor = false
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabButton
        
        tabButton.MouseButton1Click:Connect(function()
            -- Hide all pages
            for _, page in pairs(pages) do
                page.Visible = false
            end
            
            -- Show selected page
            pages[tabName].Visible = true
            currentTab = tabName
            
            -- Update all tab buttons
            for _, child in pairs(TabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    if child.Text == tabName then
                        child.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                        child.TextColor3 = Color3.fromRGB(0, 0, 0)
                    else
                        child.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                        child.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                end
            end
        end)
    end
    
    -- Minimize/Maximize functionality
    MinimizeBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        MinimizeIcon.Visible = true
        Notify("📦 Hidden", "Click the pill to come back")
    end)
    
    MinimizeIcon.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        MinimizeIcon.Visible = false
    end)
    
    -- Close button functionality
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Load config on GUI creation
    LoadConfig()
end

--[[ INITIALIZATION ]]--

Notify("💊 Kimbo's Krackpipe", "Script loaded, welcome to Agartha")

wait(1)

ScanLocations()

wait(0.5)

CreateGUI()

Notify("✅ Ready", "Time to get this bread")

print("[KIMBO] ✅ Krackpipe loaded successfully!")
print("[KIMBO] Version: 4.0.0 - Agartha Edition")
print("[KIMBO] Robberies found: " .. #Locations.Robberies)
print("[KIMBO] Welcome to the underground")
