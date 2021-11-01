local m = {}
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Chat = game:GetService("Chat")
local Prefix = ":"

local ChatService = require(ServerScriptService:WaitForChild("ChatServiceRunner").ChatService)
local CommandsMaster = require(script.Parent.CommandsMaster)
local Util = require(script.Parent.Utility)
local PermissionsHandler = require(script.Parent.PermissionsHandler)
CommandsMaster.Initialize()
local Commands = CommandsMaster:GetCommands()


-- Check to see if the message has our prefix. Returns boolean.
local function CheckForPrefix(message)
    if message:sub(1, Prefix:len()) == Prefix then
        return true, message:sub(Prefix:len() + 1, message:len())
    end

    return false
end

--[[

    Hey there! If you have a custom chat system that doesn't use Roblox's chat events
    and are wondering how you can set this up, it's quite simple.

    Just make sure that the function below, OnChatted, runs with the following arguments:

        - The speaker who said the message. This is a Player object.
        - The message itself. This should be unfiltered.

    Then, delete that function near the bottom of the script. It has a comment above it, so you'll
    know which one. :)

]]

-- Detects for commands. Returns boolean if the message should be hidden from other players or not.
local function OnChatted(speaker, message)
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

            local permslevel = cmd.PermissionLevel

            if permslevel == CommandsMaster.PermissionLevel.Custom then
                cmd.OnPermissionCheck(speaker, PermissionsHandler:GetRank(speaker.UserId))
            elseif PermissionsHandler:GetRank(speaker.UserId) < permslevel then
                return HideOverride
            end
            
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

                    if argType == CommandsMaster.Arguments.Username then
                        local target = Util:GetIdByUsername(args[num])
                        if not target then
                            WillError = true
                        end

                        finalargs[num] = args[num]
                    end

                    if argType == CommandsMaster.Arguments.UserId then
                        local target = Util:GetNameByUserId(args[num])
                        if not target then
                            WillError = true
                        end

                        finalargs[num] = args[num]
                    end

                    if argType == CommandsMaster.Arguments.Number then
                        local target = tonumber(args[num])
                        if not target then
                            WillError = true
                        end

                        finalargs[num] = target or args[num]
                    end

                    if argType == CommandsMaster.Arguments.Text then
                        local target = tostring(args[num])
                        if not target then
                            WillError = true
                        end

                        finalargs[num] = target or args[num]
                    end

                    if argType == CommandsMaster.Arguments.Boolean then
                        local target = args[num]
                        if target == "true" then
                            target = true
                        elseif target == "false" then
                            target = false
                        else
                            WillError = true
                        end

                        finalargs[num] = target or args[num]
                    end

                    if argType == CommandsMaster.Arguments.Any then
                        finalargs[num] = args[num]
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

    return HideOverride
end

-- If you have a custom chat system, read the comment near the top of the script.
-- If your custom chat system doesn't use the default Roblox Lua ChatService, then delete the below.
ChatService:RegisterProcessCommandsFunction("__Template-Admin-Register-Commands__", function (speakerName, message)
    return OnChatted(Players:FindFirstChild(speakerName), message)
end)

return function (prefix)
    Prefix = prefix
    print(Prefix)
end