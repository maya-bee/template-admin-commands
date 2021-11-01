
local CommandsMaster = require(script.Parent.Parent.CommandsMaster)
local command = {}
----------------------


-- What is the name of your command.
command.Name = "hello"

-- Is your command active?
command.Active = false

-- Does your command show in the commands list?
command.ShowInList = false

-- What are some other names for your command?
command.Aliases = {"hey", "hi", "yo"}

-- What permission levels do you need for this command?
command.PermissionLevel = CommandsMaster.PermissionLevel.Visitor

-- What does your command do? Make this short and concise.
command.Description = "Say hello to the computer!"

-- Appears in the commands list. Provide a username in a string. 
command.Credits = {"Maya70i"}

-- When someone says your command in chat, should it show to other players?
command.ShowInChat = true

-- You can add or remove arguments from this table. Make sure to number them in the correct order you want.
command.Arguments = {
    {
        Type = CommandsMaster.Arguments.UsernameInGame,
        Necessity = CommandsMaster.Necessity.Required
    },
}

-- What does your command do?
command.Function = function (speaker, args)
    if args[1] then
        print("Hello world! [" .. args[1].Name .. "]")
    else
        print("Hello world!")
    end
end 

-- What happens when someone types in your command incorrectly? For example, they forgot an argument.
command.Error = function (speaker, args)
    print(":(")
end

-- Whenever we check to see if the speaker is allowed to run this command, the below function will fire.
-- THE BELOW FUNCTION WILL ONLY FIRE IF command.PermissionLevel IS SET TO CUSTOM!!!!!
-- **IT MUST RETURN A BOOLEAN VALUE! THIS DECIDES IF THE USER IS ALLOWED TO USE THE COMMAND.**
command.OnPermissionCheck = function (speaker, speakerPermissionLevel)
    
end


----------------------
return command