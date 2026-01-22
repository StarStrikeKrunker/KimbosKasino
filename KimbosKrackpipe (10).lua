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
    AutoEscape = false,
    AutoArrest = false,
    AntiAFK = false,
    
    -- Aimbot
    SilentAim = false,
    Triggerbot = false,
    ShowFOV = false,
    FOVSize = 100,
    WallCheck = true,
    TeamCheck = true,
    
    -- Misc
    VehicleSpeed = 100,
    
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

-- Aimbot Storage
local FOVCircle = nil
local CurrentTarget = nil

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

local function SmoothFlyTo(position, speed)
    if not HumanoidRootPart or not Character then return end
    
    speed = speed or 50
    
    local humanoid = Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Completely disable fall damage
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
    humanoid:ChangeState(Enum.HumanoidStateType.Flying)
    
    -- Calculate waypoints: up -> across -> stay elevated
    local currentPos = HumanoidRootPart.Position
    local flightHeight = 200
    
    -- Stay 10 studs above ground at destination (never touch ground)
    local waypoints = {
        Vector3.new(currentPos.X, currentPos.Y + flightHeight, currentPos.Z),
        Vector3.new(position.X, position.Y + flightHeight, position.Z),
        Vector3.new(position.X, position.Y + 10, position.Z), -- Stay 10 studs up
    }
    
    for i, waypoint in ipairs(waypoints) do
        if not HumanoidRootPart then break end
        
        local distance = (waypoint - HumanoidRootPart.Position).Magnitude
        local duration = distance / speed
        
        local tween = TweenService:Create(
            HumanoidRootPart,
            TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {CFrame = CFrame.new(waypoint)}
        )
        
        tween:Play()
        tween.Completed:Wait()
    end
    
    -- Create BodyVelocity to keep player floating (prevents fall)
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(0, math.huge, 0) -- Only prevent Y-axis falling
    bv.Parent = HumanoidRootPart
    
    -- Set final position elevated
    wait(0.5)
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(Vector3.new(position.X, position.Y + 10, position.Z))
    end
    
    -- Wait then remove BodyVelocity and re-enable states
    wait(1)
    if bv then bv:Destroy() end
    
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    end
end

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
    
    if not Character or not Character:FindFirstChild("Humanoid") then return end
    
    -- Set to flying state to prevent fall damage
    local humanoid = Character.Humanoid
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    
    -- Always escape north (positive Z direction) regardless of spawn
    -- This ensures consistent escape direction
    local escapePos = Vector3.new(HumanoidRootPart.Position.X, HumanoidRootPart.Position.Y, HumanoidRootPart.Position.Z + 600)
    
    -- Smoothly fly to escape position at 50 studs/s
    SmoothFlyTo(escapePos, 50)
    
    -- Extra wait to ensure we stay at escape position
    wait(0.5)
    
    -- Re-enable falling states
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    
    -- Force position one more time
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(escapePos)
    end
    
    Status.EscapesMade = Status.EscapesMade + 1
    UpdateStatus("Idle")
    Notify("✅ Escaped", "Freedom")
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
    
    -- Get criminal's current velocity to match speed
    local crimHRP = criminal.Character.HumanoidRootPart
    local crimVelocity = crimHRP.AssemblyLinearVelocity.Magnitude
    
    -- Match their speed, minimum 50, maximum 150
    local targetSpeed = math.clamp(crimVelocity + 20, 50, 150)
    
    -- Track criminal's position in case they move
    local lastKnownPos = crimHRP.Position
    local trackingLoop
    
    trackingLoop = task.spawn(function()
        while Settings.AutoArrest and criminal.Character and crimHRP do
            wait(0.1)
            lastKnownPos = crimHRP.Position
        end
    end)
    
    -- Smoothly fly to criminal at their speed + 20
    SmoothFlyTo(lastKnownPos, targetSpeed)
    
    -- Stop tracking
    task.cancel(trackingLoop)
    
    -- Get close and arrest
    if criminal.Character and crimHRP then
        -- Final approach - get right next to them
        local finalPos = crimHRP.Position
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = CFrame.new(finalPos)
        end
    end
    
    wait(0.3)
    
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool.Name:lower():match("cuff") or tool.Name:lower():match("arrest") then
            Character.Humanoid:EquipTool(tool)
            wait(0.1)
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

--[[ AIMBOT SYSTEM ]]--

local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local function CreateFOVCircle()
    if FOVCircle then
        FOVCircle:Remove()
    end
    
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 50
    FOVCircle.Radius = Settings.FOVSize
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Transparency = 1
    FOVCircle.Visible = Settings.ShowFOV
    FOVCircle.Filled = false
end

local function UpdateFOVCircle()
    if FOVCircle then
        -- Center of screen
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Position = screenCenter
        FOVCircle.Radius = Settings.FOVSize
        FOVCircle.Visible = Settings.ShowFOV
    end
end

local function IsVisible(target)
    if not Settings.WallCheck then return true end
    
    local origin = Camera.CFrame.Position
    local direction = (target.Position - origin).Unit * (target.Position - origin).Magnitude
    
    local ray = Ray.new(origin, direction)
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, target.Parent})
    
    return hit == nil or hit:IsDescendantOf(target.Parent)
end

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Settings.FOVSize
    
    -- Screen center
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Team check
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            
            local character = player.Character
            local head = character:FindFirstChild("Head")
            
            if head and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                    local distance = (screenCenter - targetPos).Magnitude
                    
                    if distance < shortestDistance then
                        if IsVisible(head) then
                            closestPlayer = player
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- FOV Circle update loop
task.spawn(function()
    CreateFOVCircle()
    RunService.RenderStepped:Connect(function()
        UpdateFOVCircle()
    end)
end)

-- Silent Aim - Works with Jailbreak shooting
local old_index
old_index = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if Settings.SilentAim and checkcaller() == false then
        if (key == "Hit" or key == "Target") and tostring(self) == "Mouse" then
            local target = GetClosestPlayer()
            if target and target.Character then
                local head = target.Character:FindFirstChild("Head")
                if head then
                    return CFrame.new(head.Position)
                end
            end
        end
    end
    return old_index(self, key)
end))

-- Also hook namecall for RemoteEvent shooting
local old_namecall
old_namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if Settings.SilentAim and method == "FireServer" then
        local target = GetClosestPlayer()
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head")
            if head then
                -- Try to modify hit position in args
                for i, arg in pairs(args) do
                    if typeof(arg) == "Vector3" then
                        args[i] = head.Position
                    elseif typeof(arg) == "CFrame" then
                        args[i] = CFrame.new(head.Position)
                    end
                end
            end
        end
    end
    
    return old_namecall(self, unpack(args))
end))

-- Triggerbot
task.spawn(function()
    while wait(0.05) do
        if Settings.Triggerbot then
            pcall(function()
                local target = GetClosestPlayer()
                if target then
                    -- Check if target is in FOV
                    local head = target.Character and target.Character:FindFirstChild("Head")
                    if head then
                        local screenPos = Camera:WorldToViewportPoint(head.Position)
                        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local distance = (screenCenter - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                        
                        if distance <= Settings.FOVSize then
                            -- Auto shoot
                            mouse1press()
                            wait(0.05)
                            mouse1release()
                        end
                    end
                end
            end)
        end
    end
end)

--[[ VEHICLE SPEED MODIFIER ]]--

task.spawn(function()
    while wait(0.3) do
        pcall(function()
            if Character then
                -- Method 1: Check if sitting in a vehicle seat
                local humanoid = Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.SeatPart then
                    local seat = humanoid.SeatPart
                    
                    -- Check if it's a VehicleSeat
                    if seat:IsA("VehicleSeat") then
                        seat.MaxSpeed = Settings.VehicleSpeed
                    end
                    
                    -- Check parent for vehicle configuration
                    local vehicle = seat.Parent
                    if vehicle then
                        -- Find all VehicleSeats in the vehicle
                        for _, part in pairs(vehicle:GetDescendants()) do
                            if part:IsA("VehicleSeat") then
                                part.MaxSpeed = Settings.VehicleSpeed
                            end
                        end
                        
                        -- Find BodyVelocity or other constraints
                        for _, part in pairs(vehicle:GetDescendants()) do
                            if part:IsA("BodyVelocity") then
                                part.MaxForce = Vector3.new(Settings.VehicleSpeed * 100, Settings.VehicleSpeed * 100, Settings.VehicleSpeed * 100)
                            end
                        end
                    end
                end
                
                -- Method 2: Check for any vehicle seats near the player
                for _, seat in pairs(workspace:GetDescendants()) do
                    if seat:IsA("VehicleSeat") and seat.Occupant == humanoid then
                        seat.MaxSpeed = Settings.VehicleSpeed
                    end
                end
            end
        end)
    end
end)

--[[ AUTO FUNCTIONS ]]--

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

--[[ ANIMATED INTRO ]]--

local function ShowIntro()
    -- Create intro screen
    local IntroGui = Instance.new("ScreenGui")
    IntroGui.Name = "KrackpipeIntro"
    IntroGui.Parent = game.CoreGui
    IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    IntroGui.ResetOnSpawn = false
    IntroGui.IgnoreGuiInset = true
    
    local IntroFrame = Instance.new("Frame")
    IntroFrame.Parent = IntroGui
    IntroFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    IntroFrame.BorderSizePixel = 0
    IntroFrame.Position = UDim2.new(0, 0, 0, 0)
    IntroFrame.Size = UDim2.new(1, 0, 1, 0)
    IntroFrame.BackgroundTransparency = 0
    IntroFrame.ZIndex = 10
    
    -- Pill icon
    local PillIcon = Instance.new("TextLabel")
    PillIcon.Parent = IntroFrame
    PillIcon.BackgroundTransparency = 1
    PillIcon.Position = UDim2.new(0.5, 0, 0.35, 0)
    PillIcon.Size = UDim2.new(0, 100, 0, 100)
    PillIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    PillIcon.Font = Enum.Font.GothamBold
    PillIcon.Text = "💊"
    PillIcon.TextSize = 72
    PillIcon.TextTransparency = 1
    PillIcon.ZIndex = 11
    
    -- Script Name
    local ScriptName = Instance.new("TextLabel")
    ScriptName.Parent = IntroFrame
    ScriptName.BackgroundTransparency = 1
    ScriptName.Position = UDim2.new(0.5, 0, 0.48, 0)
    ScriptName.Size = UDim2.new(0, 600, 0, 80)
    ScriptName.AnchorPoint = Vector2.new(0.5, 0.5)
    ScriptName.Font = Enum.Font.GothamBold
    ScriptName.Text = "KIMBO'S KRACKPIPE"
    ScriptName.TextColor3 = Color3.fromRGB(255, 200, 0)
    ScriptName.TextSize = 48
    ScriptName.TextTransparency = 1
    ScriptName.ZIndex = 11
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Parent = IntroFrame
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0.5, 0, 0.58, 0)
    Subtitle.Size = UDim2.new(0, 400, 0, 40)
    Subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "Welcome to Agartha"
    Subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    Subtitle.TextSize = 20
    Subtitle.TextTransparency = 1
    Subtitle.ZIndex = 11
    
    -- Author
    local Author = Instance.new("TextLabel")
    Author.Parent = IntroFrame
    Author.BackgroundTransparency = 1
    Author.Position = UDim2.new(0.5, 0, 0.65, 0)
    Author.Size = UDim2.new(0, 300, 0, 30)
    Author.AnchorPoint = Vector2.new(0.5, 0.5)
    Author.Font = Enum.Font.GothamBold
    Author.Text = "By Kimbo"
    Author.TextColor3 = Color3.fromRGB(255, 100, 100)
    Author.TextSize = 18
    Author.TextTransparency = 1
    Author.ZIndex = 11
    
    -- Animations
    task.spawn(function()
        wait(0.2)
        
        -- Fade in pill (0.6s)
        TweenService:Create(PillIcon, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        wait(0.8)
        
        -- Fade in script name (0.8s)
        TweenService:Create(ScriptName, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        wait(0.6)
        
        -- Fade in subtitle (0.6s)
        TweenService:Create(Subtitle, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        wait(0.5)
        
        -- Fade in author (0.5s)
        TweenService:Create(Author, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        wait(1.0)
        
        -- Fade out everything (0.7s)
        TweenService:Create(PillIcon, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(ScriptName, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(Subtitle, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(Author, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(IntroFrame, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        wait(0.8)
        
        -- Destroy intro
        IntroGui:Destroy()
    end)
end

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
    
    -- RGB Animation values
    local hue = 0
    
    local function GetRGBColor()
        hue = hue + 0.003
        if hue > 1 then hue = 0 end
        return Color3.fromHSV(hue, 0.8, 1)
    end
    
    -- Mobile-friendly size (360x640 fits most phones)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -320, 0.5, -180)
    MainFrame.Size = UDim2.new(0, 640, 0, 360)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Thickness = 2
    MainStroke.Parent = MainFrame
    
    -- RGB animation for border
    task.spawn(function()
        while MainFrame and MainFrame.Parent do
            MainStroke.Color = GetRGBColor()
            wait()
        end
    end)
    
    local MinimizeIcon = Instance.new("TextButton")
    MinimizeIcon.Name = "MinimizeIcon"
    MinimizeIcon.Parent = ScreenGui
    MinimizeIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MinimizeIcon.Position = UDim2.new(0, 10, 0.5, -30)
    MinimizeIcon.Size = UDim2.new(0, 60, 0, 60)
    MinimizeIcon.Font = Enum.Font.GothamBold
    MinimizeIcon.Text = "💊"
    MinimizeIcon.TextSize = 28
    MinimizeIcon.Visible = false
    MinimizeIcon.Active = true
    MinimizeIcon.Draggable = true
    
    local MinIconCorner = Instance.new("UICorner")
    MinIconCorner.CornerRadius = UDim.new(0, 12)
    MinIconCorner.Parent = MinimizeIcon
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    local TitleStroke = Instance.new("UIStroke")
    TitleStroke.Color = Color3.fromRGB(255, 255, 255)
    TitleStroke.Thickness = 2
    TitleStroke.Parent = TitleBar
    
    -- RGB animation for title bar
    task.spawn(function()
        while TitleBar and TitleBar.Parent do
            TitleStroke.Color = GetRGBColor()
            wait()
        end
    end)
    
    local Title = Instance.new("TextLabel")
    Title.Parent = TitleBar
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "💊 KRACKPIPE"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Position = UDim2.new(0, 15, 0, 0)
    
    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = TitleBar
    MinBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
    MinBtn.Position = UDim2.new(1, -70, 0, 10)
    MinBtn.Size = UDim2.new(0, 28, 0, 28)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Text = "_"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.TextSize = 14
    
    local MinBtnCorner = Instance.new("UICorner")
    MinBtnCorner.CornerRadius = UDim.new(0, 6)
    MinBtnCorner.Parent = MinBtn
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = TitleBar
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Position = UDim2.new(1, -35, 0, 10)
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 14
    
    local CloseBtnCorner = Instance.new("UICorner")
    CloseBtnCorner.CornerRadius = UDim.new(0, 6)
    CloseBtnCorner.Parent = CloseBtn
    
    local TabContainer = Instance.new("Frame")
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 0, 0, 50)
    TabContainer.Size = UDim2.new(1, 0, 0, 40)
    
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 0, 0, 90)
    ContentContainer.Size = UDim2.new(1, 0, 1, -90)
    
    local function CreateButton(parent, text, position, size, color, callback)
        local button = Instance.new("TextButton")
        button.Parent = parent
        button.BackgroundColor3 = color
        button.Position = position
        button.Size = size
        button.Font = Enum.Font.GothamBold
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 12
        button.AutoButtonColor = false
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = button
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 1.5
        stroke.Parent = button
        
        -- RGB animation for button border
        task.spawn(function()
            while button and button.Parent do
                stroke.Color = GetRGBColor()
                wait()
            end
        end)
        
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
        
        -- No colors - just gray
        local buttonColor = Color3.fromRGB(60, 60, 70)
        
        local button = CreateButton(
            parent, 
            text .. ": " .. (isOn and "ON" or "OFF"), 
            position, 
            UDim2.new(0, 330, 0, 32), 
            buttonColor,
            nil
        )
        
        button.TextSize = 11
        
        button.MouseButton1Click:Connect(function()
            Settings[settingKey] = not Settings[settingKey]
            local newState = Settings[settingKey]
            button.Text = text .. ": " .. (newState and "ON" or "OFF")
            
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
    StatusFrame.Position = UDim2.new(0, 20, 0, 15)
    StatusFrame.Size = UDim2.new(0, 360, 0, 160)
    
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
                    "  Arrests: %d\n" ..
                    "  Escapes: %d\n\n" ..
                    "Features:\n" ..
                    "  Silent Aim: %s\n" ..
                    "  Auto Arrest: %s\n" ..
                    "  Auto Escape: %s",
                    Status.CurrentAction,
                    Status.ArrestsMade,
                    Status.EscapesMade,
                    Settings.SilentAim and "✓ ON" or "✗ OFF",
                    Settings.AutoArrest and "✓ ON" or "✗ OFF",
                    Settings.AutoEscape and "✓ ON" or "✗ OFF"
                )
                StatusLabel.Text = text
            else
                break
            end
        end
    end)
    
    CreateButton(HomePage, "💀 Respawn", UDim2.new(0, 20, 0, 190), UDim2.new(0, 170, 0, 35), Color3.fromRGB(192, 57, 43), function()
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.Health = 0
        end
        Notify("💀 Respawning", "Resetting")
    end)
    
    CreateButton(HomePage, "🚨 Escape", UDim2.new(0, 210, 0, 190), UDim2.new(0, 170, 0, 35), Color3.fromRGB(230, 126, 34), function()
        Escape()
    end)
    
    -- AIMBOT PAGE
    local AimbotPage = Instance.new("Frame")
    AimbotPage.Parent = ContentContainer
    AimbotPage.BackgroundTransparency = 1
    AimbotPage.Size = UDim2.new(1, 0, 1, 0)
    AimbotPage.Visible = false
    pages["Aimbot"] = AimbotPage
    
    local aimbotLabel = Instance.new("TextLabel")
    aimbotLabel.Parent = AimbotPage
    aimbotLabel.BackgroundTransparency = 1
    aimbotLabel.Position = UDim2.new(0, 20, 0, 10)
    aimbotLabel.Size = UDim2.new(1, -40, 0, 20)
    aimbotLabel.Font = Enum.Font.GothamBold
    aimbotLabel.Text = "━━━━ AIMBOT ━━━━"
    aimbotLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    aimbotLabel.TextSize = 13
    
    CreateToggle(AimbotPage, "Silent Aim", UDim2.new(0, 20, 0, 35), "SilentAim")
    CreateToggle(AimbotPage, "Triggerbot", UDim2.new(0, 20, 0, 80), "Triggerbot")
    CreateToggle(AimbotPage, "Show FOV", UDim2.new(0, 20, 0, 125), "ShowFOV")
    CreateToggle(AimbotPage, "Wall Check", UDim2.new(0, 20, 0, 170), "WallCheck")
    CreateToggle(AimbotPage, "Team Check", UDim2.new(0, 20, 0, 215), "TeamCheck")
    
    -- CRIMINALS PAGE
    local CriminalsPage = Instance.new("Frame")
    CriminalsPage.Parent = ContentContainer
    CriminalsPage.BackgroundTransparency = 1
    CriminalsPage.Size = UDim2.new(1, 0, 1, 0)
    CriminalsPage.Visible = false
    pages["Criminals"] = CriminalsPage
    
    CreateToggle(CriminalsPage, "Auto Escape", UDim2.new(0, 20, 0, 15), "AutoEscape")
    
    -- POLICE PAGE
    local PolicePage = Instance.new("Frame")
    PolicePage.Parent = ContentContainer
    PolicePage.BackgroundTransparency = 1
    PolicePage.Size = UDim2.new(1, 0, 1, 0)
    PolicePage.Visible = false
    pages["Police"] = PolicePage
    
    CreateToggle(PolicePage, "Auto Arrest", UDim2.new(0, 20, 0, 15), "AutoArrest")
    
    -- ESP PAGE (Criminal + Police ESP)
    local ESPPage = Instance.new("Frame")
    ESPPage.Parent = ContentContainer
    ESPPage.BackgroundTransparency = 1
    ESPPage.Size = UDim2.new(1, 0, 1, 0)
    ESPPage.Visible = false
    pages["ESP"] = ESPPage
    
    local crimEspLabel = Instance.new("TextLabel")
    crimEspLabel.Parent = ESPPage
    crimEspLabel.BackgroundTransparency = 1
    crimEspLabel.Position = UDim2.new(0, 10, 0, 5)
    crimEspLabel.Size = UDim2.new(0.5, -15, 0, 20)
    crimEspLabel.Font = Enum.Font.GothamBold
    crimEspLabel.Text = "CRIMINAL ESP"
    crimEspLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    crimEspLabel.TextSize = 12
    
    -- Criminal ESP toggles (left side, smaller)
    local function CreateSmallToggle(parent, text, position, settingKey)
        local isOn = Settings[settingKey]
        local buttonColor = Color3.fromRGB(60, 60, 70)
        
        local button = CreateButton(
            parent, 
            text .. ": " .. (isOn and "ON" or "OFF"), 
            position, 
            UDim2.new(0.5, -15, 0, 30), 
            buttonColor,
            nil
        )
        
        button.TextSize = 11
        
        button.MouseButton1Click:Connect(function()
            Settings[settingKey] = not Settings[settingKey]
            local newState = Settings[settingKey]
            button.Text = text .. ": " .. (newState and "ON" or "OFF")
            print("[KRACKPIPE] " .. text .. " = " .. tostring(newState))
        end)
        
        return button
    end
    
    CreateSmallToggle(ESPPage, "Enable", UDim2.new(0, 10, 0, 30), "CriminalESP").MouseButton1Click:Connect(function()
        wait(0.1)
        UpdateESP()
    end)
    
    CreateSmallToggle(ESPPage, "Names", UDim2.new(0, 10, 0, 65), "CriminalNames")
    CreateSmallToggle(ESPPage, "Boxes", UDim2.new(0, 10, 0, 100), "CriminalBoxes")
    CreateSmallToggle(ESPPage, "Distance", UDim2.new(0, 10, 0, 135), "CriminalDistance")
    CreateSmallToggle(ESPPage, "Health", UDim2.new(0, 10, 0, 170), "CriminalHealth")
    
    -- Police ESP (right side)
    local policeEspLabel = Instance.new("TextLabel")
    policeEspLabel.Parent = ESPPage
    policeEspLabel.BackgroundTransparency = 1
    policeEspLabel.Position = UDim2.new(0.5, 5, 0, 5)
    policeEspLabel.Size = UDim2.new(0.5, -15, 0, 20)
    policeEspLabel.Font = Enum.Font.GothamBold
    policeEspLabel.Text = "POLICE ESP"
    policeEspLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
    policeEspLabel.TextSize = 12
    
    CreateSmallToggle(ESPPage, "Enable", UDim2.new(0.5, 5, 0, 30), "PoliceESP").MouseButton1Click:Connect(function()
        wait(0.1)
        UpdateESP()
    end)
    
    CreateSmallToggle(ESPPage, "Names", UDim2.new(0.5, 5, 0, 65), "PoliceNames")
    CreateSmallToggle(ESPPage, "Boxes", UDim2.new(0.5, 5, 0, 100), "PoliceBoxes")
    CreateSmallToggle(ESPPage, "Distance", UDim2.new(0.5, 5, 0, 135), "PoliceDistance")
    CreateSmallToggle(ESPPage, "Health", UDim2.new(0.5, 5, 0, 170), "PoliceHealth")
    
    -- SETTINGS PAGE
    local SettingsPage = Instance.new("Frame")
    SettingsPage.Parent = ContentContainer
    SettingsPage.BackgroundTransparency = 1
    SettingsPage.Size = UDim2.new(1, 0, 1, 0)
    SettingsPage.Visible = false
    pages["Settings"] = SettingsPage
    
    CreateToggle(SettingsPage, "Anti-AFK", UDim2.new(0, 20, 0, 15), "AntiAFK")
    
    -- Vehicle Speed
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Parent = SettingsPage
    speedLabel.BackgroundTransparency = 1
    speedLabel.Position = UDim2.new(0, 20, 0, 65)
    speedLabel.Size = UDim2.new(0, 360, 0, 20)
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.Text = "Vehicle Speed: " .. Settings.VehicleSpeed
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedLabel.TextSize = 13
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local speedSlider = Instance.new("TextBox")
    speedSlider.Parent = SettingsPage
    speedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    speedSlider.Position = UDim2.new(0, 20, 0, 90)
    speedSlider.Size = UDim2.new(0, 360, 0, 35)
    speedSlider.Font = Enum.Font.Gotham
    speedSlider.PlaceholderText = "Enter speed (50-500)"
    speedSlider.Text = tostring(Settings.VehicleSpeed)
    speedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedSlider.TextSize = 14
    speedSlider.ClearTextOnFocus = false
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 8)
    sliderCorner.Parent = speedSlider
    
    speedSlider.FocusLost:Connect(function()
        local value = tonumber(speedSlider.Text)
        if value and value >= 50 and value <= 500 then
            Settings.VehicleSpeed = value
            speedLabel.Text = "Vehicle Speed: " .. value
            Notify("🚗 Speed Set", value .. " studs/s")
        else
            speedSlider.Text = tostring(Settings.VehicleSpeed)
            Notify("❌ Invalid", "Use 50-500")
        end
    end)
    
    CreateButton(SettingsPage, "💾 Save Config", UDim2.new(0, 20, 0, 140), UDim2.new(0, 170, 0, 35), Color3.fromRGB(39, 174, 96), function()
        SaveConfig()
    end)
    
    CreateButton(SettingsPage, "📁 Load Config", UDim2.new(0, 210, 0, 140), UDim2.new(0, 170, 0, 35), Color3.fromRGB(52, 152, 219), function()
        LoadConfig()
    end)
    
    -- Create tabs
    local tabs = {"Home", "Aimbot", "Criminals", "ESP", "Police", "Settings"}
    local currentTab = "Home"
    
    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Parent = TabContainer
        tabButton.BackgroundColor3 = tabName == currentTab and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(50, 50, 60)
        tabButton.Position = UDim2.new((i-1) * 0.166, 0, 0, 5)
        tabButton.Size = UDim2.new(0.16, 0, 0, 35)
        tabButton.Font = Enum.Font.GothamBold
        tabButton.Text = tabName
        tabButton.TextColor3 = tabName == currentTab and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        tabButton.TextSize = 11
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
                        child.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                        child.TextColor3 = Color3.fromRGB(255, 255, 255)
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

print("[KRACKPIPE] Loading Kimbo's Krackpipe v4.2.0...")

ShowIntro()

wait(4) -- Wait for intro to finish

CreateGUI()

Notify("✅ Ready", "Krackpipe active")
print("[KRACKPIPE] ✅ Loaded successfully")
print("[KRACKPIPE] Welcome to Agartha - By Kimbo")
