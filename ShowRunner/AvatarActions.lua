-- TODO: Move Rainbow Tiger Lily logic into a separate Actions script
local AvatarActions = {}

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Dependancies
local General = require(game.ReplicatedStorage.Modules.Utils.General)
local Network = require(game.ReplicatedStorage.Modules.Core.Network)
local Bezier = require(game.ReplicatedStorage.Modules.Bezier)

-- Constants
local LILY_THROW_DIRECTION = Vector3.new(20, 35, -1)
local LILY_THROW_FORCE = 800

local AMPLITUDE = .035 -- offset on both sides
local MAGNITUDE = 1 -- time rainbow lily takes to move from the bottom -> top, and top -> bottom

-- Declarations
local localplayer = game.Players.LocalPlayer
local avatar, cloud
local avatarWeld
local AutorunnerPaths = workspace.AFY.Engineering.AutorunnerPaths
local positionMarkers = workspace.AFY.Engineering.AvatarSpots
local rainbowLily
local rainbowLilyCollected = false


local CFrameValue = Instance.new("CFrameValue")

-- Functions

function generatePath(flightPath)
    local path = flightPath:GetChildren()
    table.sort(path, function(a, b)
        return tonumber(a.Name) < tonumber(b.Name)
    end)
    return path
end

function setGoldAuraEnabled(state)
    local aura = avatar:FindFirstChild("Aura")
    if not aura then
        return
    end

    aura = aura:GetDescendants()
    for _, inst in ipairs(aura) do
        if not inst:IsA("ParticleEmitter") then
            continue
        end
        -- local emitCount = inst:GetAttribute("EmitCount")
        inst.Enabled = state
    end
end


function setTransparency(finishTransparent)
    local parts = avatar:GetChildren()
    for _, part in pairs(parts) do
        if part:IsA("BasePart") and part ~= avatar.PrimaryPart and not part:FindFirstChild("Transparent") then
            part.Transparency = if finishTransparent then 1 else 0
        end
    end
end


function AvatarActions.PlayGoldenVFXForDuration(finishTransparent, duration)
    if finishTransparent == nil then
        finishTransparent = false
    end

    task.spawn(function()
        setGoldAuraEnabled(true)
        task.wait(duration)
        setGoldAuraEnabled(false)
    end)

    setTransparency(finishTransparent)
end


function AvatarActions.PlayGoldenVFX(finishTransparent)
    if finishTransparent == nil then
        finishTransparent = false
    end

    task.spawn(function()
        local aura = avatar:FindFirstChild("Aura")
        if not aura then
            return
        end

        aura = aura:GetDescendants()
        for _, inst in ipairs(aura) do
            if not inst:IsA("ParticleEmitter") then
                continue
            end
            local emitCount = inst:GetAttribute("EmitCount")
            inst:Emit(emitCount)
        end
    end)

    setTransparency(finishTransparent)
end


function AvatarActions.Intro()
    -- Verify that the avatar is loaded in
    avatar = workspace:WaitForChild("AFY"):WaitForChild("AFY")
    cloud = avatar:WaitForChild("Cloud")

    local marker = positionMarkers:WaitForChild("Intro")
    -- General.TweenModel(avatar, marker.CFrame, 2)
    AvatarActions.PlayGoldenVFX(true)
    task.wait(0.1)
    avatar:SetPrimaryPartCFrame(marker.CFrame)
    AvatarActions.PlayGoldenVFX(false)
end


function AvatarActions.FirstAutoRunner()
    local marker = positionMarkers:WaitForChild("AutoRunner1")
    AvatarActions.PlayGoldenVFX(true)
    task.wait(0.1)
    avatar:SetPrimaryPartCFrame(marker.CFrame)
    AvatarActions.PlayGoldenVFX(false)
end


function AvatarActions.PlanePickup()
    local marker = positionMarkers:WaitForChild("PlanePickup")
    AvatarActions.PlayGoldenVFX(true)
    task.wait(0.1)
    avatar:SetPrimaryPartCFrame(marker.CFrame)
    AvatarActions.PlayGoldenVFX(false)
end

function AvatarActions.LockToPart(bool: boolean)
    local aura = avatar:FindFirstChild("Aura")
    if not aura then
        return
    end

    aura = aura:GetDescendants()
    for _, inst in ipairs(aura) do
        if not inst:IsA("ParticleEmitter") then
            continue
        end
        inst.LockedToPart = bool
    end
end

function AvatarActions.PlaneRide()
    local marker = positionMarkers:WaitForChild("PlanePart")
    avatar:SetPrimaryPartCFrame(marker.CFrame)
    AvatarActions.PlayGoldenVFX(false)
    avatarWeld = Instance.new("WeldConstraint")
    avatarWeld.Part0 = avatar.PrimaryPart
    avatarWeld.Part1 = marker
    avatarWeld.Parent = avatar
    avatar.PrimaryPart.Anchored = false

    AvatarActions.LockToPart(true)
end


function AvatarActions.TurnAround()
    local marker = positionMarkers:WaitForChild("PlanePartReversed")
    avatarWeld.Enabled = false
    avatar:SetPrimaryPartCFrame(marker.CFrame)
    avatarWeld.Enabled = true
end

function AvatarActions.AutorunnerBezier()
    local marker = positionMarkers:WaitForChild("Final")
    --General.TweenModel(avatar, marker.CFrame, 4)

    local path = generatePath(AutorunnerPaths.SecondPath)

    table.insert(path, 1, avatar.PrimaryPart.Position)
    CFrameValue.Value = avatar.PrimaryPart.CFrame-Vector3.new(0,90,0)
    path[#path+1] = marker.Position-Vector3.new(0,90,0)

    local pathBezier = Bezier.new(unpack(path))
    local tweenInfo = TweenInfo.new(14, Enum.EasingStyle.Linear)
    local cframeTween = pathBezier:CreateCFrameTween(CFrameValue, {"Value"}, tweenInfo, true)
    local connection

    cframeTween:Play()
	connection = CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
        avatar:SetPrimaryPartCFrame(CFrameValue.Value+Vector3.new(0,90,0))
    end)
    cframeTween.Completed:Connect(function()
        connection = connection and connection:Disconnect()
    end)
end

function AvatarActions.AfterPlane()
    if avatarWeld ~= nil then
        avatarWeld:Destroy()
        avatar.PrimaryPart.Anchored = true
    end
    --AvatarActions.LockToPart(false)
    AvatarActions.AutorunnerBezier()
end


function AvatarActions.SecondAutoRunner()
    local marker = positionMarkers:WaitForChild("AutoRunner2")
    General.TweenModel(avatar, marker.CFrame, 8)
end


function AvatarActions.Final()
    local marker = positionMarkers:WaitForChild("Final")
    AvatarActions.PlayGoldenVFX(true)
    task.wait(0.1)
    avatar:SetPrimaryPartCFrame(marker.CFrame)
    AvatarActions.PlayGoldenVFX(false)
end


function AvatarActions.EnableCloud()
    if not cloud then
        error("No cloud found")
    end
    for _, emitter in ipairs(cloud:GetChildren()) do
        if not emitter:IsA("ParticleEmitter") then
            continue
        end
        emitter.Enabled = true
    end
end


function AvatarActions.DisableCloud()
    if not cloud then
        error("No cloud found")
    end
    for _, emitter in ipairs(cloud:GetChildren()) do
        if not emitter:IsA("ParticleEmitter") then
            continue
        end
        emitter.Enabled = false
    end
end


function AvatarActions.EnableSpotlight()
    avatar.SpotLightPart.SpotLight.Enabled = true
end


function isHitFromPlayer(hit)
    local hitPlayer = game.Players:GetPlayerFromCharacter(hit.Parent)
    local isPlayer = hitPlayer ~= nil
    local isLocalPlayer = isPlayer and hitPlayer == localplayer
    return isPlayer, isLocalPlayer
end


function collectRainbowLily(hit)
    local _, isLocalPlayer = isHitFromPlayer(hit)
    if not isLocalPlayer then
        return
    elseif rainbowLilyCollected then
        return
    end
    RunService:UnbindFromRenderStep("AFYRotation")
    Network:FireServer("CollectLily", "AFY")
    rainbowLilyCollected = true
    task.delay(120, function()
        rainbowLilyCollected = false
    end)
    rainbowLily:Destroy()
end


function updateRainbowLilyGraphics()
    if not rainbowLily then -- Check if the part exists
        return
    end

    if not rainbowLilyCollected then
        local cframeModifier = CFrame.Angles(math.rad(3), 0, 0)
        cframeModifier += Vector3.new(0, AMPLITUDE*math.sin( tick()*math.pi/MAGNITUDE ), 0)
        rainbowLily.CFrame = rainbowLily.CFrame * cframeModifier
    else
        local cframeModifier = CFrame.Angles(0, math.rad(5), 0)
        rainbowLily.CFrame = rainbowLily.CFrame * cframeModifier
    end
end


function AvatarActions.SummonLily()
    local lily = avatar:WaitForChild("TigerLily")
    rainbowLily = lily
    lily.ParticleEmitter.Enabled = true
    local info = TweenInfo.new(2)
    local tween = TweenService:Create(lily, info, { Transparency = 0 })
    tween:Play()
    tween.Completed:Connect(function()
        lily.ParticleEmitter.Enabled = false
        tween:Destroy()
    end)
    lily.Touched:Connect(collectRainbowLily)
end


function AvatarActions.ThrowLily()
    local lily = avatar:WaitForChild("TigerLily")
    local lilyWeld = lily:WaitForChild("WeldConstraint")
    -- Create a force to "throw" the lily
    lilyWeld:Destroy()
    lily.Anchored = true
    local positions = {}

    for i,point in ipairs(workspace.AFY:WaitForChild("GuitarPiecePoints"):GetChildren()) do
        positions[tonumber(point.Name)] = point
    end

    local NewBezier = Bezier.new(unpack(positions))

    for i=1,1 do


        local FlightTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local Tween2 = NewBezier:CreateVector3Tween(lily, {"Position"}, FlightTweenInfo)
        Tween2:Play()
        
        task.delay(1.3, function()
            lily.Anchored = false
            local highlight = Instance.new("Highlight")
            highlight.OutlineTransparency = 0.33
            highlight.FillTransparency = 1
            highlight.DepthMode = Enum.HighlightDepthMode.Occluded
            highlight.Parent = lily
        end)
    end
end


return AvatarActions
