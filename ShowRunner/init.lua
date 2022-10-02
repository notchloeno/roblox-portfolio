local ShowRunner = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Constants
local SONG_NAME = "AFY"
local SONG_ATTRIBUTE = "Song"
local BEAT_ATTRIBUTE = "SongPositionInBeats"
local OFFSET = 8

-- Dependancies
local Logger = require(game.ReplicatedStorage.Modules.Core.Logger)
local CueSheet = require(script.CueSheet)

-- Variables

local bpmScript = ReplicatedStorage.Modules.BPM
local connections = {}

-- Functions

function onBeatChange()
    -- Add one to currentBeat. `BPM` counts from 0, music and Lua count from 1
    local currentBeat = bpmScript:GetAttribute(BEAT_ATTRIBUTE) + 1
    --Logger.Debug("Current beat=" .. tostring(currentBeat - OFFSET))
    currentBeat = tonumber(currentBeat) - OFFSET
    if currentBeat < 1 then
        return
    end

    local cue = CueSheet[currentBeat]
    if cue == nil then
        return
    end
    cue:Call()
end


-- Restart the countdown's current time, then start events based off of time markers.
function ShowRunner.Initialize()
    print('initializing')
    connections.songChanged = bpmScript:GetAttributeChangedSignal(SONG_ATTRIBUTE):Connect(function()
        --Logger.Debug("Song changed to " .. tostring(bpmScript:GetAttribute(SONG_ATTRIBUTE)))
        if not (bpmScript:GetAttribute(SONG_ATTRIBUTE) == SONG_NAME) then
            if connections.beatChanged ~= nil then
                ShowRunner.Cleanup()
            end

            return
        end
        Logger.Info("Connecting `ShowRunner` to `onBeatChange` for song \"Anyone For You\"")
        connections.beatChanged = bpmScript:GetAttributeChangedSignal(BEAT_ATTRIBUTE):Connect(onBeatChange)
    end)
end


function ShowRunner.Cleanup()
    print('cleaning up')
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end
end


-- Init
do
    ShowRunner.Initialize()
end

return ShowRunner