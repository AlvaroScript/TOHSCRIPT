local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local creatorUserId = 1809018454
local creatorUsername = "gshs456f"
local allowedUsers = {
    ["gshs456f"] = true,
    ["giftdr"] = true,
}

local MAIN_SCRIPT_URL = "https://yourdomain.com/xycer_main.lua" -- Replace with your raw main script URL

local function notify(title, content)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = content,
            Duration = 4
        })
    end)
end

local function showCreatorUI()
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = "XYCER_CreatorUI"

    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 250, 0, 100)
    Frame.Position = UDim2.new(0.5, -125, 0.1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.BackgroundTransparency = 0.1

    local UICorner = Instance.new("UICorner", Frame)
    UICorner.CornerRadius = UDim.new(0, 10)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, 0, 0.5, 0)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.Text = "Creator: " .. creatorUsername
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.TextScaled = true
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold

    local CopyBtn = Instance.new("TextButton", Frame)
    CopyBtn.Size = UDim2.new(0.8, 0, 0.3, 0)
    CopyBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
    CopyBtn.Text = "Copy Creator Username"
    CopyBtn.TextScaled = true
    CopyBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    CopyBtn.TextColor3 = Color3.new(1, 1, 1)
    CopyBtn.Font = Enum.Font.Gotham

    local corner2 = Instance.new("UICorner", CopyBtn)
    corner2.CornerRadius = UDim.new(0, 6)

    CopyBtn.MouseButton1Click:Connect(function()
        setclipboard(creatorUsername)
        notify("Copied", "Username copied to clipboard!")
    end)
end

--// Check if player follows creator (via Roblox API)
local function isFollowingCreator()
    local success, result = pcall(function()
        return HttpService:JSONDecode(
            game:HttpGet(
                ("https://friends.roblox.com/v1/users/%d/following"):format(player.UserId)
            )
        )
    end)

    if success and result and result.data then
        for _, followee in ipairs(result.data) do
            if followee.id == creatorUserId then
                return true
            end
        end
    end
    return false
end

showCreatorUI()

local following = isFollowingCreator()

if player.Name == creatorUsername then
    notify("Access", "You are the creator of this script.")
    _G.XYCER_AUTHENTICATED = true
    _G.XYCER_SCRIPT_LOADED = false
    loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
elseif allowedUsers[player.Name] or following then
    notify("Access", "Admin or Follower verified. Loading...")
    _G.XYCER_AUTHENTICATED = true
    _G.XYCER_SCRIPT_LOADED = false
    loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
else
    notify("Authentication", "Authentication required to use this script.")
    _G.XYCER_AUTHENTICATED = true
    _G.XYCER_SCRIPT_LOADED = false
end
