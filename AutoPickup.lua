--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Packets = require(ReplicatedStorage.Modules.Packets)
local ItemData = require(ReplicatedStorage.Modules.ItemData)

--// SETTINGS
local AUTO_PICKUP = false
local PICKUP_ALL = false
local PICKUP_RADIUS = 25
local ItemList = {}        -- whitelist
local SelectedItem = nil   -- selected in search list
local SHOW_AOE = false

-- Priority table
local priority = {
	["Gold"] = 1,
	["Raw Gold"] = 2,
	["Coin2"] = 3,
	["Coin"] = 4,
	["Coin Stack"] = 5
}

--// GUI
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))

-- Toggle UI Button
local ToggleUIBtn = Instance.new("TextButton")
ToggleUIBtn.Size = UDim2.new(0,120,0,30)
ToggleUIBtn.Position = UDim2.new(0,15,0,15)
ToggleUIBtn.Text = "Pickup UI"
ToggleUIBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
ToggleUIBtn.TextColor3 = Color3.new(1,1,1)
ToggleUIBtn.BorderSizePixel = 0
ToggleUIBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleUIBtn).CornerRadius = UDim.new(0,6)

-- Main Window
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,300,0,450)
Main.Position = UDim2.new(0.5,-150,0.5,-225)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,8)

-- Title Bar
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1,0,0,35)
TitleBar.BackgroundColor3 = Color3.fromRGB(28,28,28)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,8)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1,0,1,0)
Title.Text = "Auto Pickup AOE"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

-- Content Frame
local Content = Instance.new("Frame", Main)
Content.Position = UDim2.new(0,8,0,42)
Content.Size = UDim2.new(1,-16,1,-50)
Content.BackgroundTransparency = 1



local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0,6)

-- Helper to create buttons
local function CreateButton(text,color,height)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,0,0,height or 32)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	b.BorderSizePixel = 0
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
	b.Parent = Content
	return b
end

local Toggle = CreateButton("Auto Pickup: OFF", Color3.fromRGB(45,45,45))
local PickupAllButton = CreateButton("Pickup ALL: OFF", Color3.fromRGB(60,45,45))
local AOEToggleButton = CreateButton("Show AOE: OFF", Color3.fromRGB(40,55,70))

-- Radius input
local RadiusBox = Instance.new("TextBox")
RadiusBox.Size = UDim2.new(1,0,0,30)
RadiusBox.PlaceholderText = "Pickup Radius"
RadiusBox.Text = ""
RadiusBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
RadiusBox.TextColor3 = Color3.new(1,1,1)
RadiusBox.BorderSizePixel = 0
RadiusBox.Font = Enum.Font.Gotham
RadiusBox.TextSize = 13
Instance.new("UICorner", RadiusBox).CornerRadius = UDim.new(0,6)
RadiusBox.Parent = Content

-- Search box for all items
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1,0,0,30)
SearchBox.Position = UDim2.new(0,0,0,0) -- top of the content frame
SearchBox.PlaceholderText = "Search Items..."
SearchBox.Text = ""
SearchBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
SearchBox.TextColor3 = Color3.new(1,1,1)
SearchBox.BorderSizePixel = 0
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 13
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0,6)
SearchBox.Parent = Content

-- Whitelist input (optional manual add)
local ItemBox = RadiusBox:Clone()
ItemBox.PlaceholderText = "Add Item Manually"
ItemBox.Text = ""
ItemBox.Parent = Content

-- Buttons
local AddButton = CreateButton("Add Selected Item", Color3.fromRGB(45,60,45))
local RemoveButton = CreateButton("Remove Selected from Whitelist", Color3.fromRGB(60,40,40))
local ClearButton = CreateButton("Clear Whitelist", Color3.fromRGB(60,35,35))

-- Scroll list to show ALL items (searchable)
local Scroll = Instance.new("ScrollingFrame")
Scroll.Position = UDim2.new(0,0,0,35) -- below the search box
Scroll.Size = UDim2.new(1,0,0,150)
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.ScrollBarThickness = 4
Scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
Scroll.BorderSizePixel = 0
Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0,6)
Scroll.Parent = Content

local ListLayout = Instance.new("UIListLayout", Scroll)
ListLayout.Padding = UDim.new(0,3)

-- Dragging
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		Main.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end
end)
ToggleUIBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- Fetch all items into AllItems list
local AllItems = {}
for itemName, data in pairs(ItemData) do
	if type(data) == "table" then
		table.insert(AllItems, itemName)
	end
end

-- Sort AllItems by priority
table.sort(AllItems, function(a,b)
	local aPriority = priority[a]
	local bPriority = priority[b]
	if aPriority and bPriority then return aPriority < bPriority
	elseif aPriority then return true
	elseif bPriority then return false
	else return a < b
	end
end)

-- Refresh scroll list (filtered)
local function RefreshScroll(filteredList)
	for _,v in pairs(Scroll:GetChildren()) do
		if v:IsA("TextButton") then v:Destroy() end
	end

	for _,name in ipairs(filteredList) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1,-4,0,25)
		btn.Text = name
		btn.TextColor3 = Color3.new(1,1,1)
		btn.BorderSizePixel = 0
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 12
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)
		btn.Parent = Scroll

		-- Coloring logic
		if SelectedItem == name and table.find(ItemList, name) then
			btn.BackgroundColor3 = Color3.fromRGB(0,255,128) -- teal = selected + in whitelist
		elseif SelectedItem == name then
			btn.BackgroundColor3 = Color3.fromRGB(0,170,255) -- blue = selected
		elseif table.find(ItemList, name) then
			btn.BackgroundColor3 = Color3.fromRGB(0,255,0) -- green = in whitelist
		else
			btn.BackgroundColor3 = Color3.fromRGB(50,50,50) -- default gray
		end

		-- Click to select
		btn.MouseButton1Click:Connect(function()
			SelectedItem = name
			RefreshScroll(filteredList)
		end)
	end

	Scroll.CanvasSize = UDim2.new(0,0,0,ListLayout.AbsoluteContentSize.Y + 4)
end

-- Initial list display
RefreshScroll(AllItems)

-- Search filter
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local filter = SearchBox.Text:lower()
	local filtered = {}
	for _,name in ipairs(AllItems) do
		if name:lower():find(filter:lower()) then
			table.insert(filtered, name)
		end
	end
	RefreshScroll(filtered)
end)

-- Button logic
AddButton.MouseButton1Click:Connect(function()
	if SelectedItem and not table.find(ItemList, SelectedItem) then
		table.insert(ItemList, SelectedItem)
	end
end)
RemoveButton.MouseButton1Click:Connect(function()
	if SelectedItem then
		for i,v in ipairs(ItemList) do
			if v == SelectedItem then table.remove(ItemList,i); break end
		end
	end
end)
ClearButton.MouseButton1Click:Connect(function()
	ItemList = {}
end)

-- Pickup radius
RadiusBox.FocusLost:Connect(function()
	local num = tonumber(RadiusBox.Text)
	if num then PICKUP_RADIUS = num end
end)

-- Toggle buttons
AOEToggleButton.MouseButton1Click:Connect(function()
	SHOW_AOE = not SHOW_AOE
	AOEToggleButton.Text = "Show AOE: "..(SHOW_AOE and "ON" or "OFF")
end)
Toggle.MouseButton1Click:Connect(function()
	AUTO_PICKUP = not AUTO_PICKUP
	Toggle.Text = "Auto Pickup: "..(AUTO_PICKUP and "ON" or "OFF")
end)
PickupAllButton.MouseButton1Click:Connect(function()
	PICKUP_ALL = not PICKUP_ALL
	PickupAllButton.Text = "Pickup ALL: "..(PICKUP_ALL and "ON" or "OFF")
end)

-- AOE Part
local AOEPart = Instance.new("Part")
AOEPart.Shape = Enum.PartType.Cylinder
AOEPart.Anchored = true
AOEPart.CanCollide = false
AOEPart.Material = Enum.Material.Neon
AOEPart.Color = Color3.fromRGB(0,170,255)
AOEPart.Transparency = 1
AOEPart.Size = Vector3.new(1,0.2,1)
AOEPart.Parent = workspace

local function UpdateAOE()
	if not Player.Character then return end
	local root = Player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	AOEPart.Size = Vector3.new(PICKUP_RADIUS*2,0.2,PICKUP_RADIUS*2)
	AOEPart.CFrame = CFrame.new(root.Position - Vector3.new(0,root.Size.Y/2+2.8,0)) * CFrame.Angles(math.rad(90),0,0)
end

-- AUTO PICKUP LOOP
RunService.Heartbeat:Connect(function()
	UpdateAOE()
	if not Player.Character then return end
	if not workspace:FindFirstChild("Items") then return end

	local charPos = Player.Character:GetPivot().Position

	for _,item in pairs(workspace.Items:GetChildren()) do
		if not item:GetAttribute("EntityID") then continue end
		local distance = (charPos - item:GetPivot().Position).Magnitude
		if distance > PICKUP_RADIUS then continue end

		if PICKUP_ALL then
			Packets.Pickup.send(item:GetAttribute("EntityID"))
			continue
		end

		if AUTO_PICKUP and table.find(ItemList,item.Name) then
			Packets.Pickup.send(item:GetAttribute("EntityID"))
		end
	end
end)
