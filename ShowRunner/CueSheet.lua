local Cue = require(script.Parent.Cue)

local BPM = require(game.ReplicatedStorage.Modules.BPM).SongBPM.AFY
local beatTime = 60/BPM

-- Action modules
local PlaneActions = require(script.Parent.PlaneActions)
local AvatarActions = require(script.Parent.AvatarActions)
local AutorunActions = require(script.Parent.AutorunActions)
local LightingActions = require(script.Parent.LightingActions)
local CannonActions = require(script.Parent.CannonActions)
local LilyLightsActions = require(script.Parent.LilyLightsActions)
local PlayerActions = require(script.Parent.PlayerActions)
local CameraActions = require(script.Parent.CameraActions)
local LilyDropActions = require(script.Parent.LilyDropActions)
local FakeCharacterActions = require(script.Parent.FakeCharacterActions)
local ParticlePath = require(script.Parent.ParticlePath)
local UIActions = require(script.Parent.UIActions)


local LilyHandler = require(game.ReplicatedStorage.Modules.RainbowLilyClient)
local FlowerManager = require(script.Parent.Parent.FlowerManager)

-- Declarations
local flightPath = workspace.AFY.Engineering.FlightPath

-- CueSheet for AFY, indexed by the beat on which the cue is called.
return {
    -- [16] = "Last beat of intro",
    [4] = Cue.new("Teleport player", function()
        LightingActions.Reset()
        PlayerActions.SetupStates()
        FakeCharacterActions()
    end),
    [3] = Cue.new("Cannons firing for INTRO - Move avatar to intro location", function()
        task.spawn(AvatarActions.Intro)
        task.spawn(CannonActions.FireVolleyOne, 13, 1)
    end),
    [17] = Cue.new("First beat of first line"),
    [21] = Cue.new("Avatar steps onto rock"),
    [25] = Cue.new("Avatar summons lily", AvatarActions.SummonLily),
    [30] = Cue.new("Avatar throws tiger lily", AvatarActions.ThrowLily),
    [31] = Cue.new("Spawning LILY!", LilyHandler.CreateLily, "AFY"),
    [33] = Cue.new("First AFY avatar cycle"),
    [48] = Cue.new("First autorunner segment", function()
        UIActions.ShowLilyCounter()
        AutorunActions.FirstSegment(12)
    end),
    [49] = Cue.new("First autorunner segment", function()
        LilyDropActions.reset()
        LilyDropActions.DropLiliesForGivenBeats(28, 0)
    end),
    [57] = Cue.new("Nighttime", function()
    LightingActions.TransitionToNight( 23.59, 20)
    end),
    [63] = Cue.new("\"Be your light\" - plane lights up"),
    [73] = Cue.new("GE dissapears", AvatarActions.PlayGoldenVFXForDuration, true, 1),
    [74] = Cue.new("Particle VFX Path", ParticlePath),
    [80] = Cue.new("Animation correction & onto plane", AvatarActions.PlaneRide),
    [81] = Cue.new("GE flying through \"being your light\"", function()
        AvatarActions.EnableSpotlight()
        LightingActions.TransitionToDay(13.77, beatTime*4)
    end),
    [90] = Cue.new("First autorunner segment", AutorunActions.Stop),
    [105] = Cue.new("Players start to get onto plane", function()
        CameraActions.SetupPlaneCamera()
        PlaneActions.StartRide(flightPath)
    end),
    [111] = Cue.new("GE turns around on plane", function()
        AvatarActions.LockToPart(false)
        AvatarActions.PlayGoldenVFXForDuration(true, 1)
        task.delay(0.5, AvatarActions.TurnAround)
        task.wait(1)
        AvatarActions.PlayGoldenVFXForDuration(false, 1)
        task.wait(2)
        AvatarActions.LockToPart(true)
    end),
    [129] = Cue.new("Second AFY avatar cycle"),
    [149] = Cue.new("GE dissapears", function()
        AvatarActions.LockToPart(false)
        AvatarActions.PlayGoldenVFX(true)
    end),
    [155] = Cue.new("GE jumps onto cloud", AvatarActions.EnableCloud),
    [161] = Cue.new("GE lands on cloud", function()
        AvatarActions.PlayGoldenVFXForDuration(false, 2)
    end),
    [170] = Cue.new("Disembark plane", function()
        CameraActions.ResetCamera()
        PlaneActions.Disembark()
    end),
    [173] = Cue.new("Move avatar for second autorun", function()
        AutorunActions.SecondSegment()
        LilyDropActions.DropLiliesForGivenBeats(209 - 173 -4*2)
    end),
    [175] = Cue.new("GE starts movin'", AvatarActions.AfterPlane),
    [177] = Cue.new("Second long \"Be Your Light\" section", LightingActions.TransitionToDay, 13.77, beatTime*4),
    [181] = Cue.new("Avatar to final stage", AvatarActions.SecondAutoRunner),
    [193] = Cue.new("Cannons firing for bridge", CannonActions.FireVolleyOne, 9, 0.5),
    [201] = Cue.new("More cannons", CannonActions.FireVolleyTwo, 13, 0.5),
    [209] = Cue.new("Beginning of buildup for finale", function()
        LightingActions.TransitionToNight(23.59, beatTime*12)
        AvatarActions.DisableCloud()
        AvatarActions.Final()
    end),
    [217] = Cue.new("GROW FLOWERS!", FlowerManager.Init),

    [226] = Cue.new("Piano comes in", LilyLightsActions.BlinkLilies, 32, true),
    [241] = Cue.new("Percussion comes in", LilyLightsActions.BlinkHalfLilies, 16, false),
    [257] = Cue.new("Crescendo before drop", LilyLightsActions.BlinkAllLilies, 16, false),
    [273] = Cue.new("Final drop", LightingActions.TransitionToDay, 13.77, beatTime*4),
    [289] = Cue.new("Outro begins", function()
        LightingActions.TransitionToNight(17, beatTime*32)
        LilyLightsActions.BlinkLilies(62, true)
    end),
    [320] = Cue.new("Final beat", function()
        PlayerActions.ResetStates()
        UIActions.HideLilyCounter()
        task.delay(30,function()
            workspace.AFY.Engineering.Plane:SetPrimaryPartCFrame(workspace.AFY.Engineering.PlaneInitialPoint.CFrame)
        end)
    end)
}