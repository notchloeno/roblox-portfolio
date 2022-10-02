local RunService = game:GetService("RunService")
local maxRotation = math.rad(12)
local rate = 70
local connection

local Flowers = {}

function Flowers.tween(flowers)
	local t = 0
	connection = RunService.Heartbeat:Connect(function(dt)
		--local offset = 0 --math.random(0,2)
		local theta = math.rad(t)
		t += dt*rate

		for i, flower in ipairs(flowers) do
			--if i%3 == offset then
			local rotationCFrame = CFrame.fromOrientation(maxRotation*math.sin(theta+i), maxRotation*math.sin(theta+2*i), maxRotation*math.sin(theta+3*i))
			local pointCFrame = CFrame.new((flower.PrimaryPart.CFrame:ToWorldSpace(CFrame.new(0,-flower.PrimaryPart.Size.Y/2,0))).Position)*rotationCFrame
			local newCFrame = pointCFrame:ToWorldSpace(CFrame.new(0,flower.PrimaryPart.Size.Y/2,0))
			flower.PrimaryPart.CFrame = newCFrame
			--end
		end
	end)
end

function Flowers.setup()
	local flowers = {}

	for i, flower in ipairs(workspace.AFY.Assets.Grass:GetChildren()) do
		if flower.Name:match("Giant") then
			flowers[#flowers+1] = flower
		end
	end

	Flowers.tween(flowers)
end

function Flowers.stop()
	connection = connection and connection:Disconnect()
end

return Flowers