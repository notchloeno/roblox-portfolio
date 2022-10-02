local UIActions = {}

-- Declarations
local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local lilyCounter = playerGui:WaitForChild("LilyPickup")
local lilyCounterShowPos = UDim2.fromScale(0.048,0.687)
local lilyCounterHidePos = lilyCounterShowPos - UDim2.fromScale(0.2,0)

-- Functions

function UIActions.ShowLilyCounter()
    local base = lilyCounter:WaitForChild("Base")
    base.Position = lilyCounterHidePos
    base.Visible = true
    base:TweenPosition(lilyCounterShowPos, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 1, true)
end


function UIActions.HideLilyCounter()
    local base = lilyCounter:WaitForChild("Base")
    base.Position = lilyCounterShowPos
    base:TweenPosition(lilyCounterHidePos, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 1, true)
    task.wait(1)
    base.Visible = false
end

return UIActions