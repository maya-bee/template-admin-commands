local s = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Util = require(game:GetService("ReplicatedStorage"):WaitForChild("GRPeeAdminModules"):WaitForChild("Utility"))
local Events = Util.Event 

local Sound = game:GetService("SoundService"):FindFirstChild("GRPeeAdminSound")
if not Sound then
    if RunService:IsServer() then
        Sound = Instance.new("Sound")
        Sound.Name = "GRPeeAdminSound"
        Sound.Parent = game:GetService("SoundService")
    end
end

s.UI = {}
s.UI.Alert = {
    Id = "rbxassetid://7871668809";
}

-- Makes each sound playable by calling :Play() or :Stop() on it
local function MakePlayableRecursive(table)
    for _, v in pairs(table) do
        if typeof(v) == "table" then
            if not v.Id then
                MakePlayableRecursive(v)
            else
                function v:Play(player)
                    if RunService:IsServer() then
                        Events:Fire("PlaySound", player, v.Id)
                    else
                        Sound.SoundId = v.Id
                        if not Sound.IsLoaded then
                            Sound.Loaded:Wait()
                        end
                        Sound:Play()
                    end 
                end

                function v:Stop(player)
                    if RunService:IsServer() then
                        Events:Fire("StopPlayingSound", player) 
                    else
                        Sound:Stop()
                    end    
                end
            end
        end
    end
end

do
    MakePlayableRecursive(s)
end

if RunService:IsServer() then
    Events.new("PlaySound")
    Events.new("StopPlayingSound")
end

-- Play a sound by id as opposed to reference
function s:Play(player, sound, looped)
    if RunService:IsServer() then
        Events:Fire("PlaySound", player, sound, looped)
    else
        Sound.SoundId = sound
        if not Sound.IsLoaded then
            Sound.Loaded:Wait()
        end
        Sound.Looped = looped or false -- so that its never "nil"
        Sound:Play()
    end    
end

function s:Stop(player)
    if RunService:IsServer() then
        Events:Fire("StopPlayingSound", player) 
    else
        Sound:Stop()
    end    
end

function s:Get()
    if RunService:IsClient() then
        return Sound
    end
end

return s