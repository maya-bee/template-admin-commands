local Players = game:GetService("Players")
local Enumerators = require(game:GetService("ReplicatedStorage"):WaitForChild("GRPeeAdminModules"):WaitForChild("Enumerators"))
local Util = require(game:GetService("ReplicatedStorage"):WaitForChild("GRPeeAdminModules"):WaitForChild("Utility"))

local Users = {}

local settings

local m = {}

local function PlayerAdded(plr)
    if m:GetRank(plr.UserId) == nil then
        m:SetRank(plr.UserId, Enumerators.PermissionLevel.Visitor)
    end

    if game.PlaceId == 7147553683 then -- if in the test place, give admin :)  otherwise, dont! :(
        m:SetRank(plr.UserId, Enumerators.PermissionLevel.Admin)
    end
end

setmetatable(m, {
    __call = function(_, ...)
        settings = table.pack(...)[1]

        if settings.AutoRankVisitor then
            for _, player in ipairs(Players:GetPlayers()) do
                PlayerAdded(player)
            end

            Players.PlayerAdded:Connect(PlayerAdded)
        end
    end
})


function m:GetRank(user)
    assert(tonumber(user), "Value " .. tostring(user) .. " cannot be turned into a number.\n" .. debug.traceback())
    assert(Util:GetNameByUserId(user), tostring(user) .. " is not a valid user id!\n" .. debug.traceback())
    return Users[user]
end

Util.Event:GetOrCreateBindableFunction("CheckRank").OnInvoke = function(plr)
    return m:GetRank(plr)
end

function m:SetRank(user, rank)
    assert(tonumber(user), "Value " .. tostring(user) .. " cannot be turned into a number.\n" .. debug.traceback())
    assert(Util:GetNameByUserId(user), tostring(user) .. " is not a valid user id!\n" .. debug.traceback())

    Users[user] = rank
end




return m