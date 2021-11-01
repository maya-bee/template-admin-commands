local Players = game:GetService("Players")
local CommandsMaster = require(script.Parent.CommandsMaster)
local Util = require(script.Parent.Utility)

local Users = {}

local settings

local m = {}
setmetatable(m, {
    __call = function(_, ...)
        settings = table.pack(...)[1]
        print(settings)

        for _, user in ipairs(settings.Mods) do
            local target = Util:GetIdByUsername(user)
            if target ~= nil then
                Users[target] = CommandsMaster.PermissionLevel.Mod
            end
        end
    
        for _, user in ipairs(settings.Admins) do
            local target = Util:GetIdByUsername(user)
            if target ~= nil then
                Users[target] = CommandsMaster.PermissionLevel.Admin
            end
        end
    
        for _, user in ipairs(settings.Owners) do
            local target = Util:GetIdByUsername(user)
            if target ~= nil then
                Users[target] = CommandsMaster.PermissionLevel.Owner
            end
        end

        if settings.AutoRankVisitor then
            for _, player in ipairs(Players:GetPlayers()) do
                if m:GetRank(player.UserId) == nil then
                    Users[player.UserId] = CommandsMaster.PermissionLevel.Visitor
                end
            end

            Players.PlayerAdded:Connect(function (plr)
                if m:GetRank(plr.UserId) == nil then
                    Users[plr.UserId] = CommandsMaster.PermissionLevel.Visitor
                end
            end)
        end
    end
})


function m:GetRank(user)
    assert(tonumber(user), "Value " .. tostring(user) .. " cannot be turned into a number.\n" .. debug.traceback())
    assert(Util:GetNameByUserId(user), tostring(user) .. " is not a valid user id!\n" .. debug.traceback())
    return Users[user]
end

function m:SetRank(user, rank)
    assert(tonumber(user), "Value " .. tostring(user) .. " cannot be turned into a number.\n" .. debug.traceback())
    assert(rank == 0 or rank == 1 or rank == 2 or rank == 3 or rank == 4, "Value " .. tostring(rank) ..  " is not a rank object!\n" .. debug.traceback())
    assert(Util:GetNameByUserId(user), tostring(user) .. " is not a valid user id!\n" .. debug.traceback())

    Users[user] = rank
end




return m