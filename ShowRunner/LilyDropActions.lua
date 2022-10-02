local LilyDropActions = {}

-- Services
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Dependancies
local Network2 = require(game.ReplicatedStorage.Modules.Core.Network)
local Logger = require(game.ReplicatedStorage.Modules.Core.Logger)

-- Constants
local BPM = require(game.ReplicatedStorage.Modules.BPM).SongBPM.AFY
local LILY_SPAWN_HEIGHT = 50
local BEATS_IN_DESCENT = 4
local TIME_TO_DESCEND = BEATS_IN_DESCENT/(BPM/60)
local LILY_SPAWN_OFFSET = 150
local LILY_SWING = 00  -- How far sideways from the player can lilies spawn
local COLLECTION_SOUND_ID = "rbxassetid://10106221280"

-- Declarations
local client = Network2.client
local beatTime = 60/BPM
local localplayer = Players.LocalPlayer
local character = localplayer.Character or localplayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local tigerLilyTemplate = game.ReplicatedStorage.Assets.Models:WaitForChild("TigerLily")
local tigerLilyTool = game.ReplicatedStorage.Assets.Items:WaitForChild("Tiger Lily")
local lilyCounterUI = localplayer.PlayerGui:WaitForChild("LilyPickup")
local uiBase = lilyCounterUI:WaitForChild("Base")
local textLabel = uiBase:WaitForChild("TextLabel")
local LilyPath = workspace.AFY.Engineering.AutorunnerLilies

local lilyDescentTweenInfo = TweenInfo.new(
    TIME_TO_DESCEND,
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.Out,
    0,
    false,
    0
)

local hasCollectedLily = false
local liliesCollected = 0

-- Functions

function isHitFromPlayer(hit)
    local hitPlayer = game.Players:GetPlayerFromCharacter(hit.Parent)
    local isPlayer = hitPlayer ~= nil
    local isLocalPlayer = isPlayer and hitPlayer == localplayer
    return isPlayer, isLocalPlayer
end


function updateLilyCounter()
    textLabel.Text = tostring(math.min(liliesCollected, 15)).. " / 15"
end


local collectDebounce = false
function collectLily()
    if collectDebounce then
        return
    end
    collectDebounce = true

    liliesCollected += 1

    if liliesCollected == 15 then
        Network2:FireServer("awardSong", "AFY")
    end

    updateLilyCounter()
    if hasCollectedLily then
        collectDebounce = false
        return
    end
    hasCollectedLily = true
    task.delay(120, function()
        hasCollectedLily = false
    end)
    Network2:FireServer("GiveTigerLilyTool")
    -- tigerLilyTool:Clone().Parent = localplayer.Backpack
    collectDebounce = false
end


-- Lower the lily to the ground, and add some rotation
function tweenLilyDescent(lily, targetPosition)
    local tween = TweenService:Create(
        lily,
        lilyDescentTweenInfo,
        {Position = targetPosition}
    )
    print("Playing tween. Tween length: " .. tostring(TIME_TO_DESCEND))
    tween:Play()
end


function setupTouchedConnection(lily)
    lily.Touched:Connect(function(hit)
        local hitByPlayer, collected = isHitFromPlayer(hit)
        if not hitByPlayer then
            return
        end
        if collected then
            collectLily()
        end

        local CollectParticle = lily.CollectParticle
        local WorldPosition = CollectParticle.WorldPosition
        CollectParticle.Parent = workspace.Terrain
        CollectParticle.Position = WorldPosition

        for _, Item in pairs(CollectParticle:GetChildren()) do
            Item:Emit(Item:GetAttribute("EmitCount"))
        end

        lily:Destroy()

        task.wait(2)
        
        CollectParticle:Destroy()
    end)
end


function spawnLily()
    -- Logger.Debug("Spawning lily at targetPosition=" .. tostring(targetPosition))
    local targetPosition = client.getRandomPoint(math.random(70, 80), math.random(-10, 10))
    local lily = tigerLilyTemplate:Clone()
    lily.Position = targetPosition + Vector3.new(0, LILY_SPAWN_HEIGHT, 0)
    lily.Parent = LilyPath
    Debris:AddItem(lily, 30)
    tweenLilyDescent(lily, targetPosition)
    setupTouchedConnection(lily)
end


function spawnLilyAheadOfPlayer()
    local playerCFrame = humanoidRootPart.CFrame
    -- Spawn tigerlily X studs ahead of player
    local swing = math.random(-LILY_SWING, LILY_SWING)
    local targetCFrame = playerCFrame * CFrame.new(swing, 0, -LILY_SPAWN_OFFSET)
    spawnLily()
end

function LilyDropActions.reset()
    liliesCollected = 0
    textLabel.Text = tostring(math.min(liliesCollected, 15)).. " / 15"
end

function LilyDropActions.DropLiliesForGivenBeats(beatCount, beatWait)
    task.delay((beatWait or 0)*beatTime, function()
        for i = 1, beatCount do
            task.wait(beatTime)
            if i % 2 ~= 0 then
                continue
            end
            spawnLilyAheadOfPlayer()
        end
    end)
end


return LilyDropActions