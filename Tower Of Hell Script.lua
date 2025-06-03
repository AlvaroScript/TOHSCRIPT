-- Load Orion Library
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/GRPGaming/Key-System/refs/heads/Xycer-Hub-Script/ZusumeLib(Slider)'))()

-- Create window
local Window = OrionLib:MakeWindow({
    Name = "AlvaroScript | Tower Of Hell Script",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "ASTOH"
})

-- Bypass Tab
local BypassTab = Window:MakeTab({
    Name = "Bypass",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Main Tab
local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Player Editor Tab
local ModsTab = Window:MakeTab({
    Name = "Player Editor Tab",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Variables
local originalWalkSpeed = 16
local originalJumpPower = 50
local speedEnabled = false
local jumpEnabled = false
local invincibleEnabled = false
local currentSpeedValue = 50
local currentJumpValue = 100
local antiVoidY = -20

-- Teleport to Finish Button
Tab:AddButton({
    Name = "Teleport to Finish",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local destination = game.workspace:FindFirstChild("tower")
            and game.workspace.tower:FindFirstChild("sections")
            and game.workspace.tower.sections:FindFirstChild("finish")
            and game.workspace.tower.sections.finish:FindFirstChild("exit")
            and game.workspace.tower.sections.finish.exit:FindFirstChild("ParticleBrick")

        if hrp and destination then
            hrp.CFrame = destination.CFrame + Vector3.new(0, 5, 0)
            OrionLib:MakeNotification({
                Name = "Teleported!",
                Content = "You are now at the finish!",
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

-- Speed Hack Toggle
ModsTab:AddToggle({
    Name = "Speed Hack",
    Default = false,
    Callback = function(enabled)
        speedEnabled = enabled
        local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = enabled and currentSpeedValue or originalWalkSpeed
            OrionLib:MakeNotification({
                Name = "Speed Hack",
                Content = enabled and "Speed hack enabled!" or "Speed hack disabled!",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
        end
    end
})

-- Speed Slider
ModsTab:AddSlider({
    Name = "WalkSpeed Value",
    Min = 16,
    Max = 200,
    Default = 50,
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        currentSpeedValue = value
        if speedEnabled then
            local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end
})

-- Jump Hack Toggle
ModsTab:AddToggle({
    Name = "Jump Hack",
    Default = false,
    Callback = function(enabled)
        jumpEnabled = enabled
        local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = enabled and currentJumpValue or originalJumpPower
            OrionLib:MakeNotification({
                Name = "Jump Hack",
                Content = enabled and "Jump hack enabled!" or "Jump hack disabled!",
                Image = "rbxassetid://4483345998",
                Time = 2
            })
        end
    end
})

-- JumpPower Slider
ModsTab:AddSlider({
    Name = "JumpPower Value",
    Min = 50,
    Max = 500,
    Default = 100,
    Increment = 5,
    ValueName = "Power",
    Callback = function(value)
        currentJumpValue = value
        if jumpEnabled then
            local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = value
            end
        end
    end
})

-- Restore on Respawn
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    task.wait(0.5)
    if speedEnabled then
        humanoid.WalkSpeed = currentSpeedValue
    end
    if jumpEnabled then
        humanoid.JumpPower = currentJumpValue
    end
end)

-- Bypass Button
BypassTab:AddButton({
    Name = "Show Bypass UI",
    Callback = function()
        local uiVisible = true

        local uiFrame = Instance.new("Frame")
        uiFrame.Size = UDim2.new(0, 200, 0, 100)
        uiFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
        uiFrame.BackgroundColor3 = Color3.new(0, 0, 0)
        uiFrame.Visible = true
        uiFrame.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(0, 100, 0, 50)
        toggleButton.Position = UDim2.new(0.5, -50, 0, 0)
        toggleButton.Text = "Toggle UI"
        toggleButton.Parent = uiFrame

        toggleButton.MouseButton1Click:Connect(function()
            uiVisible = not uiVisible
            uiFrame.Visible = uiVisible
        end)

        local dragging = false
        local dragInput
        local dragStart
        local startPos

        local function updateInput(input)
            local delta = input.Position - dragStart
            uiFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end

        uiFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = uiFrame.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        uiFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)

        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                updateInput(input)
            end
        end)
    end
})

-- Initialize UI
OrionLib:Init()
