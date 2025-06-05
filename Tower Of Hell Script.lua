-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Load Orion Library
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/GRPGaming/Key-System/refs/heads/Xycer-Hub-Script/ZusumeLib(Slider)'))()

-- Create window
local Window = OrionLib:MakeWindow({
    Name = "AlvaroScript | Tower Of Hell Script",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "ASTOH"
})

-- Tabs
local BypassTab = Window:MakeTab({ Name = "Bypass", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local MainTab = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local ModsTab = Window:MakeTab({ Name = "Player Editor", Icon = "rbxassetid://4483345998", PremiumOnly = false })

-- Variables
local originalWalkSpeed, originalJumpPower = 16, 50
local speedEnabled, jumpEnabled = false, false
local currentSpeedValue, currentJumpValue = 50, 100
local isBypassed = false
local espEnabled = false
local espObjects = {}
local godmodeEnabled, noclipEnabled = false, false

-- ESP Logic (Smoothed and Combined)
local function createOrUpdateESP(plr)
    if plr == player then return end
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local esp = espObjects[plr]
    if not esp then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESPBox"
        box.Adornee = hrp
        box.Size = Vector3.new(0, 0, 0)
        box.Color3 = Color3.new(0, 1, 0)
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Transparency = 0.5
        box.AdornCullingMode = Enum.AdornCullingMode.Never
        box.Parent = hrp

        TweenService:Create(box, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = hrp.Size + Vector3.new(2, 2, 2)
        }):Play()

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPName"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.Adornee = hrp
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Parent = hrp

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = plr.Name
        nameLabel.TextColor3 = Color3.new(0, 1, 0)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Parent = billboard

        espObjects[plr] = { box = box, name = billboard }
    else
        esp.box.Adornee = hrp
        esp.name.Adornee = hrp
    end
end

local function removeESP(plr)
    local esp = espObjects[plr]
    if esp then
        esp.box:Destroy()
        esp.name:Destroy()
        espObjects[plr] = nil
    end
end

local function updateAllESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if espEnabled then
            createOrUpdateESP(plr)
        else
            removeESP(plr)
        end
    end
end

-- Toggle ESP
MainTab:AddButton({
    Name = "Toggle Player ESP",
    Callback = function()
        espEnabled = not espEnabled
        updateAllESP()
        OrionLib:MakeNotification({
            Name = "ESP",
            Content = espEnabled and "Enabled" or "Disabled",
            Image = "rbxassetid://4483345998",
            Time = 2
        })
    end
})

-- Auto-update ESP for new players
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        if espEnabled then createOrUpdateESP(plr) end
    end)
end)

-- Character Modifiers
local function applyCharacterMods()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = speedEnabled and currentSpeedValue or originalWalkSpeed
        humanoid.JumpPower = jumpEnabled and currentJumpValue or originalJumpPower
    end
end

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    applyCharacterMods()
end)

-- Bypass Anti-Cheat
BypassTab:AddButton({
    Name = "Bypass Anti-Cheat",
    Callback = function()
        for _, v in pairs(player:WaitForChild("PlayerScripts"):GetDescendants()) do
            if v:IsA("LocalScript") and not v:IsDescendantOf(script) then
                local lowerName = v.Name:lower()
                if lowerName:find("anti") or lowerName:find("cheat") or lowerName:find("kick") or lowerName:find("ban") then
                    pcall(function() v.Disabled = true end)
                end
            end
        end
        isBypassed = true
        OrionLib:MakeNotification({
            Name = "Bypass Status",
            Content = "Potential Anti-Cheat scripts disabled!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

local statusLabel = BypassTab:AddLabel("Bypass Status: Not Bypassed")
task.spawn(function()
    while true do
        task.wait(1)
        statusLabel:Set("Bypass Status: " .. (isBypassed and "Bypassed ✅" or "Not Bypassed ❌"))
    end
end)

-- Smooth Teleport to Finish
local function getFinishPart()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Part") and v.Name:lower():find("finish") then
            return v
        end
    end
end

MainTab:AddButton({
    Name = "Teleport to Finish (Smooth)",
    Callback = function()
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart", 2)
        local finish = getFinishPart()

        if hrp and finish then
            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            local goal = { CFrame = finish.CFrame + Vector3.new(0, 3, 0) }
            local tween = TweenService:Create(hrp, tweenInfo, goal)
            tween:Play()
            tween.Completed:Wait()
            OrionLib:MakeNotification({
                Name = "Teleported!",
                Content = "Smooth teleport complete.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Error!",
                Content = "Finish part not found.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end
})

-- Speed Hack
ModsTab:AddToggle({
    Name = "Speed Hack",
    Default = false,
    Callback = function(enabled)
        speedEnabled = enabled
        applyCharacterMods()
        OrionLib:MakeNotification({ Name = "Speed Hack", Content = enabled and "Enabled!" or "Disabled!", Image = "rbxassetid://4483345998", Time = 2 })
    end
})
ModsTab:AddSlider({
    Name = "WalkSpeed Value",
    Min = 16, Max = 200, Default = 50, Increment = 1,
    ValueName = "Speed",
    Callback = function(val)
        currentSpeedValue = val
        if speedEnabled then applyCharacterMods() end
    end
})

-- Jump Hack
ModsTab:AddToggle({
    Name = "Jump Hack",
    Default = false,
    Callback = function(enabled)
        jumpEnabled = enabled
        applyCharacterMods()
        OrionLib:MakeNotification({ Name = "Jump Hack", Content = enabled and "Enabled!" or "Disabled!", Image = "rbxassetid://4483345998", Time = 2 })
    end
})
ModsTab:AddSlider({
    Name = "JumpPower Value",
    Min = 50, Max = 500, Default = 100, Increment = 5,
    ValueName = "Power",
    Callback = function(val)
        currentJumpValue = val
        if jumpEnabled then applyCharacterMods() end
    end
})

-- Godmode
local function toggleGodmode(enable)
    godmodeEnabled = enable
    local function apply()
        local char = player.Character or player.CharacterAdded:Wait()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = hum.MaxHealth
            hum:GetPropertyChangedSignal("Health"):Connect(function()
                if godmodeEnabled then hum.Health = hum.MaxHealth end
            end)
        end
    end
    apply()
    player.CharacterAdded:Connect(function()
        if godmodeEnabled then task.wait(0.5) apply() end
    end)
end

ModsTab:AddToggle({
    Name = "Godmode",
    Default = false,
    Callback = function(state)
        toggleGodmode(state)
        OrionLib:MakeNotification({ Name = "Godmode", Content = state and "Enabled" or "Disabled", Time = 2 })
    end
})

-- Noclip
game:GetService("RunService").Stepped:Connect(function()
    if noclipEnabled then
        local char = player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

ModsTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(state)
        noclipEnabled = state
        OrionLib:MakeNotification({ Name = "Noclip", Content = state and "Enabled" or "Disabled", Time = 2 })
    end
})

-- Init UI
OrionLib:Init()
