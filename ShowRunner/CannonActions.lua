local CannonActions = {}

-- Declarations
local BPM = require(game.ReplicatedStorage.Modules.BPM).SongBPM.AFY
local oneBeatTime = 60/BPM
local halfBeatTime = 30/BPM
local quarterBeatTime = 15/BPM

local cannonsFolder = workspace.AFY.Engineering.Cannons
local activeCannonsFolder

-- Functions


function fireSingleCannon(cannon)
    print("Firing cannon with name=" .. tostring(cannon.Name))
	local sound = cannon:FindFirstChild("Firing")
    sound.PlaybackSpeed = math.random(4, 8) / 10
    sound:Play()
	local emitters = cannon:WaitForChild("Launcher"):WaitForChild("Attachment"):GetChildren()
	for _, e in ipairs(emitters) do
		e:Emit(5)
	end
end


function fireCannons(count, waitTime)
    local cannonCount = #activeCannonsFolder:GetChildren()
    for i = 0, count - 1 do
        local cannonNumber = (i % cannonCount) + 1
        local cannon = activeCannonsFolder:FindFirstChild(tostring(cannonNumber))
        fireSingleCannon(cannon)
        task.wait(waitTime * 0.99)
    end
end


function fireVolley(count, bpmRatio)
    if count < 1 then
        error("Volley count must be greater than 0")
    elseif not (bpmRatio == 1 or bpmRatio == 0.5 or bpmRatio == 0.25) then
        error("BPM Ratio must be one, one half, or one quarter")
    end
    local waitTime
    if bpmRatio == 1 then
        waitTime = oneBeatTime
    elseif bpmRatio == 0.5 then
        waitTime = halfBeatTime
    elseif bpmRatio == 0.25 then
        waitTime = quarterBeatTime
    end
    task.spawn(function()
        fireCannons(count, waitTime)
    end)
end


function CannonActions.FireVolleyOne(count, bpmRatio)
    activeCannonsFolder = cannonsFolder.First
    fireVolley(count, bpmRatio)
end


function CannonActions.FireVolleyTwo(count, bpmRatio)
    activeCannonsFolder = cannonsFolder.Second
    fireVolley(count, bpmRatio)
end

return CannonActions