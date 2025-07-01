--⚙️ CONFIG:
local CFG = {
    AimPart = "Head",
    ESP = true,
    SilentAim = true,
    WallBang = true
}
getgenv().CFG = CFG

--🧠 AUTO GAME CHECK:
if game.PlaceId ~= 286090429 then
    warn("❌ This script only works in Arsenal!")
    return
end

--📢 DEBUG LOG:
local function log(msg)
    print("[ArsrnalCheat] "..msg)
end

--🛡️ ANTI-BAN BASIC:
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" then
        log("Blocked Kick attempt!")
        return
    end
    return oldNamecall(self, ...)
end)
hookfunction(game:GetService("Players").LocalPlayer.Kick, function()
    log("Blocked local Kick!")
    return
end)

--🧱 HOOK WALL CHECK (Raycast):
local oldRaycast = workspace.Raycast
workspace.__raycast = oldRaycast
workspace.Raycast = function(self, origin, direction, params)
    if getgenv().CFG.WallBang then
        params.FilterType = Enum.RaycastFilterType.Blacklist
        params.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
    end
    return oldRaycast(self, origin, direction, params)
end

--🧍 ESP TEXT (2D NAMETAG):
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function createTextESP(player)
    if player == LocalPlayer or not CFG.ESP then return end
    local char = player.Character
    if not char or char:FindFirstChild("ESPName") then return end

    local bill = Instance.new("BillboardGui")
    bill.Name = "ESPName"
    bill.Size = UDim2.new(0, 100, 0, 20)
    bill.Adornee = char:WaitForChild("Head")
    bill.AlwaysOnTop = true
    bill.Parent = char

    local label = Instance.new("TextLabel", bill)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = player.Name
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true

    log("ESP added for "..player.Name)
end

for _,p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function() task.wait(1); createTextESP(p) end)
        if p.Character then createTextESP(p) end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(1); createTextESP(p) end)
end)

--🎯 SILENTAIM HOOK:
local Camera = workspace.CurrentCamera
local function getClosestTarget()
    local target, dist = nil, math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(CFG.AimPart) then
            local pos = p.Character[CFG.AimPart].Position
            local d = (Camera.CFrame.Position - pos).Magnitude
            if d < dist then
                dist = d
                target = p
            end
        end
    end
    return target
end

local oldNC = hookmetamethod(game, "__namecall", function(self,...)
    local method = getnamecallmethod()
    local args = {...}
    if CFG.SilentAim and method == "FindPartOnRayWithIgnoreList" and self == workspace then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(CFG.AimPart) then
            local origin = Camera.CFrame.Position
            local direction = (target.Character[CFG.AimPart].Position - origin).Unit * 500
            args[1] = Ray.new(origin, direction)
            log("SilentAim shot at: "..target.Name)
            return oldNC(self, unpack(args))
        end
    end
    return oldNC(self, ...)
end)

--📋 UI MENU:
local UIS = game:GetService("UserInputService")
local CG = game:GetService("CoreGui")

local GUI = Instance.new("ScreenGui", CG)
GUI.Name = "ArsenalCheatUI"

local Frame = Instance.new("Frame", GUI)
Frame.Size = UDim2.new(0, 160, 0, 150)
Frame.Position = UDim2.new(0, 50, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.2
Frame.Active = true
Frame.Draggable = true

local layout = Instance.new("UIListLayout", Frame)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function makeToggle(name, key)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0,5,0,5)
    btn.Text = name.." [ON]"
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13

    btn.MouseButton1Click:Connect(function()
        CFG[key] = not CFG[key]
        btn.Text = name.." ["..(CFG[key] and "ON" or "OFF").."]"
        log("Toggled "..name.." → "..tostring(CFG[key]))
    end)
end

makeToggle("ESP", "ESP")
makeToggle("SilentAim", "SilentAim")
makeToggle("WallBang", "WallBang")

-- Nút mở menu:
local toggleBtn = Instance.new("TextButton", GUI)
toggleBtn.Text = "☰"
toggleBtn.Size = UDim2.new(0, 40, 0, 40)
toggleBtn.Position = UDim2.new(0, 0, 0.5, -20)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 20
toggleBtn.ZIndex = 5

toggleBtn.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        Frame.Visible = not Frame.Visible
    end
end)

--✅ DONE!
log("Arsenal cheat loaded ✅")
