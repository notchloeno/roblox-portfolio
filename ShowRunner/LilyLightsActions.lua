local LilyLightsActions = {}

-- Services
local TweenService = game:GetService("TweenService")

-- Declarations
local BPM = require(game.ReplicatedStorage.Modules.BPM).SongBPM.AFY
local fullBeatTime = 60/BPM
local halfBeatTime = 30/BPM

local fullTimeTweenInfo = TweenInfo.new(
    fullBeatTime * 3,
    Enum.EasingStyle.Sine,
    Enum.EasingDirection.Out,
    0, false, 0
)
local halfTimeTweenInfo = TweenInfo.new(
    halfBeatTime * 3,
    Enum.EasingStyle.Sine,
    Enum.EasingDirection.Out,
    0, false, 0
)

-- Functions

function blinkSingleLily(lily, halfTime)
    local tweenInfo
    if halfTime then
        tweenInfo = halfTimeTweenInfo
    else
        tweenInfo = fullTimeTweenInfo
    end

    local highlight = lily:FindFirstChild("Highlight")
    local pointLight = lily:FindFirstChild("PointLight")

    highlight.FillTransparency = 0.65
    pointLight.Brightness = 8
    --Cleaned up Tween variables
    TweenService:Create(highlight, tweenInfo, { FillTransparency = 1 }):Play()
    TweenService:Create(pointLight, tweenInfo, { Brightness = 0 }):Play()
end


function blinkLilies(count, halfTime)
    local lilies = workspace.AFY.Assets.BigLilies
    local lilyCount = #lilies:GetChildren()
    for i = 0, count - 1 do
        local lilyNumber = (i % lilyCount) + 1
        local lily = lilies:FindFirstChild(tostring(lilyNumber))
        task.spawn(blinkSingleLily, lily)
        if halfTime then
            task.wait(halfBeatTime * 0.99)
        else
            task.wait(fullBeatTime * 0.99)
        end
    end
end


function LilyLightsActions.BlinkAllLilies(count, halfTime)
    local lilies = workspace.AFY.Assets.BigLilies
    for _ = 1, count do
        for _, lily in ipairs(lilies:GetChildren()) do
            task.spawn(blinkSingleLily, lily, halfTime)
        end
        if halfTime then
            task.wait(halfBeatTime * 0.99)
        else
            task.wait(fullBeatTime * 0.99)
        end
    end
end


function LilyLightsActions.BlinkHalfLilies(count, halfTime)
    local lilies = workspace.AFY.Assets.BigLilies
    for a = 1, count do
        for b, lily in ipairs(lilies:GetChildren()) do
            if a % 2 == b % 2 then
                task.spawn(blinkSingleLily, lily, halfTime)
            end
        end
        if halfTime then
            task.wait(halfBeatTime * 0.99)
        else
            task.wait(fullBeatTime * 0.99)
        end
    end
end


function LilyLightsActions.BlinkLilies(count, halfTime)
    if count < 1 then
        error("Volley count must be greater than 0")
    end

    task.spawn(function()
        blinkLilies(count, halfTime)
    end)
end

return LilyLightsActions