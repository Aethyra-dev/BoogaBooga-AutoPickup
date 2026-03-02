--// Services
local Stats               = game:GetService("Stats")
local Players             = game:GetService("Players")
local GuiService          = game:GetService("GuiService")
local RunService          = game:GetService("RunService")
local VirtualUser         = game:GetService("VirtualUser")
local HttpService         = game:GetService("HttpService")
local TweenService        = game:GetService("TweenService")
local UserInputService    = game:GetService("UserInputService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local MarketplaceService  = game:GetService("MarketplaceService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

-- Get player
local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()

--// Game Check
-- ID Setup
local target_place_id = game.PlaceId--11729688377 -- Booga Booga REBON
local active_place_id = game.PlaceId -- Grab place ID

-- Check Ids make sure they match!
if active_place_id ~= target_place_id then
    print("Not supported!")
    task.wait(5)  -- Allow us to load in and stuff
    
    -- Kick player to make them sad :D
    print("Game isn't supported at this time. " .. active_place_id)
    Player:Kick("Game isn't supported at this time. " .. active_place_id)
else
    print("Supported!")
end

--// Detection Bypass Attempt for Booga Booga's shitty Anti-Cheat
-- Someone said about this website having stuff I may need "https://docs.volt.bz/docs/debug"
-- Come back to this later (02/02/2025 6:18 PM)

--// File Directories 
local baseFolder = "AethyrionHub"									-- Main Directory
local gameFolder = baseFolder .. "/BoogaBoogaReborn" 			    -- Main Game Directory
local scriptThemesJson = gameFolder .. "/ScriptThemes.json"		    -- Default Themes Configs
local scriptSettingsJson = gameFolder .. "/ScriptSettings.json"		-- Default Script Settings
local scriptConfigsFolder = gameFolder .. "/ScriptConfigs"			-- User Script Settings / Configs
local tweenConfigsFolder = gameFolder .. "/TweenConfigs"			-- Tween configs / AFK configs

-- Attempt to create directories if they don't exist
-- Coded in Visual Studio Code, this is used to suppress undefined-global warnings for executor functions so we know where the ACTUAL errors are
---@diagnostic disable: undefined-global
pcall(function()
	if not isfolder(baseFolder) then
		makefolder(baseFolder)
	end
end)

pcall(function()
	if not isfolder(scriptConfigsFolder) then
		makefolder(scriptConfigsFolder)
	end
end)

pcall(function()
	if not isfolder(tweenConfigsFolder) then
		makefolder(tweenConfigsFolder)
	end
end)

pcall(function()
    if not isfile(scriptSettingsJson) then
        writefile(scriptSettingsJson, "{}")
    end
end)

pcall(function()
    if not isfile(scriptThemesJson) then
        writefile(scriptThemesJson, "{}")
    end
end)
---@diagnostic enable: undefined-global

-- Pre-define Variables taken from the Game
local Modules
local Packets
local ItemIDS
local ItemData

--// GAME REQUIREMENTS -- BOOGA BOOGA REBORN // Protection for Studio Testing / Early Development
local success, error = pcall(function()
	local Modules = ReplicatedStorage:WaitForChild("Modules", 3)
	if not Modules then
		warn("ReplicatedStorage.Modules folder not found.")
		return
	end
	-- These modules are required for the hub to function properly
	Packets = select(2, pcall(require, Modules:WaitForChild("Packets", 3))) -- Asked ChatGPT to shut this ERROR line up - it was annoying me - Grave
	-- Used to send a calls to the server ^
	if not Packets then
		warn("ReplicatedStorage.Modules.Packets module file not found. Are you in the correct game?")
		return
	end

    ItemIDS = select(2, pcall(require, Modules:WaitForChild("ItemIDS", 3))) -- Asked ChatGPT to shut this ERROR line up - it was annoying me - Grave
	-- Used to define items and what they are ^
	if not ItemIDS then
		warn("ReplicatedStorage.Modules.ItemIDS module file not found. Are you in the correct game?")
		return
	end

	ItemData = select(2, pcall(require, Modules:WaitForChild("ItemData", 3))) -- Asked ChatGPT to shut this ERROR line up - it was annoying me - Grave
	-- Used to define items all items just no ids ^
	if not ItemData then
		warn("ReplicatedStorage.Modules.ItemData module file not found. Are you in the correct game?")
		return
	end
end)

if success then
	print("Loaded required modules successfully.")
else
	print("Error happened:", error)
end

--// Themes Variables
-- Notification Colors
local NotifyColors = {
	Info = Color3.fromRGB(90, 140, 255),
	Error = Color3.fromRGB(255, 80, 80),
	Success = Color3.fromRGB(90, 200, 120),
	Update = Color3.fromRGB(23, 10, 204)
}

local boot_animation_settings = {
	DURATION = 3.5,
	FADE_TIME = 0.6,
	BOB_FREQ = 0.75,
	BOB_AMPLITUDE = 8,
	PULSE_SPEED = 2,
	spacing = 30,
    text = "Aethyrion"
}

local trashExecuters = {"Solaria"}
local Script_Version = "1.0.0" -- Script Version

-- Script settings
local Script_Config = {
    --// Menu Start

    menu_toggle_keybind = {"LeftControl"},

    --// Menu End
    --// Player Start

    -- Walkspeed
    player_walkspeed_enabled = false,
    player_walkspeed_toggle_keybind = {},
    player_walkspeed_speed = 16, -- Max  21 as  22+ is anticheat detected
    player_walkspeed_increase_toggle_keybind = {},
    player_walkspeed_decrease_toggle_keybind = {},

    -- Moutain Climber
    player_moutainclimber_enabled = false,
    player_moutainclimber_toggle_keybind = {},

    -- Spider
    player_spider_enabled = false,
    player_spider_toggle_keybind = {},

    -- No-clip
    player_noclip_enabled = false,
    player_noclip_toggle_keybind = {},

    -- Spider
    player_nohutdoors_enabled = false,
    player_nohutdoors_toggle_keybind = {},

    --// Player End
    --// Farming Start

    farming_autoplant_enabled = false,
    farming_autoplant_selected = {"Bloodfruit"},
    farming_autoplant_toggle_keybind = {},

    farming_autoharvest_enabled = false,
    farming_autoharvest_toggle_keybind = {},

    farming_automove_enabled = false,
    farming_move_speed = 18,
    farming_priority_selected = {"Plant", "Box"}, -- Plant, Box // Plant is grown fruit while Box is simply a seedless box
    farming_movementTye = {"Tween", "Walk", "cFrame"},
    farming_automove_toggle_keybind = {},

    farming_autohequiphoe_enabled = false,
    farming_autohequiphoe_toggle_keybind = {},

    farming_showtweenlocation_enabled = false,
    farming_showtweenlocation_toggle_keybind = {},

    --// Farming End
    --// Combat Start

    combat_autoheal_enabled = false,
    combat_autoheal_threshold = 99, -- Keep max HP
    combat_autoheal_toggle_keybind = {},

    combat_autoeat_enabled = false,
    combat_autoeat_threshold = 70,
    combat_autoeat_toggle_keybind = {},

    combat_autocps_enabled = false,
    combat_autocps_threshold = 99, -- Keep max HP
    combat_autocps = 40, -- Keep max HP
    combat_autocps_toggle_keybind = {},

    --// Combat End
    --// Miscellaneous Start
    
    miscellaneous_antiafk_enabled = false,
    miscellaneous_antiafk_toggle_keybind = {},

    miscellaneous_autocoinpress_enabled = false,
    miscellaneous_autocoinpress_speed = 60,
    miscellaneous_autocoinpress_selected = {},
    miscellaneous_autocoinpress_toggle_keybind = {},

    --// Miscellaneous End
    --// Tween Start

    --// Tween End
    --// Webhook Start

    webhook_enabled = false,
    webhook_toggle_keybind = {},
    webhook_url = "",

    --// Webhook End
    --// WebSocket Connection Start

    -- Hats
    hats_client_connection_enabled = false,
    hats_give_all_enabled = false,

    -- Skins
    skins_client_connection_enabled = false,
    skins_give_all_enabled = false,

    -- Alt Account Controller
    master_account = false,
    master_accept_key = "DO NOT SHARE THIS KEY", -- If you dont have this Key you cant sent anything
    any_slaves = false, -- Disables the need for Whitelisting keys
    slaves = {}, -- All Slave Access Keys here

    slave_account = false,
    slave_client_connection = false,
    slave_screen_shot = false, -- Attempt to show what/where the alt is
    slave_access_key = "DO NOT SHARE THIS KEY",
    -- The SLAVE if has any attempts from other slaves to connnect to it, it will send the data that they need to work to them

    --// WebSocket Connection End
    --// Stats Start

    stats_enabled = false

    --// Stats End
}

-- Attempt to fetch all Growables
local fruitList = {}

for itemName, data in pairs(ItemData) do
    if type(data) == "table" then
        if data.grows and data.growthTime then
            table.insert(fruitList, itemName)
        end
    end
end

-- Grab all Plants for Auto Harvest
local ValidPlants = {}

for itemName, data in pairs(ItemData) do
    if type(data) == "table" then
        if data.itemType == "crop" then
            ValidPlants[itemName] = true
        end
    end
end

-- APIs
local Config = {}

function Config:Get(key)
    return Script_Config[key]
end

function Config:Set(key, value)
    Script_Config[key] = value
end

-- Potion Recipies
local potion_recipes = {
    poison = {
        ["prickly pear"] = 3, 
        ["Magnetite"] = 1
    },
    swift = {
        ["Crystal"] = 1, 
        ["Cloudberry"] = 3
    },
    slowness = {
        ["Crystal"] = 1,
        ["Ice Cube"] = 3,
        ["Frostfruit"] = 3
    },
    healing = {
        ["Bloodfruit"] = 5,
        ["Strawberry"] = 2
    },
    instant_dmg = {
        ["Prickly Pear"] = 3,
        ["Adurite"] = 3
    },
    fire_resistant = {
        ["Firehide"] = 2
    },
    strength = {
        ["Bloodfruit"] = 2,
        ["Adurite"] = 2
    },
    weakness = {
        ["Berrys"] = 2,
        ["Magnetite"] = 3
    },
    haste = {
        ["Iron"] = 2,
        ["Lemon"] = 2
    },
    placebo = { -- Cheapest?
        ["Iron"] = 3,
        ["Lemon"] = 3
    }
}

--// Notifications GUI
local NotificationsGui = Instance.new("ScreenGui")
NotificationsGui.Name = "AethyrionHubNotifications"
NotificationsGui.ResetOnSpawn = false
NotificationsGui.Parent = Player:WaitForChild("PlayerGui")

local NotificationsContainer = Instance.new("Frame")
NotificationsContainer.AnchorPoint = Vector2.new(1, 1) -- bottom-right
NotificationsContainer.Position = UDim2.new(1, -20, 1, -20)
NotificationsContainer.Size = UDim2.fromOffset(360, 400)
NotificationsContainer.BackgroundTransparency = 1
NotificationsContainer.Parent = NotificationsGui

local NotificationsLayout = Instance.new("UIListLayout")
NotificationsLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotificationsLayout.Padding = UDim.new(0, 10)
NotificationsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationsLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotificationsLayout.FillDirection = Enum.FillDirection.Vertical -- make it stack top→bottom
NotificationsLayout.Parent = NotificationsContainer

--// Notifications Function
function Notify(kind, title, message, duration)
    kind = kind or "Info"
    duration = duration or 4

    -- Notification Card
    local Card = Instance.new("Frame")
    Card.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    Card.BorderSizePixel = 0
    Card.ClipsDescendants = true
    Card.Size = UDim2.new(1, 0, 0, 50) -- let UIListLayout handle width
    Card.AutomaticSize = Enum.AutomaticSize.Y
    Card.Parent = NotificationsContainer
    local CardCorner = Instance.new("UICorner", Card)
    CardCorner.CornerRadius = UDim.new(0, 12)

    -- Color strip
    local Strip = Instance.new("Frame")
    Strip.Size = UDim2.new(0.1, 6, 1, 0) -- width fixed, height = 100% of card
    Strip.Position = UDim2.new(0, -20, 0, 0)
    Strip.BackgroundColor3 = NotifyColors[kind] or NotifyColors.Info
    Strip.BorderColor3 = NotifyColors[kind] or NotifyColors.Info
    Strip.BorderSizePixel = 1
    Strip.Parent = Card

    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -40, 0, 20)
    TitleLabel.Position = UDim2.fromOffset(30, 3)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or kind
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextColor3 = Color3.fromRGB(240,240,240)
    TitleLabel.Parent = Card

    -- Message Body
    local Body = Instance.new("TextLabel")
    Body.AutomaticSize = Enum.AutomaticSize.Y
    Body.Size = UDim2.new(1, -40, 0, 0)
    Body.Position = UDim2.fromOffset(30, 20)
    Body.BackgroundTransparency = 1
    Body.TextWrapped = true
    Body.TextYAlignment = Enum.TextYAlignment.Top
    Body.TextXAlignment = Enum.TextXAlignment.Left
    Body.Text = message or ""
    Body.Font = Enum.Font.Gotham
    Body.TextSize = 13
    Body.TextColor3 = Color3.fromRGB(210,210,210)
    Body.Parent = Card

    -- Auto size body height
    Body:GetPropertyChangedSignal("TextBounds"):Connect(function()
        Body.Size = UDim2.new(1, -40, 0, Body.TextBounds.Y)
    end)
    task.wait() -- ensure first render updates size

    -- Animate entry
    Card.Position = Card.Position + UDim2.fromOffset(40,0)
    TweenService:Create(
        Card,
        TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {
            BackgroundTransparency = 0,
            Position = Card.Position - UDim2.fromOffset(40,0)
        }
    ):Play()

    -- Click to close
    Card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            TweenService:Create(Card, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            task.delay(0.2, function() Card:Destroy() end)
        end
    end)
    Card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            TweenService:Create(Strip, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            task.delay(0.2, function() Strip:Destroy() end)
        end
    end)

    -- Auto close
    task.delay(duration, function()
        if Card.Parent then
            TweenService:Create(Card, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            
            task.wait(0.2)
            Card:Destroy()
        end
    end)
    task.delay(duration, function()
        if Strip.Parent then
            TweenService:Create(Strip, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            
            task.wait(0.2)
            Strip:Destroy()
        end
    end)
end

--// Script Functions
---@diagnostic disable: undefined-global
local function sendWebhook(data, Url)
	local jsonData = HttpService:JSONEncode(data)

	http_request({
		Url = Url, -- Made this a variable so I dont need to create a new function and add unneeded lines!
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = jsonData
	})
end
---@diagnostic enable: undefined-global

--// Booga Booga Reborn Functions
-- FARMING SYSTEM
local RunningPlant = false
local RunningMove = false
local CurrentTween = nil
local TweenMarker = nil
local DeployablesFolder = workspace:WaitForChild("Deployables")
local PLANT_RADIUS = 60

-- Character / HRP
local function GetHRP()
    local character = Player.Character or Player.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart")
end

-- Priority (Box Only For Now)
local function GetNextBox()
    local hrp = GetHRP()
    local origin = hrp.Position
    local priority = Config:Get("farming_priority_selected")

    for _, p in ipairs(priority or {}) do
        if p == "Box" then
            for _, box in ipairs(DeployablesFolder:GetChildren()) do
                if box.Name == "Plant Box"
                and box:GetAttribute("EntityID")
                and not box:FindFirstChild("Seed") then

                    local pivot = box:GetPivot()
                    local dist = (pivot.Position - origin).Magnitude

                    if dist <= PLANT_RADIUS then
                        return box
                    end
                end
            end
        end
    end

    return nil
end

local function ClearTweenMarker()
    if TweenMarker then
        TweenMarker:Destroy()
        TweenMarker = nil
    end
end

local function ShowTweenMarker(box)
    if not Config:Get("farming_showtweenlocation_enabled") then
        ClearTweenMarker()
        return
    end

    ClearTweenMarker()

    if not box then return end

    local adornee = box.PrimaryPart or box:FindFirstChildWhichIsA("BasePart")
    if not adornee then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "PlantTweenTarget"
    gui.Adornee = adornee
    gui.Size = UDim2.fromOffset(110, 32)
    gui.StudsOffset = Vector3.new(0, 2.5, 0)
    gui.AlwaysOnTop = true
    gui.Parent = workspace

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "Target"
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.Parent = gui

    TweenMarker = gui
end

local function TweenToBox(box)
    local hrp = GetHRP()
    local pivot = box:GetPivot()

    if CurrentTween then
        CurrentTween:Cancel()
        CurrentTween = nil
    end

    ShowTweenMarker(box)

    local dist = (pivot.Position - hrp.Position).Magnitude
    local speed = Config:Get("farming_move_speed") or 18
    local time = dist / speed

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        { CFrame = pivot * CFrame.new(0, 5, 0) }
    )

    CurrentTween = tween
    tween:Play()
    tween.Completed:Wait()

    ClearTweenMarker()
end

local function StartAutoMove()
    if RunningMove then return end
    RunningMove = true

    task.spawn(function()
        while RunningMove do
            if Config:Get("farming_automove_enabled") then
                local box = GetNextBox()

                if box then
                    TweenToBox(box)
                else
                    ClearTweenMarker()
                end
            end

            task.wait(0.05)
        end
    end)
end

local function StopAutoMove()
    RunningMove = false

    if CurrentTween then
        CurrentTween:Cancel()
        CurrentTween = nil
    end

    ClearTweenMarker()
end

local function StartAutoPlant()
    if RunningPlant then return end
    RunningPlant = true

    task.spawn(function()
        while RunningPlant do
            if Config:Get("farming_autoplant_enabled") then
                local selected = Config:Get("farming_autoplant_selected")
                local origin = Players.LocalPlayer.Character.PrimaryPart.Position

                for _, box in ipairs(DeployablesFolder:GetChildren()) do
                    if box.Name == "Plant Box"
                    and box:GetAttribute("EntityID")
                    and not box:FindFirstChild("Seed") then

                        local dist = (box:GetPivot().Position - origin).Magnitude
                        if dist <= PLANT_RADIUS then
                            local crop = selected[1]
                            local itemID = ItemIDS and ItemIDS[crop]
                            -- Plant immediately
                            Packets.InteractStructure.send({
                                entityID = box:GetAttribute("EntityID"),
                                itemID = itemID,
                            })
                        end
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end

local function StopAutoPlant()
    RunningPlant = false
end

local RunningHarvest = false
local HARVEST_RADIUS = 25
local SCAN_INTERVAL = 0.2      -- how often we rescan area
local PROCESS_PER_TICK = 3     -- how many plants per loop
local LOOP_DELAY = 0.03        -- ~33 loops/sec

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Blacklist

local ignoreList = {}
local plantQueue = {}
local recentlyPicked = {}
local lastScan = 0

local function ScanPlants()
    local character = Player.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    if not root then return end

    table.clear(ignoreList)
    ignoreList[1] = character
    overlapParams.FilterDescendantsInstances = ignoreList

    local parts = workspace:GetPartBoundsInRadius(root.Position, HARVEST_RADIUS, overlapParams)

    local checkedModels = {}
    table.clear(plantQueue)

    for i = 1, #parts do
        local model = parts[i].Parent
        if model
        and not checkedModels[model]
        and ValidPlants[model.Name] then

            checkedModels[model] = true
            local entityId = model:GetAttribute("EntityID")

            if entityId then
                plantQueue[#plantQueue+1] = entityId
            end
        end
    end
end

local function StartAutoHarvest()
    if RunningHarvest then return end
    RunningHarvest = true

    task.spawn(function()
        while RunningHarvest do
            if Config:Get("farming_autoharvest_enabled") then

                local now = tick()

                -- Rescan occasionally, not every frame
                if now - lastScan > SCAN_INTERVAL then
                    lastScan = now
                    ScanPlants()
                end

                local processed = 0
                local i = 1

                while processed < PROCESS_PER_TICK and i <= #plantQueue do
                    local id = plantQueue[i]

                    if not recentlyPicked[id] then
                        recentlyPicked[id] = now
                        Packets.Pickup.send(id)
                        processed += 1
                    end

                    i += 1
                end

                -- simple timestamp cooldown cleanup
                for id, timeSent in pairs(recentlyPicked) do
                    if now - timeSent > 0.2 then
                        recentlyPicked[id] = nil
                    end
                end
            end

            task.wait(LOOP_DELAY)
        end
    end)
end

local function StopAutoHarvest()
    RunningHarvest = false
end

--// Main GUI
function main_hub()
    Notify("info", "Aethyrion Hub", "Aethyrion Hub GUI has Loaded", 14)

	--// SCREEN GUI
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "AethyrionHub"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = Player:WaitForChild("PlayerGui")

	--// MAIN WINDOW
	local Main = Instance.new("Frame")
	Main.Size = UDim2.fromOffset(680, 420)
	Main.Position = UDim2.fromScale(0.5, 0.5)
	Main.AnchorPoint = Vector2.new(0.5, 0.5)
	Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	Main.BorderSizePixel = 0
	Main.Parent = ScreenGui
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

	--// TOP BAR
	local TopBar = Instance.new("Frame")
	TopBar.Size = UDim2.new(1, 0, 0, 46)
	TopBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	TopBar.BorderSizePixel = 0
	TopBar.Parent = Main
	Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)

	--// TITLE
	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(0.5, -20, 1, 0)
	Title.Position = UDim2.fromOffset(20, 0)
	Title.BackgroundTransparency = 1
	Title.Text = "Aethyrion Hub"
	Title.Font = Enum.Font.Bangers
	Title.TextSize = 21
	Title.TextColor3 = Color3.fromRGB(235, 235, 235)
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = TopBar

	--// DISCORD
	local Discord = Instance.new("TextLabel")
	Discord.Size = UDim2.new(0.5, -20, 1, 0)
	Discord.Position = UDim2.new(0.1, 0, 0, 0)
	Discord.BackgroundTransparency = 1
	Discord.Text = "discord.gg/7B4BTjMs66"
	Discord.Font = Enum.Font.Gotham
	Discord.TextSize = 14
	Discord.TextColor3 = Color3.fromRGB(200, 200, 200)
	Discord.TextXAlignment = Enum.TextXAlignment.Right
	Discord.Parent = TopBar

	--// OWNER
	local Ownership = Instance.new("TextLabel")
	Ownership.Size = UDim2.new(0.5, -20, 1, 0)
	Ownership.Position = UDim2.new(-0.38, 0, 0.3, 0)
	Ownership.BackgroundTransparency = 1
	Ownership.Text = "@nulledme"
	Ownership.Font = Enum.Font.Gotham
	Ownership.TextSize = 7
	Ownership.TextColor3 = Color3.fromRGB(200, 200, 200)
	Ownership.TextXAlignment = Enum.TextXAlignment.Right
	Ownership.Parent = TopBar

	--// VERSION
	local Version = Instance.new("TextLabel")
	Version.Size = UDim2.new(0.5, -20, 1, 0)
	Version.Position = UDim2.new(-0.3, 0, 0.3, 0)
	Version.BackgroundTransparency = 1
	Version.Text = Script_Version or "vERROR"
	Version.Font = Enum.Font.Gotham
	Version.TextSize = 9
	Version.TextColor3 = Color3.fromRGB(200, 200, 200)
	Version.TextXAlignment = Enum.TextXAlignment.Right
	Version.Parent = TopBar

	--// BUTTON FACTORY
	local function makeButton(text, color)
		local b = Instance.new("TextButton")
		b.Size = UDim2.fromOffset(26, 26)
		b.Text = text
		b.Font = Enum.Font.GothamBold
		b.TextSize = 14
		b.TextColor3 = Color3.fromRGB(230, 230, 230)
		b.BackgroundColor3 = color
		b.BorderSizePixel = 0
		b.AutoButtonColor = false
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		return b
	end

	--// CONTROLS
	local Controls = Instance.new("Frame")
	Controls.Size = UDim2.fromOffset(96, 28)
	Controls.Position = UDim2.new(1, -104, 0.5, -14)
	Controls.BackgroundTransparency = 1
	Controls.Parent = TopBar

	local UIList = Instance.new("UIListLayout")
	UIList.FillDirection = Enum.FillDirection.Horizontal
	UIList.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIList.Padding = UDim.new(0, 6)
	UIList.Parent = Controls

	local MinBtn  = makeButton("–", Color3.fromRGB(45, 45, 45))
	local MaxBtn  = makeButton("▢", Color3.fromRGB(45, 45, 45))
	local ExitBtn = makeButton("X", Color3.fromRGB(120, 45, 45))

	MinBtn.Parent = Controls
	MaxBtn.Parent = Controls
	ExitBtn.Parent = Controls

	--// FULLSCREEN
	local fullscreen = false
	local normalSize = Main.Size
	local normalPos  = Main.Position

	MaxBtn.MouseButton1Click:Connect(function()
		fullscreen = not fullscreen
		if fullscreen then
			normalSize = Main.Size
			normalPos  = Main.Position
			local inset = GuiService:GetGuiInset()
			Main.AnchorPoint = Vector2.new(0, 0)
			Main.Position = UDim2.fromOffset(inset.X, inset.Y)
			Main.Size = UDim2.new(1, -inset.X, 1, -inset.Y)
		else
			Main.Size = normalSize
			Main.Position = normalPos
		end
	end)

    --// EXIT BUTTON
    local function ConfirmExit()
        -- DISABLE MAIN WHILE POPUP IS OPEN
        Main.Active = false

        -- POPUP FRAME
        local ConfirmFrame = Instance.new("Frame")
        ConfirmFrame.Size = UDim2.new(0, 300, 0, 120)
        ConfirmFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        ConfirmFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        ConfirmFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        ConfirmFrame.BorderSizePixel = 0
        ConfirmFrame.Parent = ScreenGui
        Instance.new("UICorner", ConfirmFrame).CornerRadius = UDim.new(0, 12)

        -- MESSAGE
        local Msg = Instance.new("TextLabel")
        Msg.Size = UDim2.new(1, -20, 0, 50)
        Msg.Position = UDim2.fromOffset(10, 10)
        Msg.BackgroundTransparency = 1
        Msg.Text = "Are you sure you want to close the script?"
        Msg.TextColor3 = Color3.fromRGB(230, 230, 230)
        Msg.Font = Enum.Font.Gotham
        Msg.TextSize = 14
        Msg.TextWrapped = true
        Msg.Parent = ConfirmFrame

        -- YES BUTTON
        local YesBtn = Instance.new("TextButton")
        YesBtn.Size = UDim2.new(0.4, 0, 0, 30)
        YesBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
        YesBtn.BackgroundColor3 = Color3.fromRGB(120, 45, 45)
        YesBtn.Text = "Yes"
        YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        YesBtn.Font = Enum.Font.GothamBold
        YesBtn.TextSize = 14
        YesBtn.Parent = ConfirmFrame
        Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 6)

        -- NO BUTTON
        local NoBtn = Instance.new("TextButton")
        NoBtn.Size = UDim2.new(0.4, 0, 0, 30)
        NoBtn.Position = UDim2.new(0.55, 0, 0.7, 0)
        NoBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        NoBtn.Text = "No"
        NoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        NoBtn.Font = Enum.Font.GothamBold
        NoBtn.TextSize = 14
        NoBtn.Parent = ConfirmFrame
        Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 6)

        -- BUTTON CALLBACKS
        YesBtn.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)

        NoBtn.MouseButton1Click:Connect(function()
            ConfirmFrame:Destroy()
            Main.Active = true
        end)
    end

    ExitBtn.MouseButton1Click:Connect(function()
        ConfirmExit()
    end)

	--// DRAGGING
	do
		local dragging, dragStart, startPos
		TopBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = Main.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local delta = input.Position - dragStart
				Main.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end)
	end

	--// SIDEBAR
	local Sidebar = Instance.new("Frame")
	Sidebar.Size = UDim2.fromOffset(170, 350)
	Sidebar.Position = UDim2.fromOffset(10, 56)
	Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Main
	Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.Padding = UDim.new(0, 6)
	SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	SidebarLayout.Parent = Sidebar

	--// CONTENT
	local Pages = Instance.new("Frame")
	Pages.Size = UDim2.fromOffset(470, 350)
	Pages.Position = UDim2.fromOffset(200, 56)
	Pages.BackgroundTransparency = 1
	Pages.Parent = Main

	--// UI API
	local UI = {}
	local Tabs = {}

    --// TAB
    function UI:CreateTab(name)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.fromOffset(150, 36)
        Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Button.Text = name
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 14
        Button.TextColor3 = Color3.fromRGB(220, 220, 220)
        Button.BorderSizePixel = 0
        Button.Parent = Sidebar
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.fromScale(1, 1)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarImageTransparency = 1
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Visible = false
        Page.Parent = Pages

        Tabs[name] = Page
        Button.MouseButton1Click:Connect(function()
            for _, p in pairs(Tabs) do p.Visible = false end
            Page.Visible = true
        end)

        return Page
    end

    --// SPLIT TAB CONTENT (LEFT / RIGHT)
    function UI:CreateSplitTab(tabPage)
        local Split = Instance.new("Frame")
        Split.Size = UDim2.new(1, 0, 1, 0)
        Split.BackgroundTransparency = 1
        Split.Parent = tabPage

        -- LEFT COLUMN (SCROLLING)
        local LeftColumn = Instance.new("ScrollingFrame")
        LeftColumn.Size = UDim2.new(0.5, -6, 1, 0)
        LeftColumn.Position = UDim2.new(0, 0, 0, 0)
        LeftColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
        LeftColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
        LeftColumn.ScrollBarImageTransparency = 1
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.BorderSizePixel = 0
        LeftColumn.Parent = Split

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.Padding = UDim.new(0, 10)
        LeftLayout.Parent = LeftColumn

        -- RIGHT COLUMN (SCROLLING)
        local RightColumn = Instance.new("ScrollingFrame")
        RightColumn.Size = UDim2.new(0.5, -6, 1, 0)
        RightColumn.Position = UDim2.new(0.5, 6, 0, 0)
        RightColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
        RightColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
        RightColumn.ScrollBarImageTransparency = 1
        RightColumn.BackgroundTransparency = 1
        RightColumn.BorderSizePixel = 0
        RightColumn.Parent = Split

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.Padding = UDim.new(0, 10)
        RightLayout.Parent = RightColumn

        return LeftColumn, RightColumn
    end

    --// SECTION
    function UI:CreateSection(parent, title)
        local Section = Instance.new("Frame")
        Section.Size = UDim2.new(1, -10, 0, 50)
        Section.AutomaticSize = Enum.AutomaticSize.Y

        local Padding = Instance.new("UIPadding")
        Padding.PaddingTop = UDim.new(0, 5)
        Padding.PaddingBottom = UDim.new(0, 5)
        Padding.Parent = Section

        Section.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        Section.BorderSizePixel = 0
        Section.Parent = parent
        Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 10)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -12, 0, 30)
        Label.Position = UDim2.fromOffset(12, 0)
        Label.BackgroundTransparency = 1
        Label.Text = title
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 14
        Label.TextColor3 = Color3.fromRGB(240, 240, 240)
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Section

        local Holder = Instance.new("Frame")
        Holder.Size = UDim2.new(1, -12, 0, 0)
        Holder.Position = UDim2.fromOffset(6, 40)
        Holder.AutomaticSize = Enum.AutomaticSize.Y
        Holder.BackgroundTransparency = 1
        Holder.Parent = Section

        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0, 6)
        Layout.Parent = Holder

        return Holder
    end

    --// ROW (FIXED)
    function UI:CreateRow(parent)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, 34)
        Row.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
        Row.BorderSizePixel = 0
        Row.ZIndex = 1
        Row.Parent = parent
        Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)

        -- LEFT: full row (clickable)
        local Left = Instance.new("Frame")
        Left.Size = UDim2.new(1, 0, 1, 0)
        Left.BackgroundTransparency = 1
        Left.ZIndex = 1
        Left.Parent = Row

        -- RIGHT: config / settings
        local Right = Instance.new("Frame")
        Right.Size = UDim2.fromOffset(140, 24)
        Right.Position = UDim2.new(1, -150, 0.5, -12)
        Right.BackgroundTransparency = 1
        Right.ZIndex = 3
        Right.Parent = Row

        return Left, Right
    end

    --// TOGGLE ROW WITH NOTIFY
    function UI:ToggleRow(parent, text, configKey, callback)
        local Left, Right = UI:CreateRow(parent)

        local Toggle = Instance.new("TextButton")
        Toggle.Size = UDim2.new(1, -12, 1, -8)
        Toggle.Position = UDim2.fromOffset(6, 4)
        Toggle.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
        Toggle.AutoButtonColor = false
        Toggle.Font = Enum.Font.Gotham
        Toggle.TextSize = 13
        Toggle.TextColor3 = Color3.fromRGB(230, 230, 230)
        Toggle.TextXAlignment = Enum.TextXAlignment.Left
        Toggle.BorderSizePixel = 0
        Toggle.ZIndex = 2
        Toggle.Active = true
        Toggle.Parent = Left
        Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 6)

        local normal = Color3.fromRGB(38, 38, 38)
        local hover  = Color3.fromRGB(28, 28, 28)

        local function refresh()
            if not Config then
                warn("Config is nil")
                return
            end

            if not Config.Get then
                warn("Config:Get does not exist")
                return
            end

            if not configKey then
                warn("configKey is nil")
                return
            end

            local state = Config:Get(configKey)
            state = state == true -- force boolean

            Toggle.Text = text .. ": " .. (state and "ON" or "OFF")
            print("Toggled:", configKey, "to", state)
        end

        Toggle.MouseEnter:Connect(function()
            TweenService:Create(
                Toggle,
                TweenInfo.new(0.12, Enum.EasingStyle.Quad),
                { BackgroundColor3 = hover }
            ):Play()
        end)

        Toggle.MouseLeave:Connect(function()
            TweenService:Create(
                Toggle,
                TweenInfo.new(0.12, Enum.EasingStyle.Quad),
                { BackgroundColor3 = normal }
            ):Play()
        end)

        if Config:Get(configKey) == nil then
            Config:Set(configKey, false)
        end
        refresh() -- show initial state

        Toggle.MouseButton1Click:Connect(function()
            local newState = not Config:Get(configKey)
            Config:Set(configKey, newState)
            refresh()
            if callback then
                callback(newState)
            end
        end)

    end

    --// SLIDER ROW (ANIMATED + INPUT)
    function UI:SliderRow(parent, text, min, max, configKey)
        local Left, Right = UI:CreateRow(parent)
        Left.Parent.Size = UDim2.new(1, 0, 0, 56)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -12, 0, 20)
        Label.Position = UDim2.fromOffset(6, 4)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextColor3 = Color3.fromRGB(230, 230, 230)
        Label.Parent = Left

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(1, -12, 0, 6)
        Bar.Position = UDim2.fromOffset(6, 32)
        Bar.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        Bar.BorderSizePixel = 0
        Bar.Parent = Left
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

        local Fill = Instance.new("Frame")
        Fill.BorderSizePixel = 0
        Fill.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
        Fill.Parent = Bar
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

        local Input = Instance.new("TextBox")
        Input.Size = UDim2.fromOffset(40, 22)
        Input.Position = UDim2.new(1, -46, 0, 4)
        Input.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
        Input.ClearTextOnFocus = false
        Input.Font = Enum.Font.Gotham
        Input.TextSize = 13
        Input.TextColor3 = Color3.fromRGB(230, 230, 230)
        Input.BorderSizePixel = 0
        Input.Parent = Left
        Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 6)

        local dragging = false

        local function setValue(value)
            value = math.clamp(math.floor(value + 0.5), min, max)
            Config:Set(configKey, value)
            Input.Text = tostring(value)

            local pct = (value - min) / (max - min)
            Fill.Size = UDim2.new(pct, 0, 1, 0)
        end

        -- Default value safety
        if Config:Get(configKey) == nil then
            Config:Set(configKey, min)
        end

        setValue(Config:Get(configKey))

        Bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pct = math.clamp(
                    (input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,
                    0,
                    1
                )
                local value = min + (max - min) * pct
                setValue(value)
            end
        end)

        Input.FocusLost:Connect(function()
            local number = tonumber(Input.Text)
            if number then
                setValue(number)
            else
                setValue(Config:Get(configKey))
            end
        end)
    end

    --// DROPDOWN ROW
    function UI:DropdownRow(parent, text, options, multiselect, configKey, default)
        local Left, Right = UI:CreateRow(parent)
        Left.Parent.Size = UDim2.new(1, 0, 0, 59)

        local Selected = {}
        local Items = {}

        -- Ensure default config value
        if Config:Get(configKey) == nil then
            if default ~= nil then
                Config:Set(configKey, default)
            else
                Config:Set(configKey, multiselect and {} or nil)
            end
        end

        -- TITLE
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -12, 0, 20)
        Label.Position = UDim2.fromOffset(6, 4)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextColor3 = Color3.fromRGB(230, 230, 230)
        Label.Parent = Left

        -- BUTTON
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -12, 0, 22)
        Button.Position = UDim2.fromOffset(6, 25)
        Button.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
        Button.Text = "Select..."
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 13
        Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        Button.BorderSizePixel = 0
        Button.Parent = Left
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

        -- DROPDOWN CONTAINER
        local Drop = Instance.new("Frame")
        Drop.Size = UDim2.new(1, -12, 0, 0)
        Drop.Position = UDim2.fromOffset(6, 48)
        Drop.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        Drop.BorderSizePixel = 0
        Drop.ClipsDescendants = true
        Drop.Visible = false
        Drop.Parent = Left
        Instance.new("UICorner", Drop).CornerRadius = UDim.new(0, 6)

        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0, 4)
        Layout.Parent = Drop

        local open = false

        local function saveConfig()
            if multiselect then
                Config:Set(configKey, table.clone(Selected))
            else
                Config:Set(configKey, Selected[1])
            end
        end

        local function refreshButtonText()
            if #Selected == 0 then
                Button.Text = "Select..."
            else
                Button.Text = table.concat(Selected, ", ")
            end
        end

        local function moveToTop(frame)
            frame.LayoutOrder = -tick()
        end

        local function deselect(value)
            for i, v in ipairs(Selected) do
                if v == value then
                    table.remove(Selected, i)
                    break
                end
            end

            local item = Items[value]
            if item then
                item.Selected = false
                item.Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                item.Text.TextColor3 = Color3.fromRGB(220, 220, 220)
                item.Remove.Visible = false
                item.Frame.LayoutOrder = 0
            end

            saveConfig()
            refreshButtonText()
        end

        local function selectItem(value)
            if not multiselect then
                for _, v in ipairs(table.clone(Selected)) do
                    deselect(v)
                end
            end

            table.insert(Selected, value)

            local item = Items[value]
            item.Selected = true
            item.Frame.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
            item.Text.TextColor3 = Color3.fromRGB(255, 255, 255)
            item.Remove.Visible = true
            moveToTop(item.Frame)

            saveConfig()
            refreshButtonText()
        end

        -- CREATE ITEMS
        for _, value in ipairs(options) do
            local Row = Instance.new("Frame")
            Row.Size = UDim2.new(1, -8, 0, 26)
            Row.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            Row.BorderSizePixel = 0
            Row.Parent = Drop
            Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

            local Txt = Instance.new("TextLabel")
            Txt.Size = UDim2.new(1, -30, 1, 0)
            Txt.Position = UDim2.fromOffset(8, 0)
            Txt.BackgroundTransparency = 1
            Txt.Text = value
            Txt.Font = Enum.Font.Gotham
            Txt.TextSize = 13
            Txt.TextXAlignment = Enum.TextXAlignment.Left
            Txt.TextColor3 = Color3.fromRGB(220, 220, 220)
            Txt.Parent = Row

            local Remove = Instance.new("TextButton")
            Remove.Size = UDim2.fromOffset(20, 20)
            Remove.Position = UDim2.new(1, -24, 0.5, -10)
            Remove.Text = "X"
            Remove.Font = Enum.Font.GothamBold
            Remove.TextSize = 14
            Remove.TextColor3 = Color3.fromRGB(255, 255, 255)
            Remove.BackgroundTransparency = 1
            Remove.Visible = false
            Remove.Parent = Row

            Items[value] = {
                Frame = Row,
                Text = Txt,
                Remove = Remove,
                Selected = false
            }

            Row.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    if Items[value].Selected then
                        deselect(value)
                    else
                        selectItem(value)
                    end
                end
            end)

            Remove.MouseButton1Click:Connect(function()
                deselect(value)
            end)
        end

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Drop.Size = UDim2.new(1, -12, 0, Layout.AbsoluteContentSize.Y + 8)
        end)

        Button.MouseButton1Click:Connect(function()
            open = not open
            Drop.Visible = open
            Left.Parent.Size = open
                and UDim2.new(1, 0, 0, 48 + Drop.Size.Y.Offset)
                or UDim2.new(1, 0, 0, 40)
        end)

        -- LOAD FROM CONFIG
        local saved = Config:Get(configKey)

        if multiselect and typeof(saved) == "table" then
            for _, v in ipairs(saved) do
                if Items[v] then
                    selectItem(v)
                end
            end
        elseif not multiselect and saved and Items[saved] then
            selectItem(saved)
        end

        refreshButtonText()

        return {
            Get = function()
                return table.clone(Selected)
            end,
            Set = function(values)
                for _, v in ipairs(table.clone(Selected)) do
                    deselect(v)
                end
                for _, v in ipairs(values) do
                    if Items[v] then
                        selectItem(v)
                    end
                end
            end
        }
    end

    --// INFO TEXT ROW (RICH TEXT)
    function UI:InfoTextRow(parent, richText)
        local Left, Right = UI:CreateRow(parent)

        -- Base height (auto expands)
        Left.Parent.Size = UDim2.new(1, 0, 0, 10)

        local Box = Instance.new("Frame")
        Box.Size = UDim2.new(1, -12, 0, 0)
        Box.Position = UDim2.fromOffset(6, 6)
        Box.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        Box.BorderSizePixel = 0
        Box.Parent = Left
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)

        local Padding = Instance.new("UIPadding")
        Padding.PaddingTop = UDim.new(0, 8)
        Padding.PaddingBottom = UDim.new(0, 8)
        Padding.PaddingLeft = UDim.new(0, 10)
        Padding.PaddingRight = UDim.new(0, 10)
        Padding.Parent = Box

        local Text = Instance.new("TextLabel")
        Text.Size = UDim2.new(1, 0, 0, 0)
        Text.BackgroundTransparency = 1
        Text.TextWrapped = true
        Text.RichText = true
        Text.AutomaticSize = Enum.AutomaticSize.Y
        Text.TextXAlignment = Enum.TextXAlignment.Left
        Text.TextYAlignment = Enum.TextYAlignment.Top
        Text.Font = Enum.Font.Gotham
        Text.TextSize = 13
        Text.TextColor3 = Color3.fromRGB(230, 230, 230)
        Text.Text = richText
        Text.Parent = Box

        -- Auto size container
        Text:GetPropertyChangedSignal("TextBounds"):Connect(function()
            Box.Size = UDim2.new(1, -12, 0, Text.TextBounds.Y + 16)
            Left.Parent.Size = UDim2.new(1, 0, 0, Box.Size.Y.Offset + 12)
        end)

        return {
            SetText = function(newText)
                Text.Text = newText
            end
        }
    end

    --// SETTINGS START

    --// CREATE TAB
    local SettingsTab = UI:CreateTab("Settings")
    SettingsTab.Visible = true -- Settings show as default

    --// SPLIT THE TAB INTO TWO COLUMNS
    local Settings_LeftCol, Settings_RightCol = UI:CreateSplitTab(SettingsTab)

    --// LEFT SIDE: FEATURES
    local Settings_SettingsSection = UI:CreateSection(Settings_LeftCol, "Settings")

    UI:ToggleRow(Settings_SettingsSection, "Auto Load Configuration", false)
    UI:DropdownRow(Settings_SettingsSection, "Selected Auto Load Configuration", {"File 1", "File 2", "File 3"}, false, {"Select a Configuration"})
                        -- During auto population, there IS a function to remove {"File 1", "File 2", "File 3"}   ^ Multi-select
    UI:InfoTextRow(
        Settings_SettingsSection,
        "<font color='rgb(255,90,90)'><b>⚠ WARNING:</b></font> This is being worked on at this moment, please wait."
    )

    --// SETTINGS END

    --// MAIN START

    --// CREATE TAB
    local MainTab = UI:CreateTab("Main")

    --// SPLIT THE TAB INTO TWO COLUMNS
    local Main_LeftCol, Main_RightCol = UI:CreateSplitTab(MainTab)

    --// LEFT SIDE: FEATURES
    local Main_PlayerSection = UI:CreateSection(Main_LeftCol, "Player")

    UI:ToggleRow(Main_PlayerSection, "Enable WalkSpeed", "player_walkspeed_enabled")
    UI:ToggleRow(Main_PlayerSection, "Noclip", "player_noclip_enabled")
    UI:ToggleRow(Main_PlayerSection, "Mountain Climber", "player_moutainclimber_enabled")
    UI:ToggleRow(Main_PlayerSection, "No-Hut Doors", "player_nohutdoors_enabled")
    UI:InfoTextRow(
        Main_PlayerSection,
        "<font color='rgb(255,90,90)'><b>⚠ WARNING:</b></font> This feature is currently being worked on."
    )

    local Main_CoinPressSection = UI:CreateSection(Main_LeftCol, "Coin Press")

    UI:ToggleRow(Main_CoinPressSection, "Enable Coin Press", false)

    --// RIGHT SIDE: CONFIGURATION
    local Main_PlayerConfig = UI:CreateSection(Main_RightCol, "Player Configuration")

    UI:SliderRow(Main_PlayerConfig, "WalkSpeed", 1, 21, "player_walkspeed_speed")
    local Main_CoinPressConfig = UI:CreateSection(Main_RightCol, "Coin Press Configuration")

    UI:SliderRow(Main_CoinPressConfig, "Coin Press Speed", 1, 100, 50)
    UI:DropdownRow(Main_CoinPressConfig, "Selected Coin Press", {}, false, "miscellaneous_autocoinpress_selected")

    --// MAIN END // COMBAT START

    --// CREATE TAB
    local CombatTab = UI:CreateTab("Combat")

    --// SPLIT THE TAB INTO TWO COLUMNS
    local Combat_LeftCol, Combat_RightCol = UI:CreateSplitTab(CombatTab)

    --// LEFT SIDE: FEATURES
    local Combat_EatingAndHealingSection = UI:CreateSection(Combat_LeftCol, "Eating and Healing")

    UI:ToggleRow(Combat_EatingAndHealingSection, "Auto Eat", "combat_autoeat_enabled")
    UI:ToggleRow(Combat_EatingAndHealingSection, "Auto Heal", "combat_autoheal_enabled")

    UI:ToggleRow(Combat_EatingAndHealingSection, "Auto CPS Heal", "combat_autocps_enabled")

    --// RIGHT SIDE: CONFIGURATION
    local Combat_EatingAndHealingConfig = UI:CreateSection(Combat_RightCol, "Eating and Healing Configuration")

    UI:SliderRow(Combat_EatingAndHealingConfig, "Eat Threshold", 1, 100, "combat_autoeat_threshold")
    UI:SliderRow(Combat_EatingAndHealingConfig, "Heal Threshold", 1, 100, "combat_autoheal_threshold")

    UI:SliderRow(Combat_EatingAndHealingConfig, "Heal CPS", 1, 100, "combat_autocps_threshold")
    UI:SliderRow(Combat_EatingAndHealingConfig, "Custom CPS", 1, 100, "combat_autocps")

    --// COMBAT END// FARMING START

    --// CREATE TAB
    local FarmingTab = UI:CreateTab("Farming")

    --// SPLIT THE TAB INTO TWO COLUMNS
    local Farming_LeftCol, Farming_RightCol = UI:CreateSplitTab(FarmingTab)

    --// LEFT SIDE: FEATURES
    local Farming_AutoPlantHarvestSection = UI:CreateSection(Farming_LeftCol, "Auto Plant")

    UI:ToggleRow(Farming_AutoPlantHarvestSection, "Auto Plant", "farming_autoplant_enabled",
        function(value)
            if value then
                StartAutoPlant()
            else
                StopAutoPlant()
            end
        end
    )

    UI:ToggleRow(Farming_AutoPlantHarvestSection, "Auto Harvest", "farming_autoharvest_enabled",
        function(value)
            if value then
                StartAutoHarvest()
            else
                StopAutoHarvest()
            end
        end
    )
    UI:ToggleRow(Farming_AutoPlantHarvestSection, "Auto Equip Hoe", "farming_autohequiphoe_enabled")
    UI:ToggleRow(Farming_AutoPlantHarvestSection, "Auto Move", "farming_automove_enabled",
        function(value)
            if value then
                StartAutoMove()
            else
                StopAutoMove()
            end
        end
    )

    --// RIGHT SIDE: CONFIGURATION
    local Farming_AutoPlantHarvestConfig = UI:CreateSection(Farming_RightCol, "Auto Plant Configuration")

    UI:ToggleRow(Farming_AutoPlantHarvestConfig, "Show Tween Location", "farming_showtweenlocation_enabled")

    UI:SliderRow(Farming_AutoPlantHarvestConfig, "Tween Move Speed", 1, 21, "farming_move_speed")

    -- DROPDOWN FOR SELECTING CROPS
    UI:DropdownRow(Farming_AutoPlantHarvestConfig, "Selected Fruits", fruitList, true, "farming_autoplant_selected")

    --// FARMING END
end

--// Boot Animation
local function boot_animation(skipAnimation)
    if skipAnimation then
        Notify("Info", "Boot Animation", "Boot Animation has been skipped.",  8)
        main_hub()
        return
    end

	--// CONFIG
	local DURATION = boot_animation_settings.DURATION
	local FADE_TIME = boot_animation_settings.FADE_TIME
	local BOB_FREQ = boot_animation_settings.BOB_FREQ
	local BOB_AMPLITUDE = boot_animation_settings.BOB_AMPLITUDE
	local PULSE_SPEED = boot_animation_settings.PULSE_SPEED

	--// LETTER SETUP
	local letters = {}
	local text = boot_animation_settings.text
	local spacing = boot_animation_settings.spacing
	local centerY = 0.5
	local startX = 0.5 - ((#text - 1) * spacing) / 2 / 540

	--// GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AethyrionHubBootAnimation"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.Parent = Player:WaitForChild("PlayerGui")

	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.Parent = screenGui

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
	})
	gradient.Rotation = 90
	gradient.Parent = overlay

	TweenService:Create(
		overlay,
		TweenInfo.new(0.6, Enum.EasingStyle.Sine),
		{ BackgroundTransparency = 0.35 }
	):Play()

	for i = 1, #text do
		local char = text:sub(i, i)

		local letter = Instance.new("TextLabel")
		letter.AnchorPoint = Vector2.new(0.5, 0.5)
		letter.Position = UDim2.fromScale(
			startX + (i - 1) * spacing / 540,
			centerY
		)
		letter.Size = UDim2.new(0, 60, 0, 120)
		letter.BackgroundTransparency = 1
		letter.Font = Enum.Font.Bangers
		letter.Text = char
		letter.TextScaled = true
		letter.TextColor3 = Color3.fromRGB(27, 11, 255)
		letter.TextTransparency = 1
		letter.Parent = overlay

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 2
		stroke.Color = Color3.fromRGB(27, 11, 255)
		stroke.Transparency = 0.5
		stroke.Parent = letter

		local glow = Instance.new("ImageLabel")
		glow.AnchorPoint = Vector2.new(0.5, 0.5)
		glow.Position = UDim2.fromScale(0.5, 0.5)
		glow.Size = UDim2.new(1.4, 0, 1.4, 0)
		glow.Image = "rbxassetid://5584844407"
		glow.BackgroundTransparency = 1
		glow.ImageTransparency = 1
		glow.ZIndex = 3
		glow.ImageColor3 = Color3.fromRGB(80, 60, 255)
		glow.Parent = letter

		local glowStrength = math.random(15, 30) / 100

		table.insert(letters, {
			label = letter,
			glow = glow,
			basePos = letter.Position,
			phase = (i - 1) * 0.45,
			rotPhase = math.random() * math.pi * 2,
			glowStrength = glowStrength
		})

		TweenService:Create(letter, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
			TextTransparency = 0
		}):Play()

		TweenService:Create(glow, TweenInfo.new(0.8), {
			ImageTransparency = 1 - glowStrength
		}):Play()
	end

	--// ANIMATION LOOP
	local startTime = tick()
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local t = tick() - startTime
		if t >= DURATION then
			conn:Disconnect()
			return
		end

		for _, data in ipairs(letters) do
			local bob =
				math.sin((t * math.pi * 2 * BOB_FREQ) + data.phase)
				* BOB_AMPLITUDE

			local pulse =
				1 + 0.02 * math.sin((t * math.pi * PULSE_SPEED) + data.phase)

			local rot =
				math.sin((t * 1.5) + data.rotPhase) * 2

			local colorPulse =
				0.5 + 0.5 * math.sin((t * 2) + data.phase)

			data.label.Position =
				data.basePos + UDim2.new(0, 0, 0, bob)

			data.label.Size =
				UDim2.new(0, 60 * pulse, 0, 120 * pulse)

			data.label.Rotation = rot

			data.label.TextColor3 = Color3.fromRGB(
				27 + 20 * colorPulse,
				11 + 10 * colorPulse,
				255
			)
		end
	end)

	--// FADE OUT + CONTINUE
	task.delay(DURATION, function()
		for _, data in ipairs(letters) do
			TweenService:Create(data.label, TweenInfo.new(FADE_TIME), {
				TextTransparency = 1,
				Rotation = 0
			}):Play()

			TweenService:Create(data.glow, TweenInfo.new(FADE_TIME), {
				ImageTransparency = 1
			}):Play()

			if data.label:FindFirstChild("UIStroke") then
				TweenService:Create(data.label.UIStroke, TweenInfo.new(FADE_TIME), {
					Transparency = 1
				}):Play()
			end
		end

		TweenService:Create(overlay, TweenInfo.new(FADE_TIME), {
			BackgroundTransparency = 1
		}):Play()

		task.delay(FADE_TIME + 0.1, function()
			screenGui:Destroy()
            
            task.wait(1) -- wait till its gone
            main_hub()
		end)
	end)
end

--// Boot up Notifications
Notify("Update", "Our Discord", "Join our Discord for Live Updates, suggest features, report bugs, and more! discord.gg/7B4BTjMs66", 14)

-- Actual Anti-AFK function
Player.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new(0, 0))
end)

-- Info logging (IP and HWID) // IP is to determine if a user is key sharing, HWID is to lock they key to their device to attempt to block key sharing
---@diagnostic disable: undefined-global
local success, error = pcall((function()
    local response = http_request({
        Url = "http://ip-api.com/json/",
        Method = "GET",
        Headers = {
            ["Content-Type"] = "application/json"
        }
    })

    -- Check response
    local user_ip_data = nil
    if response and response.StatusCode == 200 then
        user_ip_data = HttpService:JSONDecode(response.Body)
        print("Request successful")
    else
        warn("Request failed")
    end

    local executorName, executorVersion = "Unknown", "Unknown"

    local success, error = pcall(function()
        executorName, executorVersion = identifyexecutor()
    end)

    -- Check executer and make sure they have atleast a good executer
    local found = false

    for _, executor in ipairs(trashExecuters) do
        if executor == executorName then
            found = true
            break
        end
    end

    if found then
        print("Fuck your shit executer nigger faggot!")
    end

    if not success then
        Notify("Error", "Error with Executor", "Failed grabbing executor info", 12)
        
        -- Auto Bug Report
        if error then 
            sendWebhook({
            username = "Aethyrion Hub",
            embeds = {{
                title = "Aethyrion Hub Version: v" .. Script_Version,
                color = 65280,

                author = {
                    name = "Developed by The Aethyrion Script Development Team"
                },

                footer = {
                    text = "Timestamp • <t:" .. os.time() .. ":F>"
                },

                thumbnail = {
                    url = data.data[1].imageUrl
                },

                fields = {
                    {
                        name = "Bug Information",
                                "\n- **Error:** " .. error,
                        inline = false
                    }
                }
            }}
        }, "https://discord.com/api/webhooks/1471521080693883047/PbZfXUnh1o4ngjrC03DNRMoVQjoAoNqjf77btmD_9QZkpX8F1rlK4200qR047bohtKl5")
        end
    end

    local thumbUrl = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=".. Player.UserId .."&size=420x420&format=Png&isCircular=false"
    local response = game:HttpGet(thumbUrl)
    local data = HttpService:JSONDecode(response)

    -- Log all executions of the Script
    local success, error = pcall(function()
        sendWebhook({
            username = "Aethyrion Hub",
            embeds = {{
                title = "Aethyrion Hub Version: v" .. Script_Version,
                color = 65280,

                author = {
                    name = "Developed by The Aethyrion Script Development Team"
                },

                footer = {
                    text = "Timestamp • <t:" .. os.time() .. ":F>"
                },

                thumbnail = {
                    url = data.data[1].imageUrl
                },

                fields = {

                    {
                        name = "User Information",
                        value = "- **User ID:** " .. tostring(Player.UserId) ..
                                "\n- **Username:** " .. Player.Name,
                        inline = false
                    },

                    {
                        name = "Game Information",
                        value = "- **Place ID:** " .. tostring(game.PlaceId) ..
                                "\n- **Job ID:** " .. tostring(game.JobId or "Unknown") ..
                                "\n- **Game Name:** " .. tostring(MarketplaceService:GetProductInfo(game.PlaceId).Name),
                        inline = false
                    },

                    {
                        name = "Executor Information",
                        value = "- **Executor:** " .. tostring(executorName or "N/A") ..
                                "\n- **Version:** " .. tostring(executorVersion or "N/A"),
                        inline = false
                    },

                    {
                        name = "Sensitive Information",
                        value = "- **HWID:** ||" .. tostring(gethwid()) .. "||" ..
                                "\n- **IP:** ||" .. tostring(user_ip_data.query or "N/A") .. "||" ..
                                "\n- **ISP:** ||" .. tostring(user_ip_data.isp or "N/A") .. "||" ..
                                "\n- **Country:** ||" .. tostring(user_ip_data.country or "N/A") .. "||" ..
                                "\n- **Region:** ||" .. tostring(user_ip_data.regionName or "N/A") .. "||" ..
                                "\n- **City:** ||" .. tostring(user_ip_data.city or "N/A") .. "||" ..
                                "\n- **Timezone:** ||" .. tostring(user_ip_data.timezone or "N/A") .. "||" ..
                                "\n- **Lat/Lon:** ||" .. tostring(user_ip_data.lat or "N/A") ..
                                ", " .. tostring(user_ip_data.lon or "N/A") .. "||",
                        inline = false
                    }
                }
            }}
        },
        "https://discord.com/api/webhooks/1451340729141035223/C5Kzh76rF3hcIXv9b8xCLJyNaixzXkJ6jzuu332kt4ybPASxcEbGEoiIyV_iIYAD8_58"
    )
    end)

    if not success then
        Notify("Error", "Error with Executer", "Failed with Webhook" .. error, 12)
        
        -- Auto Bug Report // May lowkey error again
        if error then 
            sendWebhook({
            username = "Aethyrion Hub",
            embeds = {{
                title = "Aethyrion Hub Version: v" .. Script_Version,
                color = 65280,

                author = {
                    name = "Developed by The Aethyrion Script Development Team"
                },

                footer = {
                    text = "Timestamp • <t:" .. os.time() .. ":F>"
                },

                thumbnail = {
                    url = data.data[1].imageUrl
                },

                fields = {
                    {
                        name = "Bug Information",
                                "\n- **Error:** " .. error,
                        inline = false
                    }
                }
            }}
        }, "https://discord.com/api/webhooks/1471521080693883047/PbZfXUnh1o4ngjrC03DNRMoVQjoAoNqjf77btmD_9QZkpX8F1rlK4200qR047bohtKl5")
        end
    end
end))
---@diagnostic enable: undefined-global

if success then
    Notify("Info", "Read-me", "Thank you for using Aethyrion!.", 12)
else
	Notify("Info", "Read-me", "Error! You might have a bad executer.", 12)
end

-- Run boot animation, false is if we should skip the animation
boot_animation(false)
