--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStore = game:GetService("DataStoreService"):GetDataStore("KeySystemStore")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

--// Random Remote Name
local function generateRandomName(length)
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	local name = ""
	for i = 1, length do
		name = name .. chars:sub(math.random(1, #chars), math.random(1, #chars))
	end
	return name
end

local remoteName = generateRandomName(12)
local KeyRemote = Instance.new("RemoteFunction")
KeyRemote.Name = remoteName
KeyRemote.Parent = ReplicatedStorage

--// Server-side key
local validKey = "OP TOH Script by AlvaroScript" -- change this to your desired key

--// Handle client submission
KeyRemote.OnServerInvoke = function(player, submittedKey)
	if submittedKey == validKey then
		pcall(function()
			DataStore:SetAsync(tostring(player.UserId), true)
		end)
		return true
	else
		player:Kick("Wrong key")
		return false
	end
end

--// Verify on join
Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("KeyRemoteName", remoteName)
end)

--// Client-side UI (StarterPlayerScripts)
if not game:IsLoaded() then game.Loaded:Wait() end

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Check saved key
local success, hasKey = pcall(function()
	return DataStore:GetAsync(tostring(player.UserId))
end)

if success and hasKey then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/AlvaroScript/TOHSCRIPT/refs/heads/main/Tower%20Of%20Hell%20Main.lua"))()
	return
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KeySystemUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

screenGui:GetPropertyChangedSignal("Parent"):Connect(function()
	if not screenGui:IsDescendantOf(PlayerGui) then
		player:Kick("Tampering with UI is not allowed.")
	end
end)

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.5, -150, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Enter Key to Continue"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = frame

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0.8, 0, 0, 30)
textBox.Position = UDim2.new(0.1, 0, 0.4, 0)
textBox.PlaceholderText = "Enter Key..."
textBox.Text = ""
textBox.Font = Enum.Font.Gotham
textBox.TextSize = 16
textBox.TextColor3 = Color3.new(0, 0, 0)
textBox.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
textBox.Parent = frame

local submitButton = Instance.new("TextButton")
submitButton.Size = UDim2.new(0.5, 0, 0, 30)
submitButton.Position = UDim2.new(0.25, 0, 0.75, 0)
submitButton.Text = "Submit"
submitButton.Font = Enum.Font.GothamBold
submitButton.TextSize = 16
submitButton.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
submitButton.TextColor3 = Color3.new(1, 1, 1)
submitButton.Parent = frame

local function waitForAttribute(attName)
	while player:GetAttribute(attName) == nil do task.wait() end
	return player:GetAttribute(attName)
end

submitButton.MouseButton1Click:Connect(function()
	local key = textBox.Text
	local remoteName = waitForAttribute("KeyRemoteName")
	local remote = ReplicatedStorage:FindFirstChild(remoteName)
	if remote then
		local success = remote:InvokeServer(key)
		if success then
			pcall(function()
				DataStore:SetAsync(tostring(player.UserId), true)
			end)
			screenGui:Destroy()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/AlvaroScript/TOHSCRIPT/refs/heads/main/Tower%20Of%20Hell%20Main.lua"))()
		end
	end
end)

-- Auto-destroy UI and load script if key validated post-load
spawn(function()
	while screenGui and screenGui.Parent do
		task.wait(1)
		local success, hasKey = pcall(function()
			return DataStore:GetAsync(tostring(player.UserId))
		end)
		if success and hasKey then
			screenGui:Destroy()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/AlvaroScript/TOHSCRIPT/refs/heads/main/Tower%20Of%20Hell%20Main.lua"))()
		end
	end
end)
