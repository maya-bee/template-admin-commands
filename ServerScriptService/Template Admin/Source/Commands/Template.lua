
local CommandsMaster = require(script.Parent.Parent.CommandsMaster)
local command = {}
----------------------


-- What is the name of your command.
command.Name = ""

-- What are some other names for your command?
command.Aliases = {""}

-- What permission levels do you need for this command?
command.PermissionLevel = CommandsMaster.PermissionLevel.Mod

-- What does your command do? Make this short and concise.
command.Description = ""

-- Appears in the commands list. Provide a username in a string. 
command.Credits = {"Roblox", "Builderman"}

-- When someone says your command in chat, should it show to other players?
command.ShowInChat = true

-- You can add or remove arguments from this table. Make sure to number them in the correct order you want.
command.Arguments = {
    {
        Type = CommandsMaster.Arguments.Any,
        Necessity = CommandsMaster.Necessity.Required
    },
    {
        Type = CommandsMaster.Arguments.Any,
        Necessity = CommandsMaster.Necessity.Optional
    },
}

-- What does your command do?
command.Function = function (speaker, args)
    print("User " .. speaker.Name .. " sent my command with the arguments:", args)
end

-- What happens when someone types in your command incorrectly? For example, they forgot an argument.
command.Error = function (speaker, args)
    print("Uh oh! User " .. speaker.Name .. " made a mistake. These were their arguments:", args)
end


----------------------
return command