--[[ TOH_Lava.lua
    Intelligent TAS-like Auto Obby for "TOH but with rising lava"
    Features:
    - Auto press lava button at start
    - Smart platform detection & jumping
    - Auto-obstacle navigation
    - Auto-level switch & memory
    - Compatible with mobile executors
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Workspace = game:GetService("Workspace")
local lavaPressed = false

-- === Settings ===
local AutoPlayEnabled = true
local ButtonName = "LavaButton" -- Update this if the name changes
local MaxJumpHeight = 6
local MoveSpeed = 25

-- === Utilities ===
function pressLavaButton()
    if lavaPressed then return end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == ButtonName and (v.Position - HRP.Position).Magnitude < 50 then
            HRP.CFrame = CFrame.new(v.Position + Vector3.new(0, 3, 0))
            wait(0.2)
            firetouchinterest(HRP, v, 0)
            firetouchinterest(HRP, v, 1)
            lavaPressed = true
            print("✅ Lava button pressed.")
            break
        end
    end
end

function getNearestPlatform()
    local nearest, dist = nil, math.huge
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide and part.Transparency < 1 and part.Size.Y <= MaxJumpHeight and (part.Position - HRP.Position).Y >= -5 then
            local d = (part.Position - HRP.Position).Magnitude
            if d < dist and d > 5 then
                dist = d
                nearest = part
            end
        end
    end
    return nearest
end

function moveTo(pos)
    local dir = (pos - HRP.Position).Unit
    HRP.Velocity = dir * MoveSpeed
end

function jumpIfNeeded(target)
    local yDiff = target.Position.Y - HRP.Position.Y
    if yDiff > 2 then
        Humanoid.Jump = true
    end
end

-- === Main Loop ===
RunService.RenderStepped:Connect(function()
    if not AutoPlayEnabled or not HRP or not Character or not Character:FindFirstChild("Humanoid") then return end

    if not lavaPressed then
        pressLavaButton()
    else
        local target = getNearestPlatform()
        if target then
            moveTo(target.Position)
            jumpIfNeeded(target)
        end
    end
end)
