local util = {}
local Players = game:GetService("Players")

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

return util