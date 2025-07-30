-- Tower of Hell TAS Auto Script (TAS Smart)
-- Repo: https://github.com/Auro1818/arsenal/
-- Compatible with Mobile Executor

if not game.PlaceId == 1962086868 then
    return warn("Not Tower of Hell!")
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 300)
Frame.Position = UDim2.new(0.02, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", Frame)
title.Text = "Tower TAS"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20

local autoRun = false
local toggleButton = Instance.new("TextButton", Frame)
toggleButton.Size = UDim2.new(1, -20, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 50)
toggleButton.Text = "Auto Run: OFF"
toggleButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.MouseButton1Click:Connect(function()
    autoRun = not autoRun
    toggleButton.Text = "Auto Run: " .. (autoRun and "ON" or "OFF")
end)

-- Auto Jump / Pathfinding
function smartMove()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local root = character.HumanoidRootPart
    local platforms = workspace:FindFirstChild("tower"):GetDescendants()

    local checkpoints = {}
    for _, part in ipairs(platforms) do
        if part:IsA("BasePart") and part.Size.Y < 2 then
            table.insert(checkpoints, part.Position + Vector3.new(0, 5, 0))
        end
    end

    table.sort(checkpoints, function(a, b)
        return a.Y < b.Y
    end)

    for _, pos in ipairs(checkpoints) do
        if not autoRun then break end
        local dist = (root.Position - pos).magnitude
        local tween = TweenService:Create(root, TweenInfo.new(dist/25, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
        tween:Play()
        tween.Completed:Wait()
    end
end

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    game.VirtualInputManager:SendKeyEvent(true, "Space", false, game)
end)

-- Ghost Mode toggle
local ghost = false
local ghostBtn = Instance.new("TextButton", Frame)
ghostBtn.Size = UDim2.new(1, -20, 0, 30)
ghostBtn.Position = UDim2.new(0, 10, 0, 90)
ghostBtn.Text = "Ghost Mode: OFF"
ghostBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
ghostBtn.TextColor3 = Color3.new(1,1,1)
ghostBtn.MouseButton1Click:Connect(function()
    ghost = not ghost
    ghostBtn.Text = "Ghost Mode: " .. (ghost and "ON" or "OFF")
    local char = LocalPlayer.Character
    if char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = not ghost
            end
        end
    end
end)

-- Loop
RunService.Heartbeat:Connect(function()
    if autoRun then
        smartMove()
    end
end)

print("✅ Tower of Hell TAS Loaded")
