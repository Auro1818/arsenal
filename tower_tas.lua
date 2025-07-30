local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local enabled = true
local jumpPower = 50
local speed = 15

-- Tự bật TAS khi spawn lại
LocalPlayer.CharacterAdded:Connect(function(char)
	Character = char
	HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
	Humanoid = char:WaitForChild("Humanoid")
end)

-- Phát hiện platform phía trước
function getNextPlatform()
	local ray = RaycastParams.new()
	ray.FilterType = Enum.RaycastFilterType.Blacklist
	ray.FilterDescendantsInstances = {Character}

	local origin = HumanoidRootPart.Position
	local direction = HumanoidRootPart.CFrame.LookVector * 5 + Vector3.new(0, -2, 0)
	local result = workspace:Raycast(origin, direction, ray)

	if result and result.Instance then
		return result.Position
	end
	return nil
end

-- Di chuyển đến platform phía trước
function moveTo(pos)
	local direction = (pos - HumanoidRootPart.Position).Unit
	HumanoidRootPart.Velocity = direction * speed + Vector3.new(0, HumanoidRootPart.Velocity.Y, 0)
end

-- Kiểm tra cần nhảy
function shouldJump(pos)
	local vertical = pos.Y - HumanoidRootPart.Position.Y
	return vertical > 2
end

-- TAS loop
RunService.RenderStepped:Connect(function()
	if not enabled or not Character or not HumanoidRootPart then return end

	local nextPos = getNextPlatform()
	if nextPos then
		moveTo(nextPos)
		if shouldJump(nextPos) then
			Humanoid.Jump = true
		end
	end
end)

print("✅ Tower of Hell TAS started.")
