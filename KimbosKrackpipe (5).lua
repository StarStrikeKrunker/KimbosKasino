-- Kimbo's Krackpipe - Jailbreak 2026
-- Version: 4.1.0 - "Welcome to Agartha"

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
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
    wait(0.1)
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- Settings (ALL OFF BY DEFAULT)
local Settings = {
    AutoRob = false,
    AutoEscape = false,
    AutoArrest = false,
    AntiAFK = false,
    
    -- Criminal ESP
    CriminalESP = false,
    CriminalNames = false,
    CriminalBoxes = false,
    CriminalDistance = false,
    CriminalHealth = false,
    
    -- Police ESP
    PoliceESP = false,
    PoliceNames = false,
    PoliceBoxes = false,
    PoliceDistance = false,
    PoliceHealth = false,
}

local ConfigFile = "KimbosKrackpipe_Config.json"

-- Status tracking
local Status = {
    CurrentAction = "Idle",
    RobberiesCompleted = 0,
    ArrestsMade = 0,
    EscapesMade = 0,
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

local function UpdateStatus(action)
    Status.CurrentAction = action
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

--[[ MOVEMENT ]]--

local function TeleportTo(position)
    if not HumanoidRootPart then return end
    
    HumanoidRootPart.CFrame = CFrame.new(position)
    wait(0.1)
end

--[[ JAILBREAK FUNCTIONS ]]--

local function IsInJail()
    if LocalPlayer.Team and LocalPlayer.Team.Name == "Prisoner" then
        return true
    end
    return false
end

local function Escape()
    if not IsInJail() then return end
    
    UpdateStatus("Escaping jail")
    Notify("🚨 Escaping", "Breaking out...")
    
    local escapePos = HumanoidRootPart.Position + Vector3.new(500, 100, 500)
    TeleportTo(escapePos)
    
    wait(2)
    Status.EscapesMade = Status.EscapesMade + 1
    UpdateStatus("Idle")
    Notify("✅ Escaped", "Freedom")
end

local function FindStores()
    local stores = {}
    
    -- Find donut shops and gas stations
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "DonutStore" or obj.Name == "GasStation" or obj.Name == "Store" then
            table.insert(stores, obj)
        end
    end
    
    return stores
end

local function RobStore(store)
    if not store or not HumanoidRootPart then return false end
    
    UpdateStatus("Robbing " .. store.Name)
    
    -- Find the till/register
    local till = store:FindFirstChild("Till") or store:FindFirstChild("Register") or store:FindFirstChild("Counter")
    
    if till then
        -- Teleport to till
        local tillPos = till.Position
        TeleportTo(tillPos)
        wait(1)
        
        -- Look for ProximityPrompt on till
        for _, obj in pairs(till:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                pcall(function()
                    fireproximityprompt(obj)
                    print("[KRACKPIPE] Robbed " .. store.Name)
                    Status.RobberiesCompleted = Status.RobberiesCompleted + 1
                    wait(2)
                end)
                return true
            end
        end
        
        -- Try ClickDetector
        for _, obj in pairs(till:GetDescendants()) do
            if obj:IsA("ClickDetector") then
                pcall(function()
                    fireclickdetector(obj)
                    print("[KRACKPIPE] Robbed " .. store.Name)
                    Status.RobberiesCompleted = Status.RobberiesCompleted + 1
                    wait(2)
                end)
                return true
            end
        end
    else
        -- If no till found, just teleport to the store center
        local storePart = store:FindFirstChildOfClass("Part") or store:FindFirstChildOfClass("MeshPart")
        if storePart then
            TeleportTo(storePart.Position)
            wait(1)
            
            -- Look for any ProximityPrompts in the store
            for _, obj in pairs(store:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    pcall(function()
                        fireproximityprompt(obj)
                        print("[KRACKPIPE] Robbed " .. store.Name)
                        Status.RobberiesCompleted = Status.RobberiesCompleted + 1
                        wait(2)
                    end)
                    return true
                end
            end
        end
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
    
    UpdateStatus("Arresting " .. criminal.Name)
    local crimPos = criminal.Character.HumanoidRootPart.Position
    TeleportTo(crimPos)
    
    wait(0.5)
    
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
        color = Color3.fromRGB(255, 100, 100)
    } or {
        enabled = Settings.PoliceESP,
        names = Settings.PoliceNames,
        boxes = Settings.PoliceBoxes,
        distance = Settings.PoliceDistance,
        health = Settings.PoliceHealth,
        color = Color3.fromRGB(100, 150, 255)
    }
    
    if not settings.enabled then return end
    
    ClearESP(player)
    
    storage[player] = {}
    
    local hrp = player.Character.HumanoidRootPart
    local humanoid = player.Character:FindFirstChild("Humanoid")
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Parent = hrp
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    table.insert(storage[player], billboard)
    
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
        
        task.spawn(function()
            while distLabel and distLabel.Parent and HumanoidRootPart and hrp do
                wait(0.5)
                local dist = (HumanoidRootPart.Position - hrp.Position).Magnitude
                distLabel.Text = math.floor(dist) .. " studs"
            end
        end)
    end
    
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
        
        task.spawn(function()
            while healthLabel and healthLabel.Parent and humanoid do
                wait(0.5)
                local hp = math.floor(humanoid.Health)
                healthLabel.Text = hp .. " HP"
                
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
            
            ClearESP(player)
            
            if isCriminal and Settings.CriminalESP then
                CreateESP(player, true)
            elseif isPolice and Settings.PoliceESP then
                CreateESP(player, false)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    wait(1)
    UpdateESP()
end)

Players.PlayerRemoving:Connect(function(player)
    ClearESP(player)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            wait(1)
            UpdateESP()
        end)
    end
end

task.spawn(function()
    while wait(2) do
        if Settings.CriminalESP or Settings.PoliceESP then
            UpdateESP()
        else
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
    while wait(1) do
        if Settings.AutoRob then
            pcall(function()
                if IsInJail() and Settings.AutoEscape then
                    Escape()
                    wait(5)
                    return
                end
                
                if LocalPlayer.Team and (LocalPlayer.Team.Name == "Police" or LocalPlayer.Team.Name == "Cop") then
                    UpdateStatus("Can't rob (Police Team)")
                    wait(5)
                    return
                end
                
                UpdateStatus("Searching for stores")
                local stores = FindStores()
                
                if #stores > 0 then
                    for _, store in pairs(stores) do
                        if not Settings.AutoRob then 
                            UpdateStatus("Idle")
                            break 
                        end
                        
                        RobStore(store)
                        wait(2)
                    end
                else
                    UpdateStatus("No stores found")
                    wait(5)
                end
            end)
        else
            if Status.CurrentAction:match("Rob") or Status.CurrentAction:match("Searching") then
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
    if game.CoreGui:FindFirstChild("KimbosKrackpipeGUI") then
        game.CoreGui:FindFirstChild("KimbosKrackpipeGUI"):Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KimbosKrackpipeGUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
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
    
    local TabContainer = Instance.new("Frame")
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 0, 0, 50)
    TabContainer.Size = UDim2.new(1, 0, 0, 45)
    
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 0, 0, 95)
    ContentContainer.Size = UDim2.new(1, 0, 1, -95)
    
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
        
        -- RED = OFF, GREEN = ON
        local offColor = Color3.fromRGB(200, 50, 50)
        local onColor = Color3.fromRGB(50, 200, 50)
        
        local button = CreateButton(
            parent, 
            text .. ": " .. (isOn and "ON" or "OFF"), 
            position, 
            UDim2.new(0, 380, 0, 40), 
            isOn and onColor or offColor,
            nil
        )
        
        button.MouseButton1Click:Connect(function()
            Settings[settingKey] = not Settings[settingKey]
            local newState = Settings[settingKey]
            button.Text = text .. ": " .. (newState and "ON" or "OFF")
            
            -- Animate to GREEN when ON, RED when OFF
            TweenService:Create(button, TweenInfo.new(0.3), {
                BackgroundColor3 = newState and onColor or offColor
            }):Play()
            
            print("[KRACKPIPE] " .. text .. " = " .. tostring(newState))
        end)
        
        return button
    end
    
    local pages = {}
    
    -- HOME PAGE
    local HomePage = Instance.new("Frame")
    HomePage.Parent = ContentContainer
    HomePage.BackgroundTransparency = 1
    HomePage.Size = UDim2.new(1, 0, 1, 0)
    HomePage.Visible = true
    pages["Home"] = HomePage
    
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
    
    local StatusLabel = Instance.new("TextLabel")
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
    
    CreateButton(HomePage, "💀 Respawn", UDim2.new(0, 30, 0, 240), UDim2.new(0, 180, 0, 40), Color3.fromRGB(192, 57, 43), function()
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.Health = 0
        end
        Notify("💀 Respawning", "Resetting")
    end)
    
    CreateButton(HomePage, "🚨 Escape", UDim2.new(0, 230, 0, 240), UDim2.new(0, 180, 0, 40), Color3.fromRGB(230, 126, 34), function()
        Escape()
    end)
    
    -- CRIMINAL PAGE
    local CriminalPage = Instance.new("Frame")
    CriminalPage.Parent = ContentContainer
    CriminalPage.BackgroundTransparency = 1
    CriminalPage.Size = UDim2.new(1, 0, 1, 0)
    CriminalPage.Visible = false
    pages["Criminal"] = CriminalPage
    
    CreateToggle(CriminalPage, "Auto Rob", UDim2.new(0, 30, 0, 20), "AutoRob")
    CreateToggle(CriminalPage, "Auto Escape", UDim2.new(0, 30, 0, 70), "AutoEscape")
    
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
    
    -- POLICE PAGE
    local PolicePage = Instance.new("Frame")
    PolicePage.Parent = ContentContainer
    PolicePage.BackgroundTransparency = 1
    PolicePage.Size = UDim2.new(1, 0, 1, 0)
    PolicePage.Visible = false
    pages["Police"] = PolicePage
    
    CreateToggle(PolicePage, "Auto Arrest", UDim2.new(0, 30, 0, 20), "AutoArrest")
    
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
    
    -- SETTINGS PAGE
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
CreateGUI()
Notify("✅ Ready", "Krackpipe active")
print("[KRACKPIPE] Loaded v4.1.0")
print("[KRACKPIPE] All features start OFF")
print("[KRACKPIPE] RED = OFF | GREEN = ON")
