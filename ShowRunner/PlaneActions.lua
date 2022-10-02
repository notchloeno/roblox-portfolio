local PlaneActions = {}

--Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Dependancies
local TogglePlayers = require(game.ReplicatedStorage.Modules.Utils.TogglePlayers)
local Networking = require(game.ReplicatedStorage.Modules.Core.Network)
local Bezier = require(game.ReplicatedStorage.Modules.Bezier)
local client = Networking.client

-- Declarations
local localplayer = Players.LocalPlayer
local playerModule = require(localplayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local controls = playerModule:GetControls()
local character = localplayer.Character or localplayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local plane = workspace.AFY.Engineering:WaitForChild("Plane")
local walkway = plane:WaitForChild("StandArea")

-- local jumpedOffTick = 0
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { walkway }

local FlightTweenInfo = TweenInfo.new(33, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)

local lastPlaneCFrame = walkway.CFrame
local keepPlayerOnPlaneConnection
--local currentFlightPath

local DancingAnimationIDs = {
    "rbxassetid://4841405708", -- Happy
    "rbxassetid://3338097973", -- Celebrate
    "rbxassetid://4265725525", -- Cutesy Dance
    "rbxassetid://5918726674", -- Dolphin
    "rbxassetid://5895324424", -- Big Wave
    "rbxassetid://3333136415", -- Disco
    "rbxassetid://10223073084", -- Conductor
    --"rbxassetid://10223090877", -- Kickback
    "rbxassetid://10223084286", -- SideKick
    "rbxassetid://10223066554", -- BoomBoomClap
    "rbxassetid://10223061191", -- Cartwheel
    "rbxassetid://10223078662" -- ChillVibes
}

-- Functions
local function WeldParts(Part0, Part1)
    Part1.Anchored = false
    local weld = Instance.new("ManualWeld")
    weld.C0 = Part0.CFrame:inverse() * Part1.CFrame
    weld.Part0 = Part0
    weld.Part1 = Part1
    weld.Parent = Part0
end

-- Returns true if the local player is stood on the plane
function playerIsOnPlane()
    local hit = workspace:Raycast(rootPart.CFrame.Position, Vector3.new(0, -50, 0), raycastParams)
    if hit and hit.Instance == walkway then
        return true
    else
        return false
    end
end


function keepPlayerOnPlane()
    if playerIsOnPlane() then
        if lastPlaneCFrame == nil then
            error("Invalid case")
        end

        local walkwayCFrame = walkway.CFrame
        local relativeCFrame = walkwayCFrame * lastPlaneCFrame:Inverse()
        lastPlaneCFrame = walkway.CFrame
        rootPart.CFrame = relativeCFrame * rootPart.CFrame
    else
        print("Player has fallen off plane")
        rootPart.CFrame = walkway.CFrame * CFrame.new(0, 10, 1)
    end
end


function generatePath(flightPath)
    local path = flightPath:GetChildren()
    table.sort(path, function(a, b)
        return tonumber(a.Name) < tonumber(b.Name)
    end)
    return path
end

function tweenPropeller()
    plane.PrimaryPart.Motor6D.DesiredAngle = 100000
end

function stopPropeller()
    plane.PrimaryPart.Motor6D.DesiredAngle = plane.PrimaryPart.Motor6D.CurrentAngle
end

function createCharacters()
    local Itr = math.random(0,1)
    for _, plyr in pairs(Players:GetPlayers()) do
        if plyr ~= localplayer and plyr.Character then
            Itr += 1
            local offsetSign = Itr%2 == 0 and 1 or -1
            local offset = math.ceil(Itr/2)*offsetSign*9

            local char2 = plyr.Character
            char2.Archivable = true
            local clone = char2:Clone()
            char2.Archivable = false
            clone.Parent = workspace.AFY.Engineering.FakeCharacters
            clone.PrimaryPart.CFrame = walkway.CFrame * CFrame.new(offset, 5.5, 1)
            WeldParts(walkway, clone.PrimaryPart)

            local Animation = Instance.new("Animation")
            Animation.AnimationId = DancingAnimationIDs[Itr%#DancingAnimationIDs + 1]
            local AnimationTrack = clone.Humanoid:LoadAnimation(Animation)
            AnimationTrack:Play()
            Animation:Destroy()
            task.wait(1)
        end
    end
end

function removeCharacters()
    for _, char in pairs(workspace.AFY.Engineering.FakeCharacters:GetChildren()) do
        char:Destroy()
    end
end

function startPlaneMovement(flightPath)
    local path = generatePath(flightPath)
    local pathBezier = Bezier.new(unpack(path))
    local flightTween = pathBezier:CreateCFrameTween(plane.PrimaryPart, { "CFrame" }, FlightTweenInfo)
    flightTween:Play()
    tweenPropeller()
end

--[[
function startPlaneMovement()
    local CFrameValue = workspace.AFY.Engineering.PlaneCFrame
    local oldParent = localplayer.Character.Parent

    localplayer.Character.Parent = plane
	RunService:BindToRenderStep("PlaneMovement", 1, function()
        plane:SetPrimaryPartCFrame(CFrameValue.Value)
    end)

    task.delay(30, function()
        RunService:UnbindFromRenderStep("PlaneMovement")
        localplayer.Character.Parent = oldParent
    end)

    tweenPropeller()
end
--]]

function getRotatedMoveVector(cframe, vector)
    return cframe:VectorToWorldSpace(vector)
end

function moveFunction(_, inputVector, _)
    local moveVector = Vector3.new(inputVector.X, 0, 0)
    moveVector = getRotatedMoveVector(plane.StandArea.CFrame, moveVector)
    localplayer:Move(moveVector)
end


function setupControls()
    controls:GetActiveController().moveVectorIsCameraRelative = false
    controls.moveFunction = moveFunction
end


function resetControls()
    controls:GetActiveController().moveVectorIsCameraRelative = true
    controls.moveFunction = localplayer.Move
end


function PlaneActions.StartRide(flightPath)
    setupControls()
    startPlaneMovement(flightPath)
    --Networking:FireServer("UpdateQueue", "PlaneRide")
    
    createCharacters()
    TogglePlayers(true)
    keepPlayerOnPlaneConnection = RunService.Heartbeat:Connect(keepPlayerOnPlane)
end


function PlaneActions.Disembark()
    resetControls()
    removeCharacters()
    TogglePlayers(false)
    keepPlayerOnPlaneConnection:Disconnect()
    stopPropeller()
    
    for _, part in ipairs(plane:GetChildren()) do
        if part.Name == "InvisWall" then
            part.CanCollide = false
        end
    end
end

do
    --client.startPlaneRide = startPlaneMovement
end

return PlaneActions