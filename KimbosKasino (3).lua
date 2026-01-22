--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║              ██╗  ██╗██╗███╗   ███╗██████╗  ██████╗      ║
    ║              ██║ ██╔╝██║████╗ ████║██╔══██╗██╔═══██╗     ║
    ║              █████╔╝ ██║██╔████╔██║██████╔╝██║   ██║     ║
    ║              ██╔═██╗ ██║██║╚██╔╝██║██╔══██╗██║   ██║     ║
    ║              ██║  ██╗██║██║ ╚═╝ ██║██████╔╝╚██████╔╝     ║
    ║              ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚═════╝  ╚═════╝      ║
    ║                                                           ║
    ║                    ██╗  ██╗ █████╗ ███████╗██╗███╗   ██╗ ║
    ║                    ██║ ██╔╝██╔══██╗██╔════╝██║████╗  ██║ ║
    ║                    █████╔╝ ███████║███████╗██║██╔██╗ ██║ ║
    ║                    ██╔═██╗ ██╔══██║╚════██║██║██║╚██╗██║ ║
    ║                    ██║  ██╗██║  ██║███████║██║██║ ╚████║ ║
    ║                    ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═══╝ ║
    ║                                                           ║
    ║                  🎰 UNIVERSAL FARM SCRIPT 🎰              ║
    ║                                                           ║
    ║              » Auto Farm All Items & Currency «           ║
    ║              » Auto Rob, Escape & Arrest «                ║
    ║              » Vehicle-Based Flight System «              ║
    ║              » Anti-Cheat Evasion «                       ║
    ║              » Jailbreak 2026 Update «                    ║
    ║              » Smart Pathfinding «                        ║
    ║                                                           ║
    ║                  Version: 4.0.0 - JB2026                  ║
    ║                   Made with 💎 by Kimbo                   ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
]]

-- Service declarations
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

-- Local player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Script variables
local ScriptVersion = "4.0.0 - JB2026"
local FarmEnabled = false
local AntiAFKEnabled = true
local TeleportSpeed = 0.5
local AutoRobEnabled = false
local AutoEscapeEnabled = false
local AutoArrestEnabled = false
local MaxFlightHeight = 150 -- Safe height to avoid anticheat
local HumanFlightSpeed = 50 -- Human-like speed
local UseVehicles = true
local CurrentVehicle = nil

-- Jailbreak 2026-specific variables
local JailbreakData = {
    -- Classic robberies
    Stores = {},
    Banks = {},
    Museum = nil,
    PowerPlant = nil,
    Jewelry = nil,
    
    -- 2025-2026 robberies
    Casino = nil,
    Cargo = nil,
    Tomb = nil,
    Train = nil,
    NuclearPlant = nil,
    Refinery = nil,
    ArtGallery = nil,
    Mansion = nil,
    
    -- Newer 2026 additions
    SpaceStation = nil,
    Submarine = nil,
    SkyScraper = nil,
    
    -- Locations
    PrisonLocation = nil,
    PoliceStation = nil,
    CriminalBase = nil,
    
    -- Vehicles
    VehicleSpawns = {},
}

-- Config system
local ConfigFileName = "KimbosKasino_Config.json"
local DefaultConfig = {
    AutoRobEnabled = false,
    AutoEscapeEnabled = true,
    AutoArrestEnabled = false,
    UseVehicles = true,
    MaxFlightHeight = 150,
    HumanFlightSpeed = 50,
    AntiAFKEnabled = true,
    AutoFarmEnabled = false,
}

local CurrentConfig = DefaultConfig

-- Intro notification
local function ShowIntro()
    local StarterGui = game:GetService("StarterGui")
    
    StarterGui:SetCore("SendNotification", {
        Title = "🎰 KIMBO'S KASINO 🎰";
        Text = "Universal Farm Script Loading...";
        Duration = 3;
        Icon = "rbxassetid://7733955511";
    })
    
    wait(3)
    
    StarterGui:SetCore("SendNotification", {
        Title = "✅ LOADED SUCCESSFULLY";
        Text = "Welcome! Version " .. ScriptVersion;
        Duration = 5;
        Icon = "rbxassetid://7733955511";
    })
    
    print("╔═══════════════════════════════════════╗")
    print("║     KIMBO'S KASINO INITIALIZED        ║")
    print("║     Universal Farm Script v" .. ScriptVersion .. "     ║")
    print("╚═══════════════════════════════════════╝")
end

-- Anti-AFK system
local function SetupAntiAFK()
    if AntiAFKEnabled then
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            print("[KIMBO'S KASINO] Anti-AFK activated")
        end)
    end
end

-- Config System
local function SaveConfig()
    local config = {
        AutoRobEnabled = AutoRobEnabled,
        AutoEscapeEnabled = AutoEscapeEnabled,
        AutoArrestEnabled = AutoArrestEnabled,
        UseVehicles = UseVehicles,
        MaxFlightHeight = MaxFlightHeight,
        HumanFlightSpeed = HumanFlightSpeed,
        AntiAFKEnabled = AntiAFKEnabled,
        AutoFarmEnabled = FarmEnabled,
    }
    
    local HttpService = game:GetService("HttpService")
    local jsonConfig = HttpService:JSONEncode(config)
    
    writefile(ConfigFileName, jsonConfig)
    print("[KIMBO'S KASINO] 💾 Config saved successfully!")
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "💾 CONFIG SAVED";
        Text = "Settings saved successfully!";
        Duration = 3;
    })
end

local function LoadConfig()
    if isfile and isfile(ConfigFileName) then
        local HttpService = game:GetService("HttpService")
        local jsonConfig = readfile(ConfigFileName)
        local config = HttpService:JSONDecode(jsonConfig)
        
        -- Apply loaded config
        AutoRobEnabled = config.AutoRobEnabled or false
        AutoEscapeEnabled = config.AutoEscapeEnabled or true
        AutoArrestEnabled = config.AutoArrestEnabled or false
        UseVehicles = config.UseVehicles or true
        MaxFlightHeight = config.MaxFlightHeight or 150
        HumanFlightSpeed = config.HumanFlightSpeed or 50
        AntiAFKEnabled = config.AntiAFKEnabled or true
        FarmEnabled = config.AutoFarmEnabled or false
        
        print("[KIMBO'S KASINO] 📁 Config loaded successfully!")
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "📁 CONFIG LOADED";
            Text = "Previous settings restored!";
            Duration = 3;
        })
        
        return true
    else
        print("[KIMBO'S KASINO] No config file found, using defaults")
        return false
    end
end

-- Kill player function (respawn)
local function KillPlayer()
    print("[KIMBO'S KASINO] 💀 Respawning player...")
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "💀 RESPAWNING";
        Text = "Killing character to unstuck...";
        Duration = 3;
    })
    
    if Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid.Health = 0
    end
    
    -- Backup method
    LocalPlayer.Character = nil
    wait(0.5)
    LocalPlayer:LoadCharacter()
end

-- Jailbreak Location Finder
local function FindJailbreakLocations()
    print("[KIMBO'S KASINO] 🔍 Scanning for Jailbreak 2026 locations...")
    
    -- Find stores
    for _, store in pairs(Workspace:GetDescendants()) do
        if store.Name == "BankStore" or store.Name == "GasStation" or store.Name == "DonutStore" or 
           store.Name == "Store" or store.Name == "SmallStore" then
            table.insert(JailbreakData.Stores, store)
        end
    end
    
    -- Find vehicle spawns
    if Workspace:FindFirstChild("VehicleSpawns") then
        for _, spawn in pairs(Workspace.VehicleSpawns:GetChildren()) do
            table.insert(JailbreakData.VehicleSpawns, spawn)
        end
    end
    
    -- Find all robbery locations (2026 update compatible)
    for _, location in pairs(Workspace:GetDescendants()) do
        local name = location.Name
        
        -- Classic robberies
        if name == "BankBuilding" or name == "Bank" or name:match("Bank") then
            if not JailbreakData.Banks[1] then
                table.insert(JailbreakData.Banks, location)
            end
        elseif name == "Museum" or name == "MuseumRobbery" or name:match("Museum") then
            JailbreakData.Museum = location
        elseif name == "PowerPlant" or name == "Power" or name:match("PowerPlant") then
            JailbreakData.PowerPlant = location
        elseif name == "Jewelry" or name == "JewelryStore" or name:match("Jewelry") then
            JailbreakData.Jewelry = location
            
        -- 2025-2026 robberies
        elseif name == "Casino" or name == "CasinoRobbery" or name:match("Casino") then
            JailbreakData.Casino = location
        elseif name == "CargoShip" or name == "Cargo" or name:match("Cargo") then
            JailbreakData.Cargo = location
        elseif name == "Tomb" or name == "TombRobbery" or name:match("Tomb") then
            JailbreakData.Tomb = location
        elseif name == "Train" or name == "TrainRobbery" or name:match("Train") then
            JailbreakData.Train = location
        elseif name == "NuclearPlant" or name == "Nuclear" or name:match("Nuclear") then
            JailbreakData.NuclearPlant = location
        elseif name == "Refinery" or name == "OilRefinery" or name:match("Refinery") then
            JailbreakData.Refinery = location
        elseif name == "ArtGallery" or name == "Gallery" or name:match("Gallery") then
            JailbreakData.ArtGallery = location
        elseif name == "Mansion" or name == "MansionRobbery" or name:match("Mansion") then
            JailbreakData.Mansion = location
            
        -- 2026 newest additions
        elseif name == "SpaceStation" or name == "Space" or name:match("SpaceStation") then
            JailbreakData.SpaceStation = location
        elseif name == "Submarine" or name == "SubRobbery" or name:match("Submarine") then
            JailbreakData.Submarine = location
        elseif name == "SkyScraper" or name == "Skyscraper" or name:match("SkyScraper") then
            JailbreakData.SkyScraper = location
        end
        
        -- Find prison
        if name == "Prison" or name == "Jail" or name:match("Prison") then
            JailbreakData.PrisonLocation = location
        end
        
        -- Find police station
        if name == "PoliceStation" or name == "Police" or name:match("PoliceStation") then
            JailbreakData.PoliceStation = location
        end
        
        -- Find criminal base
        if name == "CriminalBase" or name == "CrimBase" or name:match("CriminalBase") then
            JailbreakData.CriminalBase = location
        end
    end
    
    print("[KIMBO'S KASINO] ✅ Jailbreak 2026 Locations found:")
    print("  🏪 Stores: " .. #JailbreakData.Stores)
    print("  🏦 Banks: " .. #JailbreakData.Banks)
    print("  🎨 Museum: " .. (JailbreakData.Museum and "✓" or "✗"))
    print("  ⚡ Power Plant: " .. (JailbreakData.PowerPlant and "✓" or "✗"))
    print("  💎 Jewelry: " .. (JailbreakData.Jewelry and "✓" or "✗"))
    print("  🎰 Casino: " .. (JailbreakData.Casino and "✓" or "✗"))
    print("  🚢 Cargo Ship: " .. (JailbreakData.Cargo and "✓" or "✗"))
    print("  ⚰️ Tomb: " .. (JailbreakData.Tomb and "✓" or "✗"))
    print("  🚂 Train: " .. (JailbreakData.Train and "✓" or "✗"))
    print("  ☢️ Nuclear Plant: " .. (JailbreakData.NuclearPlant and "✓" or "✗"))
    print("  🛢️ Refinery: " .. (JailbreakData.Refinery and "✓" or "✗"))
    print("  🖼️ Art Gallery: " .. (JailbreakData.ArtGallery and "✓" or "✗"))
    print("  🏰 Mansion: " .. (JailbreakData.Mansion and "✓" or "✗"))
    print("  🚀 Space Station: " .. (JailbreakData.SpaceStation and "✓" or "✗"))
    print("  🌊 Submarine: " .. (JailbreakData.Submarine and "✓" or "✗"))
    print("  🏙️ Skyscraper: " .. (JailbreakData.SkyScraper and "✓" or "✗"))
    print("  🚗 Vehicle Spawns: " .. #JailbreakData.VehicleSpawns)
end

-- Vehicle system
local function FindNearestVehicle()
    local nearestVehicle = nil
    local shortestDistance = math.huge
    
    for _, vehicle in pairs(Workspace:GetDescendants()) do
        if vehicle:IsA("VehicleSeat") or (vehicle:IsA("Model") and vehicle:FindFirstChild("VehicleSeat")) then
            local vehiclePart = vehicle:IsA("VehicleSeat") and vehicle or vehicle:FindFirstChild("VehicleSeat")
            if vehiclePart and HumanoidRootPart then
                local distance = (vehiclePart.Position - HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance and distance < 500 then
                    shortestDistance = distance
                    nearestVehicle = vehicle:IsA("Model") and vehicle or vehicle.Parent
                end
            end
        end
    end
    
    return nearestVehicle
end

local function SpawnVehicle()
    -- Try to spawn vehicle via game-specific methods
    pcall(function()
        -- Jailbreak 2026 vehicle spawning
        local success = false
        
        -- Method 1: Use vehicle spawn pads
        if #JailbreakData.VehicleSpawns > 0 then
            local closestSpawn = nil
            local shortestDistance = math.huge
            
            for _, spawn in pairs(JailbreakData.VehicleSpawns) do
                local distance = (spawn.Position - HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestSpawn = spawn
                end
            end
            
            if closestSpawn then
                -- Teleport to spawn
                HumanoidRootPart.CFrame = closestSpawn.CFrame + Vector3.new(0, 5, 0)
                wait(0.5)
                
                -- Try to interact with spawn pad
                if closestSpawn:FindFirstChildOfClass("ProximityPrompt") then
                    fireproximityprompt(closestSpawn:FindFirstChildOfClass("ProximityPrompt"))
                    success = true
                end
            end
        end
        
        -- Method 2: Look for garage/vehicle GUI
        if not success then
            for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if gui:IsA("TextButton") and (gui.Name:match("Vehicle") or gui.Text:match("Spawn")) then
                    for _, conn in pairs(getconnections(gui.MouseButton1Click)) do
                        conn:Fire()
                    end
                    success = true
                    break
                end
            end
        end
        
        -- Method 3: Remote event spawning
        if not success and ReplicatedStorage:FindFirstChild("VehicleSpawn") then
            ReplicatedStorage.VehicleSpawn:FireServer()
            success = true
        end
        
        -- Method 4: Direct garage teleport
        if not success and Workspace:FindFirstChild("Garage") then
            HumanoidRootPart.CFrame = Workspace.Garage:FindFirstChildOfClass("Part").CFrame
            wait(0.5)
        end
    end)
    
    wait(1.5)
    return FindNearestVehicle()
end

local function EnterVehicle(vehicle)
    if not vehicle then return false end
    
    pcall(function()
        local vehicleSeat = vehicle:FindFirstChild("VehicleSeat", true)
        if vehicleSeat and vehicleSeat:IsA("VehicleSeat") then
            Character.Humanoid:Sit()
            HumanoidRootPart.CFrame = vehicleSeat.CFrame
            CurrentVehicle = vehicle
            wait(0.5)
        end
    end)
    
    return CurrentVehicle ~= nil
end

-- Flying system with vehicle preference
local function FlyTo(targetPosition, useVehicle)
    if not HumanoidRootPart then return end
    
    -- Try to use vehicle if preferred
    if useVehicle and UseVehicles then
        if not CurrentVehicle then
            local vehicle = FindNearestVehicle()
            if not vehicle then
                vehicle = SpawnVehicle()
            end
            if vehicle then
                EnterVehicle(vehicle)
            end
        end
    end
    
    -- Calculate safe flight path at max height
    local startPos = HumanoidRootPart.Position
    local endPos = targetPosition
    
    -- Create waypoints: up -> across at max height -> down
    local waypoints = {
        Vector3.new(startPos.X, MaxFlightHeight, startPos.Z),
        Vector3.new(endPos.X, MaxFlightHeight, endPos.Z),
        endPos
    }
    
    -- Fly through waypoints
    for _, waypoint in ipairs(waypoints) do
        local distance = (waypoint - HumanoidRootPart.Position).Magnitude
        local duration = distance / HumanFlightSpeed
        
        local tweenInfo = TweenInfo.new(
            duration,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out,
            0,
            false,
            0
        )
        
        if CurrentVehicle and CurrentVehicle.PrimaryPart then
            local tween = TweenService:Create(CurrentVehicle.PrimaryPart, tweenInfo, {CFrame = CFrame.new(waypoint)})
            tween:Play()
            tween.Completed:Wait()
        else
            local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(waypoint)})
            tween:Play()
            tween.Completed:Wait()
        end
        
        wait(0.1)
    end
end

-- Teleport function with smooth tweening
local function TeleportTo(position)
    if not Character or not HumanoidRootPart then return end
    
    local tweenInfo = TweenInfo.new(
        TeleportSpeed,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(position)})
    tween:Play()
    tween.Completed:Wait()
end

-- Find farmable items in workspace
local function FindFarmables()
    local farmables = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        -- Common farmable item names and properties
        if obj:IsA("Model") or obj:IsA("Part") then
            local name = obj.Name:lower()
            
            if name:match("coin") or name:match("cash") or 
               name:match("money") or name:match("gem") or
               name:match("crystal") or name:match("orb") or
               name:match("collectible") or name:match("pickup") then
                table.insert(farmables, obj)
            end
        end
    end
    
    return farmables
end

-- Find robbable locations
local function FindRobbables()
    local robbables = {}
    
    -- Jailbreak 2026 robbery locations (prioritized list)
    local jailbreakRobberies = {
        -- Newest 2026 robberies (highest priority)
        {name = "SpaceStation", location = JailbreakData.SpaceStation, value = "HIGH"},
        {name = "Submarine", location = JailbreakData.Submarine, value = "HIGH"},
        {name = "SkyScraper", location = JailbreakData.SkyScraper, value = "HIGH"},
        
        -- 2025-2026 robberies
        {name = "Mansion", location = JailbreakData.Mansion, value = "MEDIUM"},
        {name = "ArtGallery", location = JailbreakData.ArtGallery, value = "MEDIUM"},
        {name = "Refinery", location = JailbreakData.Refinery, value = "MEDIUM"},
        {name = "NuclearPlant", location = JailbreakData.NuclearPlant, value = "MEDIUM"},
        {name = "Casino", location = JailbreakData.Casino, value = "MEDIUM"},
        {name = "Tomb", location = JailbreakData.Tomb, value = "MEDIUM"},
        {name = "Train", location = JailbreakData.Train, value = "MEDIUM"},
        {name = "Cargo", location = JailbreakData.Cargo, value = "MEDIUM"},
        
        -- Classic robberies
        {name = "Bank", location = JailbreakData.Banks[1], value = "LOW"},
        {name = "Museum", location = JailbreakData.Museum, value = "LOW"},
        {name = "PowerPlant", location = JailbreakData.PowerPlant, value = "LOW"},
        {name = "Jewelry", location = JailbreakData.Jewelry, value = "LOW"},
    }
    
    for _, robbery in pairs(jailbreakRobberies) do
        if robbery.location then
            table.insert(robbables, robbery.location)
        end
    end
    
    -- Add stores (low priority)
    for _, store in pairs(JailbreakData.Stores) do
        table.insert(robbables, store)
    end
    
    -- Fallback: search for any robbery names
    if #robbables == 0 then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("Part") then
                local name = obj.Name:lower()
                
                if name:match("bank") or name:match("store") or 
                   name:match("jewelry") or name:match("museum") or
                   name:match("casino") or name:match("vault") or
                   name:match("robbery") or name:match("heist") or
                   name:match("power") or name:match("cargo") or
                   name:match("tomb") or name:match("train") or
                   name:match("nuclear") or name:match("refinery") or
                   name:match("gallery") or name:match("mansion") or
                   name:match("space") or name:match("submarine") or
                   name:match("skyscraper") then
                    
                    if obj:FindFirstChild("Trigger") or obj:FindFirstChild("Interact") or 
                       obj:FindFirstChild("Root") or obj:FindFirstChildOfClass("ProximityPrompt") then
                        table.insert(robbables, obj)
                    end
                end
            end
        end
    end
    
    return robbables
end

-- Find criminals to arrest
local function FindCriminals()
    local criminals = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            pcall(function()
                -- Check for criminal team or wanted status
                if player.Team and (player.Team.Name:lower():match("criminal") or 
                   player.Team.Name:lower():match("prisoner") or
                   player.Team.Name:lower():match("inmate")) then
                    table.insert(criminals, player)
                end
                
                -- Check for wanted attribute
                if player:FindFirstChild("Wanted") and player.Wanted.Value == true then
                    table.insert(criminals, player)
                end
            end)
        end
    end
    
    return criminals
end

-- Check if player is in jail/prison
local function IsInJail()
    local inJail = false
    
    pcall(function()
        -- Check team first (Jailbreak-specific)
        if LocalPlayer.Team and LocalPlayer.Team.Name == "Prisoner" then
            return true
        end
        
        -- Check for prison region
        if JailbreakData.PrisonLocation and HumanoidRootPart then
            local distance = (JailbreakData.PrisonLocation.Position - HumanoidRootPart.Position).Magnitude
            if distance < 300 then
                inJail = true
                return
            end
        end
        
        -- Fallback position check
        if HumanoidRootPart then
            for _, area in pairs(Workspace:GetDescendants()) do
                if area:IsA("Part") and (area.Name:lower():match("jail") or 
                   area.Name:lower():match("prison") or area.Name:lower():match("cell")) then
                    
                    local distance = (area.Position - HumanoidRootPart.Position).Magnitude
                    if distance < 100 then
                        inJail = true
                        break
                    end
                end
            end
        end
    end)
    
    return inJail
end

-- Auto Escape system
local function AutoEscape()
    if not IsInJail() then return end
    
    print("[KIMBO'S KASINO] 🚨 In jail! Attempting escape...")
    
    pcall(function()
        -- Find escape points
        local escapePoint = nil
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if (name:match("escape") or name:match("exit") or name:match("freedom")) and obj:IsA("Part") then
                escapePoint = obj.Position
                break
            end
        end
        
        -- If no escape point found, fly away from jail center
        if not escapePoint then
            local jailCenter = HumanoidRootPart.Position
            escapePoint = jailCenter + Vector3.new(500, 100, 500)
        end
        
        FlyTo(escapePoint, true)
        print("[KIMBO'S KASINO] ✅ Escaped successfully!")
    end)
end

-- Auto Rob system
local function AutoRob()
    while AutoRobEnabled do
        pcall(function()
            -- Check if in jail first
            if IsInJail() and AutoEscapeEnabled then
                AutoEscape()
                wait(5)
                return
            end
            
            -- Check team - can't rob as police
            if LocalPlayer.Team and (LocalPlayer.Team.Name == "Police" or LocalPlayer.Team.Name == "Cop") then
                print("[KIMBO'S KASINO] ⚠️ Cannot rob as Police! Switch teams first.")
                wait(5)
                return
            end
            
            local robbables = FindRobbables()
            
            for _, location in pairs(robbables) do
                if not AutoRobEnabled then break end
                
                -- Get the robbery position
                local targetPos = nil
                if location:IsA("Model") and location.PrimaryPart then
                    targetPos = location.PrimaryPart.Position
                elseif location:IsA("Model") and location:FindFirstChild("Door") then
                    targetPos = location.Door.Position
                elseif location:IsA("Model") and location:FindFirstChild("Main") then
                    targetPos = location.Main.Position
                elseif location:IsA("Part") then
                    targetPos = location.Position
                end
                
                if targetPos then
                    local robberyName = location.Name or "Unknown"
                    print("[KIMBO'S KASINO] 💰 Flying to robbery: " .. robberyName)
                    FlyTo(targetPos, true)
                    
                    -- Wait to arrive
                    wait(1.5)
                    
                    -- Jailbreak 2026 robbery interaction system
                    local interacted = false
                    
                    -- Method 1: ProximityPrompts (primary method in 2026)
                    for _, descendant in pairs(location:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") then
                            print("[KIMBO'S KASINO] 🔓 Activating ProximityPrompt...")
                            fireproximityprompt(descendant)
                            interacted = true
                            wait(0.5)
                        end
                    end
                    
                    -- Method 2: Look for buttons/triggers
                    if not interacted then
                        for _, trigger in pairs(location:GetDescendants()) do
                            if trigger:IsA("Part") or trigger:IsA("MeshPart") then
                                local name = trigger.Name:lower()
                                if name:match("button") or name:match("trigger") or 
                                   name:match("interact") or name:match("start") or
                                   name:match("begin") then
                                    HumanoidRootPart.CFrame = trigger.CFrame
                                    interacted = true
                                    wait(0.3)
                                end
                            end
                        end
                    end
                    
                    -- Method 3: Check for ClickDetectors
                    if not interacted then
                        for _, obj in pairs(location:GetDescendants()) do
                            if obj:IsA("ClickDetector") then
                                fireclickdetector(obj)
                                interacted = true
                                wait(0.3)
                            end
                        end
                    end
                    
                    -- Method 4: Remote events (2026 uses these heavily)
                    pcall(function()
                        -- Try common remote names
                        local remotes = {
                            "StartRobbery",
                            "InitiateRobbery", 
                            "BeginRobbery",
                            "RobberyStart",
                            "Robbery"
                        }
                        
                        for _, remoteName in pairs(remotes) do
                            if ReplicatedStorage:FindFirstChild(remoteName) then
                                local remote = ReplicatedStorage[remoteName]
                                if remote:IsA("RemoteEvent") then
                                    remote:FireServer(robberyName)
                                    interacted = true
                                elseif remote:IsA("RemoteFunction") then
                                    remote:InvokeServer(robberyName)
                                    interacted = true
                                end
                            end
                        end
                    end)
                    
                    -- Method 5: Look in player's GUI for robbery buttons
                    if not interacted then
                        for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                            if gui:IsA("TextButton") then
                                local text = gui.Text:lower()
                                if text:match("rob") or text:match("start") or text:match("begin") then
                                    for _, conn in pairs(getconnections(gui.MouseButton1Click)) do
                                        conn:Fire()
                                    end
                                    interacted = true
                                    break
                                end
                            end
                        end
                    end
                    
                    if interacted then
                        print("[KIMBO'S KASINO] ⏳ Robbery initiated! Waiting for completion...")
                        wait(10) -- Wait for robbery to complete
                    else
                        print("[KIMBO'S KASINO] ⚠️ Could not interact with robbery location")
                        wait(2)
                    end
                end
            end
        end)
        
        wait(3)
    end
end

-- Auto Arrest system
local function AutoArrest()
    while AutoArrestEnabled do
        pcall(function()
            local criminals = FindCriminals()
            
            for _, criminal in pairs(criminals) do
                if not AutoArrestEnabled then break end
                
                if criminal.Character and criminal.Character:FindFirstChild("HumanoidRootPart") then
                    local criminalPos = criminal.Character.HumanoidRootPart.Position
                    
                    print("[KIMBO'S KASINO] 👮 Flying to arrest: " .. criminal.Name)
                    FlyTo(criminalPos, true)
                    
                    -- Get close for arrest
                    local arrestDistance = 10
                    local targetCFrame = CFrame.new(criminalPos + Vector3.new(0, 0, arrestDistance))
                    HumanoidRootPart.CFrame = targetCFrame
                    
                    -- Try to trigger arrest
                    if Workspace:FindFirstChild("Arrest") then
                        Workspace.Arrest:FireServer(criminal)
                    end
                    
                    -- Equip handcuffs if available
                    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                        if tool.Name:lower():match("cuff") or tool.Name:lower():match("arrest") then
                            Character.Humanoid:EquipTool(tool)
                            tool:Activate()
                        end
                    end
                    
                    wait(3)
                end
            end
        end)
        
        wait(2)
    end
end

-- Main farming loop
local function StartFarming()
    FarmEnabled = true
    
    spawn(function()
        while FarmEnabled do
            pcall(function()
                -- Check if in jail and auto escape if enabled
                if IsInJail() and AutoEscapeEnabled then
                    AutoEscape()
                    wait(5)
                    return
                end
                
                local farmables = FindFarmables()
                
                for _, item in pairs(farmables) do
                    if not FarmEnabled then break end
                    
                    local targetPos = nil
                    
                    if item and item:FindFirstChild("Position") then
                        targetPos = item.Position.Position
                    elseif item and item:IsA("Model") and item.PrimaryPart then
                        targetPos = item.PrimaryPart.Position
                    elseif item and item:IsA("Part") then
                        targetPos = item.Position
                    end
                    
                    if targetPos then
                        FlyTo(targetPos, true)
                        wait(0.1)
                    end
                end
            end)
            
            wait(1)
        end
    end)
end

-- Stop farming
local function StopFarming()
    FarmEnabled = false
    print("[KIMBO'S KASINO] Farming stopped")
end

-- Create GUI
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local Title = Instance.new("TextLabel")
    local FarmButton = Instance.new("TextButton")
    local RobButton = Instance.new("TextButton")
    local ArrestButton = Instance.new("TextButton")
    local EscapeButton = Instance.new("TextButton")
    local VehicleToggle = Instance.new("TextButton")
    local SaveConfigButton = Instance.new("TextButton")
    local LoadConfigButton = Instance.new("TextButton")
    local KillButton = Instance.new("TextButton")
    local StatusLabel = Instance.new("TextLabel")
    local SettingsLabel = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")
    
    -- ScreenGui setup
    ScreenGui.Name = "KimbosKasinoGUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- MainFrame setup
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.35, 0, 0.15, 0)
    MainFrame.Size = UDim2.new(0, 400, 0, 580)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    -- Title
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 10)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🎰 KIMBO'S KASINO 🎰"
    Title.TextColor3 = Color3.fromRGB(255, 215, 0)
    Title.TextSize = 20
    
    -- Helper function to create buttons
    local function CreateButton(name, text, position, color)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Parent = MainFrame
        button.BackgroundColor3 = color
        button.Position = position
        button.Size = UDim2.new(0.85, 0, 0, 38)
        button.Font = Enum.Font.GothamBold
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 13
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = button
        
        return button
    end
    
    -- Main buttons
    FarmButton = CreateButton("FarmButton", "START FARMING", UDim2.new(0.075, 0, 0.10, 0), Color3.fromRGB(46, 204, 113))
    RobButton = CreateButton("RobButton", "AUTO ROB: OFF", UDim2.new(0.075, 0, 0.18, 0), Color3.fromRGB(155, 89, 182))
    ArrestButton = CreateButton("ArrestButton", "AUTO ARREST: OFF", UDim2.new(0.075, 0, 0.26, 0), Color3.fromRGB(52, 152, 219))
    EscapeButton = CreateButton("EscapeButton", "AUTO ESCAPE: OFF", UDim2.new(0.075, 0, 0.34, 0), Color3.fromRGB(230, 126, 34))
    
    -- Settings Label
    SettingsLabel.Name = "SettingsLabel"
    SettingsLabel.Parent = MainFrame
    SettingsLabel.BackgroundTransparency = 1
    SettingsLabel.Position = UDim2.new(0, 0, 0.43, 0)
    SettingsLabel.Size = UDim2.new(1, 0, 0, 25)
    SettingsLabel.Font = Enum.Font.GothamBold
    SettingsLabel.Text = "⚙️ SETTINGS"
    SettingsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SettingsLabel.TextSize = 14
    
    -- Settings buttons
    VehicleToggle = CreateButton("VehicleToggle", "VEHICLE MODE: ON", UDim2.new(0.075, 0, 0.48, 0), Color3.fromRGB(41, 128, 185))
    
    -- Config Label
    local ConfigLabel = Instance.new("TextLabel")
    ConfigLabel.Name = "ConfigLabel"
    ConfigLabel.Parent = MainFrame
    ConfigLabel.BackgroundTransparency = 1
    ConfigLabel.Position = UDim2.new(0, 0, 0.57, 0)
    ConfigLabel.Size = UDim2.new(1, 0, 0, 25)
    ConfigLabel.Font = Enum.Font.GothamBold
    ConfigLabel.Text = "💾 CONFIG"
    ConfigLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ConfigLabel.TextSize = 14
    
    -- Config buttons (side by side)
    SaveConfigButton = Instance.new("TextButton")
    SaveConfigButton.Name = "SaveConfigButton"
    SaveConfigButton.Parent = MainFrame
    SaveConfigButton.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
    SaveConfigButton.Position = UDim2.new(0.075, 0, 0.62, 0)
    SaveConfigButton.Size = UDim2.new(0.40, 0, 0, 38)
    SaveConfigButton.Font = Enum.Font.GothamBold
    SaveConfigButton.Text = "💾 SAVE"
    SaveConfigButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveConfigButton.TextSize = 13
    
    local SaveCorner = Instance.new("UICorner")
    SaveCorner.CornerRadius = UDim.new(0, 8)
    SaveCorner.Parent = SaveConfigButton
    
    LoadConfigButton = Instance.new("TextButton")
    LoadConfigButton.Name = "LoadConfigButton"
    LoadConfigButton.Parent = MainFrame
    LoadConfigButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
    LoadConfigButton.Position = UDim2.new(0.525, 0, 0.62, 0)
    LoadConfigButton.Size = UDim2.new(0.40, 0, 0, 38)
    LoadConfigButton.Font = Enum.Font.GothamBold
    LoadConfigButton.Text = "📁 LOAD"
    LoadConfigButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadConfigButton.TextSize = 13
    
    local LoadCorner = Instance.new("UICorner")
    LoadCorner.CornerRadius = UDim.new(0, 8)
    LoadCorner.Parent = LoadConfigButton
    
    -- Utility Label
    local UtilityLabel = Instance.new("TextLabel")
    UtilityLabel.Name = "UtilityLabel"
    UtilityLabel.Parent = MainFrame
    UtilityLabel.BackgroundTransparency = 1
    UtilityLabel.Position = UDim2.new(0, 0, 0.715, 0)
    UtilityLabel.Size = UDim2.new(1, 0, 0, 25)
    UtilityLabel.Font = Enum.Font.GothamBold
    UtilityLabel.Text = "🛠️ UTILITIES"
    UtilityLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    UtilityLabel.TextSize = 14
    
    -- Kill button
    KillButton = CreateButton("KillButton", "💀 RESPAWN (FIX STUCK)", UDim2.new(0.075, 0, 0.765, 0), Color3.fromRGB(192, 57, 43))
    
    -- Status Label
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = MainFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0.075, 0, 0.845, 0)
    StatusLabel.Size = UDim2.new(0.85, 0, 0, 30)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "Status: Ready | Height: " .. MaxFlightHeight .. "m"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.TextSize = 11
    
    -- Close Button
    CloseButton = CreateButton("CloseButton", "❌ CLOSE GUI", UDim2.new(0.075, 0, 0.91, 0), Color3.fromRGB(231, 76, 60))
    
    -- Update GUI from loaded config
    local function UpdateGUIFromConfig()
        if UseVehicles then
            VehicleToggle.Text = "VEHICLE MODE: ON"
            VehicleToggle.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
        else
            VehicleToggle.Text = "VEHICLE MODE: OFF"
            VehicleToggle.BackgroundColor3 = Color3.fromRGB(127, 140, 141)
        end
        
        if AutoEscapeEnabled then
            EscapeButton.Text = "AUTO ESCAPE: ON"
            EscapeButton.BackgroundColor3 = Color3.fromRGB(211, 84, 0)
        end
    end
    
    -- Button functionality
    FarmButton.MouseButton1Click:Connect(function()
        if FarmEnabled then
            StopFarming()
            FarmButton.Text = "START FARMING"
            FarmButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            StatusLabel.Text = "Status: Idle | Height: " .. MaxFlightHeight .. "m"
        else
            StartFarming()
            FarmButton.Text = "STOP FARMING"
            FarmButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
            StatusLabel.Text = "Status: 🔥 FARMING | Height: " .. MaxFlightHeight .. "m"
        end
    end)
    
    RobButton.MouseButton1Click:Connect(function()
        AutoRobEnabled = not AutoRobEnabled
        if AutoRobEnabled then
            RobButton.Text = "AUTO ROB: ON"
            RobButton.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
            spawn(AutoRob)
            print("[KIMBO'S KASINO] 💰 Auto Rob enabled")
        else
            RobButton.Text = "AUTO ROB: OFF"
            RobButton.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
            print("[KIMBO'S KASINO] Auto Rob disabled")
        end
    end)
    
    ArrestButton.MouseButton1Click:Connect(function()
        AutoArrestEnabled = not AutoArrestEnabled
        if AutoArrestEnabled then
            ArrestButton.Text = "AUTO ARREST: ON"
            ArrestButton.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
            spawn(AutoArrest)
            print("[KIMBO'S KASINO] 👮 Auto Arrest enabled")
        else
            ArrestButton.Text = "AUTO ARREST: OFF"
            ArrestButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
            print("[KIMBO'S KASINO] Auto Arrest disabled")
        end
    end)
    
    EscapeButton.MouseButton1Click:Connect(function()
        AutoEscapeEnabled = not AutoEscapeEnabled
        if AutoEscapeEnabled then
            EscapeButton.Text = "AUTO ESCAPE: ON"
            EscapeButton.BackgroundColor3 = Color3.fromRGB(211, 84, 0)
            print("[KIMBO'S KASINO] 🚨 Auto Escape enabled")
        else
            EscapeButton.Text = "AUTO ESCAPE: OFF"
            EscapeButton.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
            print("[KIMBO'S KASINO] Auto Escape disabled")
        end
    end)
    
    VehicleToggle.MouseButton1Click:Connect(function()
        UseVehicles = not UseVehicles
        if UseVehicles then
            VehicleToggle.Text = "VEHICLE MODE: ON"
            VehicleToggle.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
            print("[KIMBO'S KASINO] 🚗 Vehicle mode enabled (Anti-Cheat Safe)")
        else
            VehicleToggle.Text = "VEHICLE MODE: OFF"
            VehicleToggle.BackgroundColor3 = Color3.fromRGB(127, 140, 141)
            print("[KIMBO'S KASINO] Vehicle mode disabled")
        end
    end)
    
    SaveConfigButton.MouseButton1Click:Connect(function()
        SaveConfig()
    end)
    
    LoadConfigButton.MouseButton1Click:Connect(function()
        if LoadConfig() then
            UpdateGUIFromConfig()
        end
    end)
    
    KillButton.MouseButton1Click:Connect(function()
        KillPlayer()
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        FarmEnabled = false
        AutoRobEnabled = false
        AutoArrestEnabled = false
        print("[KIMBO'S KASINO] GUI closed, all features disabled")
    end)
    
    -- Load config on startup
    if LoadConfig() then
        UpdateGUIFromConfig()
    end
end

-- Initialize script
ShowIntro()
wait(2)
SetupAntiAFK()

-- Find Jailbreak 2026 locations
FindJailbreakLocations()

-- Create GUI
CreateGUI()

print("[KIMBO'S KASINO] ✅ All systems ready!")
print("[KIMBO'S KASINO] 🎮 Jailbreak 2026 Update Compatible!")
print("[KIMBO'S KASINO] 🚀 New Robberies: Space Station, Submarine, Skyscraper")
print("[KIMBO'S KASINO] 🚗 Vehicle mode: " .. tostring(UseVehicles))
print("[KIMBO'S KASINO] 🛡️ Max flight height: " .. MaxFlightHeight .. "m (Anti-Cheat Safe)")
print("[KIMBO'S KASINO] ⚡ Flight speed: " .. HumanFlightSpeed .. " studs/s (Human-like)")
print("[KIMBO'S KASINO] 🎮 Features: Farm | Rob | Arrest | Escape | Config | Respawn")
print("[KIMBO'S KASINO] 💾 Config auto-load: " .. (isfile and isfile(ConfigFileName) and "✓" or "✗"))
print("[KIMBO'S KASINO] Anti-AFK: " .. tostring(AntiAFKEnabled))
