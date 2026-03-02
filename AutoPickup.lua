--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--// PLAYER
local Player = Players.LocalPlayer

--// MODULES
local Packets = require(ReplicatedStorage.Modules.Packets)

--// SETTINGS
local AUTO_PICKUP = false
local PICKUP_ALL = false
local PICKUP_RADIUS = 25
local ItemList = {}
local SelectedItem = nil

--// GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BetterAutoPickupGUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- Toggle Show Button (Always Visible)
local ShowButton = Instance.new("TextButton")
ShowButton.Size = UDim2.new(0,120,0,35)
ShowButton.Position = UDim2.new(0,15,0,15)
ShowButton.Text = "Open Pickup UI"
ShowButton.BackgroundColor3 = Color3.fromRGB(35,35,35)
ShowButton.TextColor3 = Color3.new(1,1,1)
ShowButton.Parent = ScreenGui
ShowButton.BorderSizePixel = 0

-- Main Window
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,300,0,420)
Main.Position = UDim2.new(0.5,-150,0.5,-210)
Main.BackgroundColor3 = Color3.fromRGB(22,22,22)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui

-- Corner
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)

-- Title Bar
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1,0,0,34)
TitleBar.BackgroundColor3 = Color3.fromRGB(30,30,30)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1,0,1,0)
Title.Text = "Auto Pickup"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- Close Button
local CloseButton = Instance.new("TextButton", TitleBar)
CloseButton.Size = UDim2.new(0,40,1,0)
CloseButton.Position = UDim2.new(1,-40,0,0)
CloseButton.Text = "X"
CloseButton.BackgroundColor3 = Color3.fromRGB(60,30,30)
CloseButton.TextColor3 = Color3.new(1,1,1)
CloseButton.BorderSizePixel = 0
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0,8)

-- Content Container
local Content = Instance.new("Frame", Main)
Content.Position = UDim2.new(0,8,0,42)
Content.Size = UDim2.new(1,-16,1,-50)
Content.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0,8)

-- Button Creator
local function CreateButton(text,color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,0,0,28)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	b.BorderSizePixel = 0
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	b.Parent = Content
	return b
end

-- Toggle Buttons
local Toggle = CreateButton("Auto Pickup: OFF", Color3.fromRGB(45,45,45))
local PickupAllButton = CreateButton("Pickup ALL: OFF", Color3.fromRGB(60,45,45))

-- Radius Box
local RadiusBox = Instance.new("TextBox")
RadiusBox.Size = UDim2.new(1,0,0,30)
RadiusBox.PlaceholderText = "Pickup Radius"
RadiusBox.Text = ""
RadiusBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
RadiusBox.TextColor3 = Color3.new(1,1,1)
RadiusBox.BorderSizePixel = 0
RadiusBox.Font = Enum.Font.Gotham
RadiusBox.TextSize = 14
Instance.new("UICorner", RadiusBox).CornerRadius = UDim.new(0,8)
RadiusBox.Parent = Content

-- Item Box
local ItemBox = RadiusBox:Clone()
ItemBox.PlaceholderText = "Item Name"
ItemBox.Parent = Content

local AddButton = CreateButton("Add Item", Color3.fromRGB(45,60,45))
local RemoveButton = CreateButton("Remove Selected", Color3.fromRGB(60,40,40))
local ClearButton = CreateButton("Clear List", Color3.fromRGB(60,35,35))

-- Scroll List
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1,0,0,115)
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.ScrollBarThickness = 5
Scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)
Scroll.BorderSizePixel = 0
Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0,8)
Scroll.Parent = Content

local ListLayout = Instance.new("UIListLayout", Scroll)
ListLayout.Padding = UDim.new(0,4)

-- Dragging
local dragging, dragInput, dragStart, startPos

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
		Main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- Show / Hide
ShowButton.MouseButton1Click:Connect(function()
	Main.Visible = true
end)

CloseButton.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

-- Refresh List
local function RefreshList()
	for _,v in pairs(Scroll:GetChildren()) do
		if v:IsA("TextButton") then v:Destroy() end
	end
	
	for _,name in ipairs(ItemList) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1,-4,0,30)
		btn.Text = name
		btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
		btn.TextColor3 = Color3.new(1,1,1)
		btn.BorderSizePixel = 0
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 13
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
		btn.Parent = Scroll
		
		btn.MouseButton1Click:Connect(function()
			SelectedItem = name
		end)
	end
	
	task.wait()
	Scroll.CanvasSize = UDim2.new(0,0,0,ListLayout.AbsoluteContentSize.Y + 5)
end

-- Button Logic
Toggle.MouseButton1Click:Connect(function()
	AUTO_PICKUP = not AUTO_PICKUP
	Toggle.Text = "Auto Pickup: "..(AUTO_PICKUP and "ON" or "OFF")
end)

PickupAllButton.MouseButton1Click:Connect(function()
	PICKUP_ALL = not PICKUP_ALL
	PickupAllButton.Text = "Pickup ALL: "..(PICKUP_ALL and "ON" or "OFF")
end)

RadiusBox.FocusLost:Connect(function()
	local num = tonumber(RadiusBox.Text)
	if num then PICKUP_RADIUS = num end
end)

AddButton.MouseButton1Click:Connect(function()
	if ItemBox.Text ~= "" then
		table.insert(ItemList, ItemBox.Text)
		ItemBox.Text = ""
		RefreshList()
	end
end)

RemoveButton.MouseButton1Click:Connect(function()
	if not SelectedItem then return end
	for i,v in ipairs(ItemList) do
		if v == SelectedItem then
			table.remove(ItemList,i)
			break
		end
	end
	SelectedItem = nil
	RefreshList()
end)

ClearButton.MouseButton1Click:Connect(function()
	ItemList = {}
	SelectedItem = nil
	RefreshList()
end)

-- Whitelist Check
local function IsWhitelisted(name)
	for _,v in ipairs(ItemList) do
		if v:lower() == name:lower() then
			return true
		end
	end
	return false
end

-- Auto Pickup Loop
RunService.Heartbeat:Connect(function()
	if not Player.Character then return end
	if not workspace:FindFirstChild("Items") then return end
	
	local charPos = Player.Character:GetPivot().Position
	
	for _,item in pairs(workspace.Items:GetChildren()) do
		local entityID = item:GetAttribute("EntityID")
		if not entityID then continue end
		
		local distance = (charPos - item:GetPivot().Position).Magnitude
		if distance > PICKUP_RADIUS then continue end
		
		if PICKUP_ALL or AUTO_PICKUP or IsWhitelisted(item.Name) then
			Packets.Pickup.send(entityID)
		end
	end
end)

RefreshList()
