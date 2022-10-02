local PlayerActions = {}

-- Constants
local ANIMATION_IDS = {
    HandsUp = "rbxassetid://4841405708"
}

-- Declarations
local localPlayer = game:GetService("Players").LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animationController = humanoid:WaitForChild("Animator")

local activeTrack

-- Functions

function stopActiveTrack()
    if not activeTrack then
        return
    end
    activeTrack:Stop()
    activeTrack:Destroy()
    activeTrack = nil
end


function forceEmote(animationId)
    stopActiveTrack()
    local animation = Instance.new("Animation")
    animation.AnimationId = animationId
    local track = animationController:LoadAnimation(animation)
    track.AnimationPriority = Enum.AnimationPriority.Action
    track:Play()
end


function PlayerActions.HandsUp()
    forceEmote(ANIMATION_IDS.HandsUp)
end


function PlayerActions.ResetAnimations()
    stopActiveTrack()
end


function PlayerActions.SetupStates()
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
end


function PlayerActions.ResetStates()
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
end


return PlayerActions