local validKey = "OP TOH Script by AlvaroScript"
local scriptURL = "https://raw.githubusercontent.com/AlvaroScript/TOHSCRIPT/refs/heads/main/Main%20Script/Script/Tower%20Of%20Hell%20Main.lua"

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "KeySystemUI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.5, -150, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Enter Access Key"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = frame

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0.8, 0, 0, 30)
textBox.Position = UDim2.new(0.1, 0, 0.4, 0)
textBox.PlaceholderText = "Enter Key..."
textBox.Font = Enum.Font.Gotham
textBox.TextSize = 16
textBox.Text = ""
textBox.TextColor3 = Color3.new(0, 0, 0)
textBox.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
textBox.Parent = frame

local submitButton = Instance.new("TextButton")
submitButton.Size = UDim2.new(0.5, 0, 0, 30)
submitButton.Position = UDim2.new(0.25, 0, 0.75, 0)
submitButton.Text = "Submit"
submitButton.Font = Enum.Font.GothamBold
submitButton.TextSize = 16
submitButton.BackgroundColor3 = Color3.fromRGB(60, 180, 100)
submitButton.TextColor3 = Color3.new(1, 1, 1)
submitButton.Parent = frame

local function notify(title, text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = 4
		})
	end)
end

submitButton.MouseButton1Click:Connect(function()
	local input = textBox.Text
	if input == validKey then
		notify("Success ✅", "Correct key. Loading script...")
		gui:Destroy()
		pcall(function()
			loadstring(game:HttpGet(scriptURL))()
		end)
	else
		notify("Wrong Key ❌", "You entered an invalid key!")
		wait(1)
		player:Kick("Wrong Key❌")
	end
end)
