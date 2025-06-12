if not game:IsLoaded() then
    game.Loaded:Wait()
end

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local allowedPlaceIds = {
    [1962086868] = true, -- Tower of Hell
    [3582763398] = true, -- Tower of Hell Pro
    [5253186791] = true  -- Tower of Hell Appeals
}

local currentPlaceId = game.PlaceId

local function loadMyScript()
    print("✅ Game ID verified. Loading your script...")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AlvaroScript/TOHSCRIPT/refs/heads/main/Main%20Script/Key/Tower%20Of%20Hell%20Key.lua"))()
end

local function showTeleportUI()
    print("❌ Invalid Game ID. Showing teleport UI.")

    local player = Players.LocalPlayer
    local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    screenGui.Name = "TeleportUI"

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.1

    local uicorner = Instance.new("UICorner", frame)
    uicorner.CornerRadius = UDim.new(0, 12)

    local layout = Instance.new("UIListLayout", frame)
    layout.Padding = UDim.new(0, 10)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center

    local function makeButton(text, placeId)
        local button = Instance.new("TextButton", frame)
        button.Size = UDim2.new(0, 200, 0, 40)
        button.Text = text
        button.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 16

        local btnCorner = Instance.new("UICorner", button)
        btnCorner.CornerRadius = UDim.new(0, 8)

        button.MouseButton1Click:Connect(function()
            TeleportService:Teleport(placeId, player)
        end)
    end

    makeButton("Teleport to Tower Of Hell", 1962086868)
    makeButton("Teleport to Tower Of Hell Pro", 3582763398)
end

if allowedPlaceIds[currentPlaceId] then
    loadMyScript()
else
    showTeleportUI()
end
