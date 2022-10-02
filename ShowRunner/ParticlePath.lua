return function()
    local Bezier = require(game.ReplicatedStorage.Modules.Utils.Bezier)
    local positions = {}

    for i,point in ipairs(workspace.AFY:WaitForChild("Points"):GetChildren()) do
        positions[tonumber(point.Name)] = point
    end

    local NewBezier = Bezier.new(unpack(positions))

    for i=1,1 do
        local newPoint = workspace.AFY.path:Clone()
        newPoint.CFrame = positions[1].CFrame
        newPoint.Parent = workspace.AFY
        for i,particle in ipairs(newPoint:GetChildren()) do
            particle.Enabled = true
        end

        local FlightTweenInfo = TweenInfo.new(3.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local Tween2 = NewBezier:CreateVector3Tween(newPoint, {"Position"}, FlightTweenInfo)
        Tween2:Play()
        
        task.delay(3.5, function()
            if newPoint then 
                for i,particle in ipairs(newPoint:GetChildren()) do
                    particle.Enabled = false
                end
                if newPoint then 
                    newPoint:Destroy()
                end
            end
        end)
    end
end