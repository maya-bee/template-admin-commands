
local CommandsMaster = require(script.Parent.Parent.CommandsMaster)
local command = {}
----------------------


-- What is the name of your command.
command.Name = "mycommand"

-- Is your command active?
command.Active = false

-- Does your command show in the commands list?
command.ShowInList = false

-- What are some other names for your command?
command.Aliases = {"mycmd", "myCommand", "myCmd"}

-- What permission levels do you need for this command?
command.PermissionLevel = CommandsMaster.PermissionLevel.Custom

-- What does your command do? Make this short and concise.
command.Description = "This command prints to the console."

-- Appears in the commands list. Provide a username in a string. 
command.Credits = {"Maya70i"}

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

-- Whenever we check to see if the speaker is allowed to run this command, the below function will fire.
-- THE BELOW FUNCTION WILL ONLY FIRE IF command.PermissionLevel IS SET TO CUSTOM!!!!!
command.OnPermissionCheck = function (speaker, speakerPermissionLevel)
    print("The speaker (" .. speaker.Name .. ") had the permission level of " .. speakerPermissionLevel)
end


----------------------
return command