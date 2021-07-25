local m = {}
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Chat = game:GetService("Chat")
local Prefix = ":"

local ChatService = require(ServerScriptService:WaitForChild("ChatServiceRunner").ChatService)
local CommandsMaster = require(script.Parent.CommandsMaster)
local Util = require(script.Parent.Utility)
CommandsMaster.Initialize()
local Commands = CommandsMaster:GetCommands()

local function CheckForPrefix(message)
    if message:sub(1, Prefix:len()) == Prefix then
        return true, message:sub(Prefix:len() + 1, message:len())
    end

    return false
end

ChatService:RegisterProcessCommandsFunction("__Template-Admin-Register-Commands__", function (speakerName, message, channelName)
    local speaker = ChatService:GetSpeaker(speakerName)
    local args = message:split(" ")
    local HideOverride = false

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

            for num, argumentInfo in ipairs(cmd.Arguments) do
                if args[num] ~= nil then
                    local argType = argumentInfo.Type
                    if argType == CommandsMaster.Arguments.UsernameInGame then
                        local target = Util:GetPlayerFromPartialString(args[num])
                        if not target then -- Invalid argument.
                            WillError = true
                        end
                        finalargs[num] = target
                    end

                    if argType == CommandsMaster.Arguments.DisplayNameInGame then
                        local target = Util:GetPlayerFromPartialStringDisplayNames(args[num])
                        if not target then
                            WillError = true
                        end

                        finalargs[num] = target
                    end
                else -- They are missing an argument. Check to see if the argument was necessary, and error if it was.
                    if argumentInfo.Necessity == CommandsMaster.Necessity.Required then
                        WillError = true
                    end
                    -- If the argument was optional, just continue
                end
            end

            if WillError then
                cmd.Error(speaker, finalargs)
                return (not cmd.ShowInChat) or HideOverride
            end

            cmd.Function(speaker, finalargs)
            return (not cmd.ShowInChat) or HideOverride
        end
    else
        return HideOverride
    end

    return false
end)

return function (prefix)
    Prefix = prefix
    print(Prefix)
end