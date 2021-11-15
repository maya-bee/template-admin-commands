local m = {}
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Chat = game:GetService("Chat")
local Prefix = ":"

local ChatService = require(ServerScriptService:WaitForChild("ChatServiceRunner").ChatService)
local CommandsMaster = require(script.Parent.CommandsMaster)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local Util = require(ReplicatedStorage:WaitForChild("GRPeeAdminModules"):WaitForChild("Utility"))
local Events = Util.Event
local Enumerators = require(game:GetService("ReplicatedStorage"):WaitForChild("GRPeeAdminModules"):WaitForChild("Enumerators"))
local PermissionsHandler = require(script.Parent.PermissionsHandler)
CommandsMaster.Initialize()
local Commands = CommandsMaster:GetCommands()

local PlayerSpecificLogs = {}
local debounce = {}

local function ShallowCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

-- Check to see if the message has our prefix. Returns boolean.
local function CheckForPrefix(message)
    if message:sub(1, Prefix:len()) == Prefix then
        return true, message:sub(Prefix:len() + 1, message:len())
    end

    return false
end

-- Detects chats and makes chatlogs work.
local function UserChat(speakerName, message)
    local HideOverride = false
    if message:sub(1, 2) == "/e" then
        HideOverride = true
    end

    local uid = Players:FindFirstChild(speakerName)

    local suc, response = pcall(function()
        return Chat:FilterStringAsync(message, uid, uid)
    end)

    local DissectedMessage

    if suc then
        DissectedMessage = {
            Speaker = speakerName;
            UserId = uid;
            Message = response;
            Timestamp = DateTime.now();
        }
    else
        DissectedMessage = {
            Speaker = speakerName;
            UserId = uid;
            Message = "<i>(Couldn't filter)</i> " .. message;
            Timestamp = DateTime.now();
        }
    end

    if PlayerSpecificLogs[speakerName] == nil then
        PlayerSpecificLogs[speakerName] = {}
    end

    table.insert(PlayerSpecificLogs[speakerName], 1, DissectedMessage)

    return HideOverride    
end

Events:GetOrCreateFunction("RequestLogs").OnServerInvoke = function(user, phrase)
    if table.find(debounce, user) then
        return "stop"
    end

    if PermissionsHandler:GetRank(user.UserId) >= Enumerators.PermissionLevel.Support and phrase then
        table.insert(debounce, user)

        coroutine.wrap(function()
            task.wait(2)
            table.remove(debounce, table.find(debounce, user))
        end)()

        local FoundUser
        for username, messages in pairs(PlayerSpecificLogs) do
            if username:lower():sub(1, phrase:len()) == phrase:lower() then -- if username:sub(1, phrase-length) equals phrase then they were searching for a player
                FoundUser = messages
                break
            end
        end

        if FoundUser then
            return FoundUser
        else -- user doesnt exist, they are likely searching a phrase.
            local messages = {}
            for player, messageLogs in pairs(PlayerSpecificLogs) do
                for _, message in ipairs(messageLogs) do
                    if message.Message:lower():match(phrase:lower()) then
                        table.insert(messages, message)
                    end
                end
            end

            if #messages > 0 then
                return messages
            end

            return nil -- if there are no messages, return nil
        end
    end

    return nil
end


-- Detects for commands. Returns boolean if the message should be hidden from other players or not.
local function OnChatted(speakerName, message)
    local args = message:lower():split(" ")
    local HideOverride = false
    local speaker = Players:FindFirstChild(speakerName)

    if args[1]:sub(1, 2) == "/e" then
        table.remove(args, 1)
        HideOverride = true
    end

    local PrefixFound, updatedmessage = CheckForPrefix(args[1])

    if PrefixFound then -- command found?
        args[1] = updatedmessage
        local cmd = Commands[args[1]]
        if cmd ~= nil then -- command found!
            table.remove(args, 1)
            
            local finalargs = {}
            local WillError = false
            local ErrorInformation = {}

            -- Uncomment below whenever you need to threaten Mikel.

            --[[
            if cmd.Name == "hat" and (speaker.UserId == 148103779 or speaker.UserId == 699526) then -- mikel and  "Finalargs" user id
                cmd.Error(speaker, finalargs)
            end
            ]]

            WillError, finalargs, ErrorInformation = CommandsMaster:CheckArguments(speaker, cmd, args)

            if WillError then
                cmd.Error(speaker, args, ErrorInformation)
                return (not cmd.ShowInChat) or HideOverride
            end

            cmd.Function(speaker, finalargs)
            return (not cmd.ShowInChat) or HideOverride
        end
    else
        return HideOverride
    end

    return HideOverride
end

local function PlayerAdded(player)
    PlayerSpecificLogs[player.Name] = {}
end

do
    for _,plr in ipairs(Players:GetPlayers()) do
        PlayerAdded(plr)
    end
end


-- These two are different functions because thats easier to read.
-- Theoritically, these two functions could be combined. But why would I do that. lol.
ChatService:RegisterProcessCommandsFunction("__Template-Admin-Register-Commands__", OnChatted)
ChatService:RegisterProcessCommandsFunction("__Chatlogs__", UserChat)

Players.PlayerAdded:Connect(PlayerAdded)

return function (prefix)
    Prefix = prefix
end