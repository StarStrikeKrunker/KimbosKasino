-- Kimbo's Krackpipe - Jailbreak 2026
-- Version: 4.0.0 - "Welcome to Agartha"

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    wait(0.1)
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- Settings
local Settings = {
    AutoRob = false,
    AutoEscape = false,
    AutoFarm = false,
    AutoArrest = false,
    UseVehicles = false,
    FlightHeight = 150,
    FlightSpeed = 50,
    AntiAFK = false,
    
    -- Criminal ESP
    CriminalESP = false,
    CriminalNames = true,
    CriminalBoxes = true,
    CriminalDistance = true,
    CriminalHealth = true,
    
    -- Police ESP
    PoliceESP = false,
    PoliceNames = true,
    PoliceBoxes = true,
    PoliceDistance = true,
    PoliceHealth = true,
}

local ConfigFile = "KimbosKrackpipe_Config.json"

-- Status tracking (for live updates)
local Status = {
    CurrentAction = "Idle",
    LastRobbery = "None",
    RobberiesCompleted = 0,
    ArrestsMade = 0,
    EscapesMade = 0,
}

-- GUI References (for live updates)
local StatusLabel = nil

-- Locations
local Locations = {
    Robberies = {},
    Stores = {},
    Prison = nil,
}

-- ESP Storage
local ESPObjects = {
    Criminals = {},
    Police = {},
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

local function UpdateStatus(action, details)
    Status.CurrentAction = action
    if details then
        Status.LastRobbery = details
    end
end

local function SaveConfig()
    pcall(function()
        local json = HttpService:JSONEncode(Settings)
        writefile(ConfigFile, json)
        Notify("💾 Saved", "Config saved")
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
            Notify("📁 Loaded", "Settings restored")
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
        
        if name:match("Prison") or name:match("Jail") then
            Locations.Prison = obj
        end
    end
    
    print("[KRACKPIPE] Found " .. #Locations.Robberies .. " robberies")
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
        if not HumanoidRootPart then break end
        
        local distance = (waypoint - HumanoidRootPart.Position).Magnitude
        local duration = distance / Settings.FlightSpeed
        
        local tween = TweenService:Create(
            HumanoidRootPart,
            TweenInfo.new(math.max(duration, 0.1), Enum.EasingStyle.Linear),
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
    
    UpdateStatus("Escaping jail")
    Notify("🚨 Escaping", "Breaking out...")
    
    local escapePos = HumanoidRootPart.Position + Vector3.new(500, 100, 500)
    FlyTo(escapePos)
    
    wait(2)
    Status.EscapesMade = Status.EscapesMade + 1
    UpdateStatus("Idle")
    Notify("✅ Escaped", "Freedom")
end

local function IsRobberyAvailable(location)
    if not location then return false end
    
    -- Check for ProximityPrompts that are enabled
    for _, obj in pairs(location:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            if obj.Enabled then
                return true
            end
        end
    end
    
    -- Check for ClickDetectors
    for _, obj in pairs(location:GetDescendants()) do
        if obj:IsA("ClickDetector") then
            return true
        end
    end
    
    -- Check for common robbery indicators
    for _, obj in pairs(location:GetDescendants()) do
        if obj:IsA("BillboardGui") then
            local textLabel = obj:FindFirstChildOfClass("TextLabel")
            if textLabel then
                local text = textLabel.Text:lower()
                if text:match("open") or text:match("available") or text:match("rob") then
                    return true
                end
                if text:match("closed") or text:match("wait") or text:match("cooldown") then
                    return false
                end
            end
        end
    end
    
    return false
end

local function TryRobbery(location)
    if not location then return false end
    
    local activated = false
    
    -- Try ProximityPrompts
    for _, obj in pairs(location:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            pcall(function()
                fireproximityprompt(obj)
                activated = true
            end)
        end
    end
    
    -- Try ClickDetectors
    if not activated then
        for _, obj in pairs(location:GetDescendants()) do
            if obj:IsA("ClickDetector") then
                pcall(function()
                    fireclickdetector(obj)
                    activated = true
                end)
            end
        end
    end
    
    return activated
end

local function RobLocation(location)
    if not location or not HumanoidRootPart then return false end
    
    -- Check if robbery is available first
    if not IsRobberyAvailable(location) then
        return false
    end
    
    local targetPos = nil
    if location:IsA("Model") and location.PrimaryPart then
        targetPos = location.PrimaryPart.Position
    elseif location:IsA("Part") then
        targetPos = location.Position
    elseif location:IsA("Model") then
        local part = location:FindFirstChildOfClass("Part") or location:FindFirstChildOfClass("MeshPart")
        if part then
            targetPos = part.Position
        end
    end
    
    if not targetPos then return false end
    
    local robberyName = location.Name
    UpdateStatus("Flying to " .. robberyName)
    
    -- Fly to location
    FlyTo(targetPos)
    wait(1)
    
    UpdateStatus("Robbing " .. robberyName)
    
    -- Try to activate robbery
    local success = TryRobbery(location)
    
    if success then
        Status.RobberiesCompleted = Status.RobberiesCompleted + 1
        UpdateStatus("Robbing " .. robberyName .. " (waiting)")
        wait(3)
        return true
    end
    
    return false
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
    
    UpdateStatus("Arresting", criminal.Name)
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
    wait(1)
end

--[[ ESP SYSTEM ]]--

local function ClearESP(player)
    if ESPObjects.Criminals[player] then
        for _, obj in pairs(ESPObjects.Criminals[player]) do
            obj:Destroy()
        end
        ESPObjects.Criminals[player] = nil
    end
    
    if ESPObjects.Police[player] then
        for _, obj in pairs(ESPObjects.Police[player]) do
            obj:Destroy()
        end
        ESPObjects.Police[player] = nil
    end
end

local function CreateESP(player, isCriminal)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local storage = isCriminal and ESPObjects.Criminals or ESPObjects.Police
    local settings = isCriminal and {
        enabled = Settings.CriminalESP,
        names = Settings.CriminalNames,
        boxes = Settings.CriminalBoxes,
        distance = Settings.CriminalDistance,
        health = Settings.CriminalHealth,
        color = Color3.fromRGB(255, 100, 100) -- Red for criminals
    } or {
        enabled = Settings.PoliceESP,
        names = Settings.PoliceNames,
        boxes = Settings.PoliceBoxes,
        distance = Settings.PoliceDistance,
        health = Settings.PoliceHealth,
        color = Color3.fromRGB(100, 150, 255) -- Blue for police
    }
    
    if not settings.enabled then return end
    
    ClearESP(player)
    
    storage[player] = {}
    
    local hrp = player.Character.HumanoidRootPart
    local humanoid = player.Character:FindFirstChild("Humanoid")
    
    -- Billboard GUI
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Parent = hrp
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    table.insert(storage[player], billboard)
    
    -- Name label
    if settings.names then
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = billboard
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = settings.color
        nameLabel.TextSize = 14
        nameLabel.TextStrokeTransparency = 0.5
    end
    
    -- Distance label
    if settings.distance then
        local distLabel = Instance.new("TextLabel")
        distLabel.Parent = billboard
        distLabel.BackgroundTransparency = 1
        distLabel.Position = UDim2.new(0, 0, 0, 20)
        distLabel.Size = UDim2.new(1, 0, 0, 20)
        distLabel.Font = Enum.Font.Gotham
        distLabel.Text = "0 studs"
        distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        distLabel.TextSize = 12
        distLabel.TextStrokeTransparency = 0.5
        
        -- Update distance
        task.spawn(function()
            while distLabel and distLabel.Parent and HumanoidRootPart and hrp do
                wait(0.5)
                local dist = (HumanoidRootPart.Position - hrp.Position).Magnitude
                distLabel.Text = math.floor(dist) .. " studs"
            end
        end)
    end
    
    -- Health label
    if settings.health and humanoid then
        local healthLabel = Instance.new("TextLabel")
        healthLabel.Parent = billboard
        healthLabel.BackgroundTransparency = 1
        healthLabel.Position = UDim2.new(0, 0, 0, 40)
        healthLabel.Size = UDim2.new(1, 0, 0, 20)
        healthLabel.Font = Enum.Font.Gotham
        healthLabel.Text = "100 HP"
        healthLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        healthLabel.TextSize = 12
        healthLabel.TextStrokeTransparency = 0.5
        
        -- Update health
        task.spawn(function()
            while healthLabel and healthLabel.Parent and humanoid do
                wait(0.5)
                local hp = math.floor(humanoid.Health)
                healthLabel.Text = hp .. " HP"
                
                -- Color based on health
                if hp > 75 then
                    healthLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                elseif hp > 50 then
                    healthLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
                elseif hp > 25 then
                    healthLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
                else
                    healthLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
            end
        end)
    end
    
    -- Box ESP
    if settings.boxes then
        local box = Instance.new("BoxHandleAdornment")
        box.Parent = hrp
        box.Name = "ESPBox"
        box.Adornee = hrp
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Size = Vector3.new(4, 5, 1)
        box.Color3 = settings.color
        box.Transparency = 0.7
        table.insert(storage[player], box)
    end
end

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team then
            local teamName = player.Team.Name
            local isCriminal = teamName:match("Criminal") or teamName:match("Prisoner") or teamName:match("Inmate")
            local isPolice = teamName:match("Police") or teamName:match("Cop") or teamName:match("Guard")
            
            -- Clear old ESP
            ClearESP(player)
            
            -- Create new ESP
            if isCriminal and Settings.CriminalESP then
                CreateESP(player, true)
            elseif isPolice and Settings.PoliceESP then
                CreateESP(player, false)
            end
        end
    end
end

-- Update ESP when players are added/removed
Players.PlayerAdded:Connect(function(player)
    wait(1)
    UpdateESP()
end)

Players.PlayerRemoving:Connect(function(player)
    ClearESP(player)
end)

-- Update ESP when character spawns
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            wait(1)
            UpdateESP()
        end)
    end
end

-- ESP update loop
task.spawn(function()
    while wait(2) do
        if Settings.CriminalESP or Settings.PoliceESP then
            UpdateESP()
        else
            -- Clear all ESP if both are disabled
            for player, _ in pairs(ESPObjects.Criminals) do
                ClearESP(player)
            end
            for player, _ in pairs(ESPObjects.Police) do
                ClearESP(player)
            end
        end
    end
end)

--[[ AUTO FUNCTIONS ]]--

task.spawn(function()
    while wait(2) do
        if Settings.AutoRob then
            pcall(function()
                -- Check if in jail
                if IsInJail() and Settings.AutoEscape then
                    Escape()
                    wait(5)
                    return
                end
                
                -- Check team
                if LocalPlayer.Team and (LocalPlayer.Team.Name == "Police" or LocalPlayer.Team.Name == "Cop") then
                    UpdateStatus("Can't rob (Police Team)")
                    wait(5)
                    return
                end
                
                -- Find available robberies
                local availableRobberies = {}
                
                for _, robbery in pairs(Locations.Robberies) do
                    if IsRobberyAvailable(robbery) then
                        table.insert(availableRobberies, robbery)
                    end
                end
                
                for _, store in pairs(Locations.Stores) do
                    if IsRobberyAvailable(store) then
                        table.insert(availableRobberies, store)
                    end
                end
                
                -- Rob available locations
                if #availableRobberies > 0 then
                    for _, location in pairs(availableRobberies) do
                        if not Settings.AutoRob then 
                            UpdateStatus("Idle")
                            break 
                        end
                        
                        if RobLocation(location) then
                            wait(2)
                        end
                    end
                else
                    UpdateStatus("Scanning for available robberies")
                    wait(5)
                end
            end)
        else
            if Status.CurrentAction:match("Rob") or Status.CurrentAction:match("Flying") then
                UpdateStatus("Idle")
            end
        end
    end
end)

task.spawn(function()
    while wait(2) do
        if Settings.AutoArrest then
            pcall(function()
                local criminals = FindCriminals()
                
                if #criminals == 0 then
                    UpdateStatus("Searching for criminals")
                else
                    for _, criminal in pairs(criminals) do
                        if not Settings.AutoArrest then 
                            UpdateStatus("Idle")
                            break 
                        end
                        ArrestPlayer(criminal)
                        wait(2)
                    end
                end
            end)
        else
            if Status.CurrentAction:match("Arrest") or Status.CurrentAction:match("Searching") then
                UpdateStatus("Idle")
            end
        end
    end
end)

task.spawn(function()
    while wait(5) do
        if Settings.AutoEscape and IsInJail() then
            Escape()
        end
    end
end)

--[[ GUI ]]--

local function CreateGUI()
    -- Destroy existing
    if game.CoreGui:FindFirstChild("KimbosKrackpipeGUI") then
        game.CoreGui:FindFirstChild("KimbosKrackpipeGUI"):Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KimbosKrackpipeGUI"
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
    
    -- Minimize Icon
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
    
    local MinIconCorner = Instance.new("UICorner")
    MinIconCorner.CornerRadius = UDim.new(0, 10)
    MinIconCorner.Parent = MinimizeIcon
    
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
    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = TitleBar
    MinBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
    MinBtn.Position = UDim2.new(1, -80, 0, 10)
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Text = "_"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.TextSize = 16
    
    local MinBtnCorner = Instance.new("UICorner")
    MinBtnCorner.CornerRadius = UDim.new(0, 6)
    MinBtnCorner.Parent = MinBtn
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
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
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 0, 0, 50)
    TabContainer.Size = UDim2.new(1, 0, 0, 45)
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 0, 0, 95)
    ContentContainer.Size = UDim2.new(1, 0, 1, -95)
    
    -- Helper functions
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
            
            TweenService:Create(button, TweenInfo.new(0.3), {
                BackgroundColor3 = newState and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(60, 60, 70)
            }):Play()
        end)
        
        return button
    end
    
    local pages = {}
    
    -- HOME PAGE with live status
    local HomePage = Instance.new("Frame")
    HomePage.Parent = ContentContainer
    HomePage.BackgroundTransparency = 1
    HomePage.Size = UDim2.new(1, 0, 1, 0)
    HomePage.Visible = true
    pages["Home"] = HomePage
    
    -- Live Status Frame
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Parent = HomePage
    StatusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    StatusFrame.Position = UDim2.new(0, 30, 0, 20)
    StatusFrame.Size = UDim2.new(0, 380, 0, 200)
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = StatusFrame
    
    local StatusTitle = Instance.new("TextLabel")
    StatusTitle.Parent = StatusFrame
    StatusTitle.BackgroundTransparency = 1
    StatusTitle.Position = UDim2.new(0, 15, 0, 10)
    StatusTitle.Size = UDim2.new(1, -30, 0, 25)
    StatusTitle.Font = Enum.Font.GothamBold
    StatusTitle.Text = "🔴 LIVE STATUS"
    StatusTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
    StatusTitle.TextSize = 16
    StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    StatusLabel = Instance.new("TextLabel")
    StatusLabel.Parent = StatusFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 15, 0, 40)
    StatusLabel.Size = UDim2.new(1, -30, 1, -50)
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.Text = "Initializing..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.TextSize = 13
    StatusLabel.TextWrapped = true
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Update status in real-time
    task.spawn(function()
        while wait(0.3) do
            if StatusLabel and StatusLabel.Parent then
                local text = string.format(
                    "Action: %s\n\n" ..
                    "Stats:\n" ..
                    "  Robberies: %d\n" ..
                    "  Arrests: %d\n" ..
                    "  Escapes: %d\n\n" ..
                    "Features:\n" ..
                    "  Auto Rob: %s\n" ..
                    "  Auto Arrest: %s\n" ..
                    "  Auto Escape: %s",
                    Status.CurrentAction,
                    Status.RobberiesCompleted,
                    Status.ArrestsMade,
                    Status.EscapesMade,
                    Settings.AutoRob and "✓ ON" or "✗ OFF",
                    Settings.AutoArrest and "✓ ON" or "✗ OFF",
                    Settings.AutoEscape and "✓ ON" or "✗ OFF"
                )
                StatusLabel.Text = text
            else
                break
            end
        end
    end)
    
    -- Quick buttons
    CreateButton(HomePage, "💀 Respawn", UDim2.new(0, 30, 0, 240), UDim2.new(0, 180, 0, 40), Color3.fromRGB(192, 57, 43), function()
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.Health = 0
        end
        Notify("💀 Respawning", "Resetting character")
    end)
    
    CreateButton(HomePage, "🔄 Rescan", UDim2.new(0, 230, 0, 240), UDim2.new(0, 180, 0, 40), Color3.fromRGB(155, 89, 182), function()
        ScanLocations()
        Notify("🔍 Rescanning", "Finding locations")
    end)
    
    CreateButton(HomePage, "🚨 Escape", UDim2.new(0, 30, 0, 300), UDim2.new(0, 380, 0, 40), Color3.fromRGB(230, 126, 34), function()
        Escape()
    end)
    
    -- Criminal Page
    local CriminalPage = Instance.new("Frame")
    CriminalPage.Parent = ContentContainer
    CriminalPage.BackgroundTransparency = 1
    CriminalPage.Size = UDim2.new(1, 0, 1, 0)
    CriminalPage.Visible = false
    pages["Criminal"] = CriminalPage
    
    CreateToggle(CriminalPage, "Auto Rob", UDim2.new(0, 30, 0, 20), "AutoRob")
    CreateToggle(CriminalPage, "Auto Escape", UDim2.new(0, 30, 0, 70), "AutoEscape")
    
    -- ESP Section
    local espLabel = Instance.new("TextLabel")
    espLabel.Parent = CriminalPage
    espLabel.BackgroundTransparency = 1
    espLabel.Position = UDim2.new(0, 30, 0, 130)
    espLabel.Size = UDim2.new(1, -60, 0, 25)
    espLabel.Font = Enum.Font.GothamBold
    espLabel.Text = "━━━━ CRIMINAL ESP ━━━━"
    espLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    espLabel.TextSize = 14
    
    local espToggle = CreateToggle(CriminalPage, "Enable ESP", UDim2.new(0, 30, 0, 160), "CriminalESP")
    espToggle.MouseButton1Click:Connect(function()
        wait(0.1)
        UpdateESP()
    end)
    
    CreateToggle(CriminalPage, "Names", UDim2.new(0, 30, 0, 210), "CriminalNames")
    CreateToggle(CriminalPage, "Boxes", UDim2.new(0, 30, 0, 260), "CriminalBoxes")
    CreateToggle(CriminalPage, "Distance", UDim2.new(0, 30, 0, 310), "CriminalDistance")
    CreateToggle(CriminalPage, "Health", UDim2.new(0, 30, 0, 360), "CriminalHealth")
    
    -- Police Page
    local PolicePage = Instance.new("Frame")
    PolicePage.Parent = ContentContainer
    PolicePage.BackgroundTransparency = 1
    PolicePage.Size = UDim2.new(1, 0, 1, 0)
    PolicePage.Visible = false
    pages["Police"] = PolicePage
    
    CreateToggle(PolicePage, "Auto Arrest", UDim2.new(0, 30, 0, 20), "AutoArrest")
    
    -- ESP Section
    local policeEspLabel = Instance.new("TextLabel")
    policeEspLabel.Parent = PolicePage
    policeEspLabel.BackgroundTransparency = 1
    policeEspLabel.Position = UDim2.new(0, 30, 0, 80)
    policeEspLabel.Size = UDim2.new(1, -60, 0, 25)
    policeEspLabel.Font = Enum.Font.GothamBold
    policeEspLabel.Text = "━━━━ POLICE ESP ━━━━"
    policeEspLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
    policeEspLabel.TextSize = 14
    
    local policeEspToggle = CreateToggle(PolicePage, "Enable ESP", UDim2.new(0, 30, 0, 110), "PoliceESP")
    policeEspToggle.MouseButton1Click:Connect(function()
        wait(0.1)
        UpdateESP()
    end)
    
    CreateToggle(PolicePage, "Names", UDim2.new(0, 30, 0, 160), "PoliceNames")
    CreateToggle(PolicePage, "Boxes", UDim2.new(0, 30, 0, 210), "PoliceBoxes")
    CreateToggle(PolicePage, "Distance", UDim2.new(0, 30, 0, 260), "PoliceDistance")
    CreateToggle(PolicePage, "Health", UDim2.new(0, 30, 0, 310), "PoliceHealth")
    
    -- Settings Page
    local SettingsPage = Instance.new("Frame")
    SettingsPage.Parent = ContentContainer
    SettingsPage.BackgroundTransparency = 1
    SettingsPage.Size = UDim2.new(1, 0, 1, 0)
    SettingsPage.Visible = false
    pages["Settings"] = SettingsPage
    
    CreateToggle(SettingsPage, "Anti-AFK", UDim2.new(0, 30, 0, 20), "AntiAFK")
    
    CreateButton(SettingsPage, "💾 Save Config", UDim2.new(0, 30, 0, 80), UDim2.new(0, 180, 0, 40), Color3.fromRGB(39, 174, 96), function()
        SaveConfig()
    end)
    
    CreateButton(SettingsPage, "📁 Load Config", UDim2.new(0, 230, 0, 80), UDim2.new(0, 180, 0, 40), Color3.fromRGB(52, 152, 219), function()
        LoadConfig()
    end)
    
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
            for _, page in pairs(pages) do
                page.Visible = false
            end
            
            pages[tabName].Visible = true
            currentTab = tabName
            
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
    
    -- Minimize/Maximize
    MinBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        MinimizeIcon.Visible = true
    end)
    
    MinimizeIcon.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        MinimizeIcon.Visible = false
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    LoadConfig()
end

--[[ INIT ]]--

Notify("💊 Krackpipe", "Script loaded, welcome to Agartha")

wait(1)
ScanLocations()
wait(0.5)
CreateGUI()

Notify("✅ Ready", "Krackpipe active")
print("[KRACKPIPE] Loaded | Version 4.0.0")
