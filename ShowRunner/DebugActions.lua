local DebugActions = {}

-- Services
local Players = game:GetService("Players")

-- Functions

-- Teleports all players to the target part
function DebugActions.TeleportToPart(targetPart)
    print("DebugActions.TeleportToPart")
    for _, plyr in ipairs(Players:GetChildren()) do
        local char = plyr.Character or plyr.CharacterAdded:Wait()
        local humanoidRootPart = char:WaitForChild("HumanoidRootPart")
        humanoidRootPart.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 10, 0))
    end
end


return DebugActions