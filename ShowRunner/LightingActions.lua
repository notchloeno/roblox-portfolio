-- This module is responsible for the `Lighting` singleton service, not all the light-based VFX
local LightingActions = {}

-- Services
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- Functions


function LightingActions.TransitionToNight(timestamp, length)
    if not timestamp then
        error("No timestamp given")
    elseif 0 > timestamp or timestamp >= 24 then
        error("Timestamp out of range 0 < timestamp <= 24")
    elseif not length then
        error("No transition length given")
    end

    local info = TweenInfo.new(
        length,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    local tween = TweenService:Create(Lighting, info,  {
        ClockTime = timestamp,
        Brightness = 2,
        Ambient = Color3.fromRGB(1, 0, 53)
    })
    tween:Play()
end


function LightingActions.TransitionToDay(timestamp, length)
    if not timestamp then
        error("No timestamp given")
    elseif 0 > timestamp or timestamp >= 24 then
        error("Timestamp out of range 0 < timestamp <= 24")
    elseif not length then
        error("No transition length given")
    end

    local info = TweenInfo.new(
        length,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    local tween = TweenService:Create(Lighting, info,  {
        ClockTime = timestamp,
        Brightness = 4.7,
        Ambient = Color3.fromRGB(147, 182, 225)
    })
    tween:Play()
end

function LightingActions.Reset()
    Lighting.ClockTime = 13.777
    Lighting.Brightness = 4.7
    Lighting.Ambient = Color3.fromRGB(147, 182, 225)
end


-- function LightingActions.TransitionToTime(timestamp, length)
--     if not timestamp then
--         error("No timestamp given")
--     elseif 0 < timestamp or timestamp >= 24 then
--         error("Timestamp out of range 0 < timestamp <= 24")
--     elseif not length then
--         error("No transition length given")
--     end

--     local tween = generateLightingTween(timestamp, length)
--     tween:Play()
-- end


return LightingActions