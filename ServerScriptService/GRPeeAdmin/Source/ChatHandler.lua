local m = {}
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Chat = game:GetService("Chat")
local Prefix = ":"

local ChatService = require(ServerScriptService:WaitForChild("ChatServiceRunner").ChatService)
local CommandsMaster = require(script.Parent.CommandsMaster)
local Util = require(game:GetService("ReplicatedStorage"):WaitForChild("GRPeeAdminModules"):WaitForChild("Utility"))
local Enumerators = require(game:GetService("ReplicatedStorage"):WaitForChild("GRPeeAdminModules"):WaitForChild("Enumerators"))
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

-- If you have a custom chat system, read the comment near the top of the script.
-- If your custom chat system doesn't use the default Roblox Lua ChatService, then delete the below.
ChatService:RegisterProcessCommandsFunction("__Template-Admin-Register-Commands__", OnChatted)

return function (prefix)
    Prefix = prefix
end