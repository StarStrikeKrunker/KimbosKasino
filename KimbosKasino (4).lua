-- Kimbo's Kasino - Jailbreak 2026
-- Version: 4.0.0

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
local ConfigFile = "KimbosKasino_Config.json"

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
        Notify("💾 Saved", "Config saved!")
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
            Notify("📁 Loaded", "Config loaded!")
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
    
    Notify("🚨 Escaping", "Breaking out of jail...")
    
    local escapePos = HumanoidRootPart.Position + Vector3.new(500, 100, 500)
    FlyTo(escapePos)
    
    wait(2)
    Notify("✅ Escaped", "Freedom!")
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
end

--[[ AUTO FUNCTIONS ]]--

task.spawn(function()
    while true do
        if Settings.AutoRob then
            pcall(function()
                if IsInJail() and Settings.AutoEscape then
                    Escape()
                    wait(5)
                    return
                end
                
                if LocalPlayer.Team and (LocalPlayer.Team.Name == "Police" or LocalPlayer.Team.Name == "Cop") then
                    wait(5)
                    return
                end
                
                for _, robbery in pairs(Locations.Robberies) do
                    if not Settings.AutoRob then break end
                    RobLocation(robbery)
                    wait(3)
                end
                
                for _, store in pairs(Locations.Stores) do
                    if not Settings.AutoRob then break end
                    RobLocation(store)
                    wait(2)
                end
            end)
        end
        wait(1)
    end
end)

task.spawn(function()
    while true do
        if Settings.AutoArrest then
            pcall(function()
                local criminals = FindCriminals()
                for _, criminal in pairs(criminals) do
                    if not Settings.AutoArrest then break end
                    ArrestPlayer(criminal)
                    wait(3)
                end
            end)
        end
        wait(1)
    end
end)

task.spawn(function()
    while true do
        if Settings.AutoEscape and IsInJail() then
            Escape()
        end
        wait(5)
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
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame
    
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
    Title.Size = UDim2.new(0.8, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🎰 KIMBO'S KASINO"
    Title.TextColor3 = Color3.fromRGB(0, 0, 0)
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Position = UDim2.new(0, 15, 0, 0)
    
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
        
        button.MouseButton1Click:Connect(function()
            if callback then
                callback()
            end
        end)
        
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
        local button = CreateButton(parent, text .. ": OFF", position, UDim2.new(0, 380, 0, 40), Color3.fromRGB(60, 60, 70), function()
            Settings[settingKey] = not Settings[settingKey]
            button.Text = text .. ": " .. (Settings[settingKey] and "ON" or "OFF")
            button.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(60, 60, 70)
        end)
        
        -- Set initial state
        button.Text = text .. ": " .. (Settings[settingKey] and "ON" or "OFF")
        button.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(60, 60, 70)
        
        return button
    end
    
    -- Create content pages
    local pages = {}
    
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
    
    CreateButton(CriminalPage, "💀 Escape Now", UDim2.new(0, 30, 0, 180), UDim2.new(0, 380, 0, 40), Color3.fromRGB(230, 126, 34), function()
        Escape()
    end)
    
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
    policeInfo.Text = "Auto Arrest will hunt down all criminals\nand arrest them automatically.\n\nMake sure you're on the Police team!"
    policeInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
    policeInfo.TextSize = 13
    policeInfo.TextWrapped = true
    policeInfo.TextYAlignment = Enum.TextYAlignment.Top
    
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
    
    local heightLabel = Instance.new("TextLabel")
    heightLabel.Parent = SettingsPage
    heightLabel.BackgroundTransparency = 1
    heightLabel.Position = UDim2.new(0, 30, 0, 130)
    heightLabel.Size = UDim2.new(0, 200, 0, 20)
    heightLabel.Font = Enum.Font.Gotham
    heightLabel.Text = "Flight Height: " .. Settings.FlightHeight .. "m"
    heightLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    heightLabel.TextSize = 13
    heightLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Parent = SettingsPage
    speedLabel.BackgroundTransparency = 1
    speedLabel.Position = UDim2.new(0, 30, 0, 200)
    speedLabel.Size = UDim2.new(0, 200, 0, 20)
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.Text = "Flight Speed: " .. Settings.FlightSpeed .. " s/s"
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedLabel.TextSize = 13
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Misc Page
    local MiscPage = Instance.new("Frame")
    MiscPage.Name = "MiscPage"
    MiscPage.Parent = ContentContainer
    MiscPage.BackgroundTransparency = 1
    MiscPage.Size = UDim2.new(1, 0, 1, 0)
    MiscPage.Visible = true -- Default page
    pages["Misc"] = MiscPage
    
    CreateButton(MiscPage, "💾 Save Config", UDim2.new(0, 30, 0, 20), UDim2.new(0, 180, 0, 40), Color3.fromRGB(39, 174, 96), function()
        SaveConfig()
    end)
    
    CreateButton(MiscPage, "📁 Load Config", UDim2.new(0, 230, 0, 20), UDim2.new(0, 180, 0, 40), Color3.fromRGB(52, 152, 219), function()
        LoadConfig()
    end)
    
    CreateButton(MiscPage, "💀 Respawn", UDim2.new(0, 30, 0, 80), UDim2.new(0, 380, 0, 40), Color3.fromRGB(192, 57, 43), function()
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.Health = 0
        end
        Notify("💀 Respawning", "Killing character...")
    end)
    
    CreateButton(MiscPage, "🔄 Rescan Locations", UDim2.new(0, 30, 0, 140), UDim2.new(0, 380, 0, 40), Color3.fromRGB(155, 89, 182), function()
        ScanLocations()
        Notify("🔍 Scanning", "Rescanning locations...")
    end)
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Parent = MiscPage
    statusLabel.BackgroundTransparency = 1
    statusLabel.Position = UDim2.new(0, 30, 0, 200)
    statusLabel.Size = UDim2.new(0, 380, 0, 150)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = "📊 Status:\n\n" ..
                       "Robberies Found: " .. #Locations.Robberies .. "\n" ..
                       "Stores Found: " .. #Locations.Stores .. "\n" ..
                       "Version: 4.0.0 - JB2026"
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    statusLabel.TextSize = 12
    statusLabel.TextWrapped = true
    statusLabel.TextYAlignment = Enum.TextYAlignment.Top
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Create tabs
    local tabs = {"Misc", "Criminal", "Police", "Settings"}
    local currentTab = "Misc"
    
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
    
    -- Close button functionality
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Load config on GUI creation
    LoadConfig()
end

--[[ INITIALIZATION ]]--

Notify("🎰 Kimbo's Kasino", "Loading v4.0.0...")

wait(1)

ScanLocations()

wait(0.5)

CreateGUI()

Notify("✅ Ready!", "Jailbreak 2026 Edition")

print("[KIMBO] ✅ Loaded successfully!")
print("[KIMBO] Version: 4.0.0 - JB2026")
print("[KIMBO] Robberies found: " .. #Locations.Robberies)
