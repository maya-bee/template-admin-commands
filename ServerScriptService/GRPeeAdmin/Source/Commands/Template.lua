local ErrorHandler = require(game:GetService("ServerStorage"):WaitForChild("GRPeeAdminModulesServer").ErrorHandler)
local Enumerators = require(game:GetService("ReplicatedStorage"):WaitForChild("GRPeeAdminModules"):WaitForChild("Enumerators"))
local Sounds = require(game:GetService("ReplicatedStorage"):WaitForChild("GRPeeAdminModules"):WaitForChild("Sounds"))
local command = {}
----------------------

local Sounds = require(game:GetService("ReplicatedStorage"):WaitForChild("GRPeeAdminModules"):WaitForChild("Sounds"))
local Util = require(game:GetService("ReplicatedStorage"):WaitForChild("GRPeeAdminModules"):WaitForChild("Utility"))

-- What is the name of your command.
command.Name = ""

-- Is your command active?
command.Active = false

-- Does your command show in the commands list?
command.ShowInList = true

-- What are some other names for your command?
command.Aliases = {""}

-- What permission levels do you need for this command?
command.PermissionLevel = Enumerators.PermissionLevel.JrMod

-- What does your command do? Make this short and concise.
command.Description = ""

-- Appears in the commands list. Provide a username in a string. 
command.Credits = {"Maya70i"}

-- When someone says your command in chat, should it show to other players?
command.ShowInChat = true

-- You can add or remove arguments from this table. Make sure to number them in the correct order you want.
command.Arguments = {
    {
        Type = Enumerators.Arguments.UsernameInGame,
        Necessity = Enumerators.Necessity.Required
    },
}

-- What does your command do?
command.Function = function (speaker, args)

end 

-- What happens when someone types in your command incorrectly? For example, they forgot an argument.
command.Error = function (speaker, args, errorinfo)
    ErrorHandler(speaker, command, args, errorinfo)
end

-- Whenever we check to see if the speaker is allowed to run this command, the below function will fire.
-- THE BELOW FUNCTION WILL ONLY FIRE IF command.PermissionLevel IS SET TO CUSTOM!!!!!
-- **IT MUST RETURN A BOOLEAN VALUE! THIS DECIDES IF THE USER IS ALLOWED TO USE THE COMMAND.**
command.OnPermissionCheck = function (speaker, speakerPermissionLevel)
    
end


----------------------
return command