local Players = game:GetService("Players")

local FriendsDescriptions = require(game.ReplicatedStorage.Modules.Utils.FriendsDescriptions)
local SetCollisions = require(game.ReplicatedStorage.Modules.SetCollisions)

local Player = Players.LocalPlayer

local DancingAnimationIDs = {
    "rbxassetid://4841405708", -- Happy
    "rbxassetid://3338097973", -- Celebrate
    "rbxassetid://4265725525", -- Cutesy Dance
    "rbxassetid://5895324424", -- Big Wave
    "rbxassetid://10223066554", -- BoomBoomClap
}

local function start()
    task.spawn(function() 
        local FriendsFolder = workspace.AFY:WaitForChild("Assets", 60).Friends
        for Itr, Dummy in pairs(FriendsFolder:GetChildren()) do
            -- Can only set HumanoidDescriptions on Locally Created Humanoids
            local NewDummy = Dummy:Clone()
            NewDummy.Parent = Dummy.Parent
            Dummy:Destroy()

            local ID = FriendsDescriptions.GetRandomFriend(Player.UserId)
            if ID then
                NewDummy.Humanoid:ApplyDescription(ID)
            end

            local Animation = Instance.new("Animation")
            Animation.AnimationId = DancingAnimationIDs[Itr%#DancingAnimationIDs + 1]

            local AnimationTrack = NewDummy.Humanoid:LoadAnimation(Animation)
            AnimationTrack:Play()
            Animation:Destroy()

            SetCollisions(Dummy)
        end
    end)
end

return start