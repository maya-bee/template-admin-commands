local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(game:GetService("ReplicatedStorage"):WaitForChild("GRPeeAdminModules"):WaitForChild("Utility"))
local Events = Util.Event

local Sound = game:GetService("SoundService"):WaitForChild("GRPeeAdminSound")

-- SOUND MANAGEMENT

Events:Get("PlaySound").OnClientEvent:Connect(function(sound, looped)
    Sound.SoundId = sound
    if not Sound.IsLoaded then
        Sound.Loaded:Wait()
    end
    Sound.Looped = looped or false -- so that its never "nil"
    Sound:Play()
end)

Events:Get("StopPlayingSound").OnClientEvent:Connect(function()
    Sound:Stop()
end)