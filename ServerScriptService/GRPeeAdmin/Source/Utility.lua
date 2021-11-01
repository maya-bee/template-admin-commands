local util = {}
local Players = game:GetService("Players")

local UsernameCache = {}
local UserIdCache = {}

function util:GetPlayerFromPartialString(str)
    str = str:lower()
    for _, player in ipairs(Players:GetPlayers()) do
        local name = player.Name:lower()
        if name:sub(1, str:len()) == str then
            return player
        end
    end

    return nil
end

function util:GetPlayerFromPartialStringDisplayNames(str)
    str = str:lower()
    for _, player in ipairs(Players:GetPlayers()) do
        local name = player.DisplayName:lower()
        if name:sub(1, str:len()) == str then
            return player
        end
    end

    return nil
end

function util:GetIdByUsername(username)
    local FromCache = UsernameCache[username]
    if FromCache ~= nil then
        return FromCache
    end

    local player = Players:FindFirstChild(username)
    if player then
        UsernameCache[username] = player.UserId
        return player.UserId
    end

    local id
    pcall(function ()
        id = Players:GetUserIdFromNameAsync(username)
    end)

    UsernameCache[username] = id
    return id
end

function util:GetNameByUserId(id)
    local FromCache = UserIdCache[id]
    if FromCache ~= nil then
        return FromCache
    end

    local player = Players:GetPlayerByUserId(id)
    if player then
        UserIdCache[id] = player.Name
        return player.UserId
    end

    local plr
    pcall(function ()
        plr = Players:GetUserIdFromNameAsync(id)
    end)

    UserIdCache[id] = plr
    return plr
end

function util:GetUsernameCache()
    return UsernameCache
end

function util:GetUserIdCache()
    return UserIdCache
end

return util