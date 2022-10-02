-- An object to handle the description and execution of cues and their data
local Cue = {}
Cue.__index = Cue

-- Dependancies
local Logger = require(game.ReplicatedStorage.Modules.Core.Logger)

-- Functions

function Cue.new(name, action, ...)
    local arguments = {...}
    return setmetatable({
        name = name,
        action = action,
        called = false,
        args = arguments
    }, Cue)
end


function Cue:Call()
    if self.called then
        Logger.Error("Tried to call the same cue twice")
    end
    Logger.Debug("Calling cue " .. self.name)
    self.called = true
    if self.action then
        self.action(unpack(self.args))
    end
end


return Cue