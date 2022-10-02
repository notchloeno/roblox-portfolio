local AutorunActions = {}

-- Services
local TweenService = game:GetService("TweenService")

-- Dependancies
local Autorunner = require(script.Parent.Parent.Autorunner)

-- Declarations
local AutorunnerPaths = workspace.AFY.Engineering.AutorunnerPaths
local firstWall = workspace.AFY.Engineering.FirstLilyWall
local flowerAwayTweenInfo = TweenInfo.new(4)

-- Functions

function tweenFlowerAway(flower)
    local targetCFrame = flower.CFrame * CFrame.new(0, -15, 0)
    local tween = TweenService:Create(
        flower,
        flowerAwayTweenInfo,
        {
            CFrame = targetCFrame,
            Transparency = 1
        })
    tween:Play()
end
function tweenFlowerBack(flower)
    local targetCFrame = flower.CFrame * CFrame.new(0, 15, 0)
    local tween = TweenService:Create(
        flower,
        flowerAwayTweenInfo,
        {
            CFrame = targetCFrame,
            Transparency = 0
        })
    tween:Play()
end

function lowerFirstWall()
    local barrier = firstWall:FindFirstChild("Barrier")
    if barrier then
        firstWall.Barrier.CanCollide = false
    end
    for _, flower in ipairs(firstWall:GetChildren()) do
        if (flower:IsA("MeshPart")) then
            tweenFlowerAway(flower)
            task.delay(100, function()
                firstWall.Barrier.CanCollide = true
                tweenFlowerBack(flower)
            end)
        end
    end
end


function AutorunActions.FirstSegment(speed)
    lowerFirstWall()
    Autorunner.SetupFirstSegment()
    Autorunner.Start(AutorunnerPaths.FirstPath, speed, true)
end


function AutorunActions.SecondSegment(speed)
    Autorunner.SetupSecondSegment()
    Autorunner.Start(AutorunnerPaths.SecondPath, speed, true)
end


function AutorunActions.Stop()
    Autorunner.Stop()
end


return AutorunActions