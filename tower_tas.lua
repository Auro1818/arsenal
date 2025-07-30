-- Tower of Hell Smart TAS Script (Auto-run + Pathfinding + Ghost)
-- Phù hợp với mobile executor, tải script lên GitHub theo đường dẫn cố định

-- Wait until map tower sections fully load
repeat task.wait(0.1) until workspace:FindFirstChild("tower") and workspace.tower:FindFirstChild("Sections")

local Players      = game:GetService("Players")
local LocalPlayer  = Players.LocalPlayer
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

if game.PlaceId ~= 1962086868 then
    warn("Not Tower of Hell. Stopping script.")
    return
end

-- GUI setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TowerTASGui"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 260)
frame.Position = UDim2.new(0.02, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

local function btn(text, y, fn)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1, -20, 0, 30)
    b.Position = UDim2.new(0, 10, 0, y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(60,60,60)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.MouseButton1Click:Connect(fn)
    return b
end

local autoEnabled = false
local ghostEnabled = false
local lastSafePos = nil

local lblStatus = Instance.new("TextLabel", frame)
lblStatus.Size = UDim2.new(1, -20, 0, 30)
lblStatus.Position = UDim2.new(0,10,0,220)
lblStatus.BackgroundTransparency = 1
lblStatus.TextColor3 = Color3.new(1,1,1)
lblStatus.Text = "Status: OFF"
lblStatus.TextSize = 16
lblStatus.Font = Enum.Font.Gotham

local btnAuto = btn("Auto: OFF", 10, function()
    autoEnabled = not autoEnabled
    btnAuto.Text = "Auto: " .. (autoEnabled and "ON" or "OFF")
    lblStatus.Text = autoEnabled and "Status: RUNNING" or "Status: PAUSED"
end)

local btnGhost = btn("Ghost Mode: OFF", 50, function()
    ghostEnabled = not ghostEnabled
    btnGhost.Text = "Ghost: " .. (ghostEnabled and "ON" or "OFF")
end)

-- Pathfinding logic
local function getClosestPlatform()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local pool = {}
    for _, part in ipairs(workspace.tower.Sections:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide and not part:IsDescendantOf(char) then
            local vec = part.Position - root.Position
            -- choose platform within range and upward
            if vec.Y > -5 and vec.Y < 20 and vec.Magnitude < 50 then
                table.insert(pool, {p = part, d = vec.Magnitude})
            end
        end
    end
    table.sort(pool, function(a,b) return a.d < b.d end)
    return pool[1] and pool[1].p or nil
end

RunService.Heartbeat:Connect(function()
    if not autoEnabled then return end
    pcall(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        -- Ghost mode
        if ghostEnabled then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end

        -- Reset if falling
        if root.Position.Y < -10 then
            if lastSafePos then
                root.CFrame = CFrame.new(lastSafePos + Vector3.new(0,5,0))
            else
                LocalPlayer:LoadCharacter()
            end
            return
        end

        -- Platform detection
        local plat = getClosestPlatform()
        if plat then
            lastSafePos = root.Position
            local target = plat.Position + Vector3.new(0,3,0)
            local dist = (root.Position - target).Magnitude
            local tween = TweenService:Create(root, TweenInfo.new(dist / 25, Enum.EasingStyle.Linear), {CFrame = CFrame.new(target)})
            tween:Play()
            tween.Completed:Wait()
        else
            -- no platform, auto jump
            char.Humanoid.Jump = true
        end
    end)
end)

print("Tower TAS Smart script loaded.")
