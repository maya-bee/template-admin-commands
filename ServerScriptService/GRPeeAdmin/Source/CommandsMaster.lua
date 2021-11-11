local m = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("GRPeeAdminModules"):WaitForChild("Utility"))
local PermissionsHandler = require(script.Parent.PermissionsHandler)
local Players = game:GetService("Players")
local enums = require(ReplicatedStorage:WaitForChild("GRPeeAdminModules"):WaitForChild("Enumerators"))
local ServerScriptService = game:GetService("ServerScriptService")

local CompiledCommands = {}
local Initialized = false

local function DeepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = DeepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

function m.Initialize()
	if not Initialized then
		Initialized = true
		for _, command in ipairs(script.Parent.Commands:GetChildren()) do
			local LoadedCommand = require(command)
			if LoadedCommand.Active then
				CompiledCommands[LoadedCommand.Name:lower()] = LoadedCommand
				for _, alias in ipairs(LoadedCommand.Aliases) do
					CompiledCommands[alias:lower()] = LoadedCommand
				end
			end
		end
	end
end

function m:GetCommands()
	return CompiledCommands
end

-- Checks the arguments of the command to make sure everything is right.
-- Also checks to make sure the player is allowed to run the command.
-- If everything is right, it runs the command.
-- Returns WillError (boolean), finalargs (table [this table is all the arguments "converted" into what they actually are: so usernames turn 
-- into player objects, numbers into integers, etc.]) and ErrorInformation (table [information for the error handler])
function m:CheckArguments(plr, cmd, args)
	local finalargs = {}
	local WillError = false
	local ErrorInformation = {}

	local permsLevel = cmd.PermissionLevel

	if permsLevel == enums.PermissionLevel.Custom then
		local canUse = cmd.OnPermissionCheck(plr, PermissionsHandler:GetRank(plr.UserId))
		if not canUse then
			ErrorInformation = {
				Type = enums.FailureType.InvalidPerms;
				ArgumentNumber = nil;
				Argument = nil;
				ProvidedArgument = "None";
			}
			WillError = true
			return WillError, finalargs, ErrorInformation
		end
	elseif PermissionsHandler:GetRank(plr.UserId) < permsLevel then
		ErrorInformation = {
			Type = enums.FailureType.InvalidPerms;
			ArgumentNumber = nil;
			Argument = nil;
			ProvidedArgument = "None";
		}
		WillError = true
		return WillError, finalargs, ErrorInformation
	end

	for num, argumentInfo in ipairs(cmd.Arguments) do
		if args[num] ~= nil then
			local argType = argumentInfo.Type
			if argType == enums.Arguments.UsernameInGame then
				local target = Util:GetPlayerFromPartialString(args[num])
				if not target then -- Invalid argument.
					WillError = true

					ErrorInformation = {
						Type = enums.FailureType.InvalidArgs;
						ArgumentNumber = num;
						Argument = argumentInfo;
						ProvidedArgument = args[num];
					}
				end
				finalargs[num] = target
			end

			if argType == enums.Arguments.DisplayNameInGame then
				local target = Util:GetPlayerFromPartialStringDisplayNames(args[num])
				if not target then
					WillError = true
					ErrorInformation = {
						Type = enums.FailureType.InvalidArgs;
						ArgumentNumber = num;
						Argument = argumentInfo;
						ProvidedArgument = args[num];
					}
				end

				finalargs[num] = target
			end

			if argType == enums.Arguments.Username then
				local target = Util:GetIdByUsername(args[num])
				if not target then
					WillError = true
					ErrorInformation = {
						Type = enums.FailureType.InvalidArgs;
						ArgumentNumber = num;
						Argument = argumentInfo;
						ProvidedArgument = args[num];
					}
				end

				finalargs[num] = args[num]
			end

			if argType == enums.Arguments.UserId then
				local target = Util:GetNameByUserId(args[num])
				if not target then
					WillError = true
					ErrorInformation = {
						Type = enums.FailureType.InvalidArgs;
						ArgumentNumber = num;
						Argument = argumentInfo;
						ProvidedArgument = args[num];
					}
				end

				finalargs[num] = args[num]
			end

			if argType == enums.Arguments.Number then
				local target = tonumber(args[num])
				if not target then
					WillError = true
					ErrorInformation = {
						Type = enums.FailureType.InvalidArgs;
						ArgumentNumber = num;
						Argument = argumentInfo;
						ProvidedArgument = args[num];
					}
				end

				finalargs[num] = target or args[num]
			end

			if argType == enums.Arguments.Text then
				local target = tostring(args[num])
				if not target then
					WillError = true
					ErrorInformation = {
						Type = enums.FailureType.InvalidArgs;
						ArgumentNumber = num;
						Argument = argumentInfo;
						ProvidedArgument = args[num];
					}
				end

				finalargs[num] = target or args[num]
			end

			if argType == enums.Arguments.Boolean then
				local target = args[num]
				if target == "true" then
					target = true
				elseif target == "false" then
					target = false
				else
					WillError = true
					ErrorInformation = {
						Type = enums.FailureType.InvalidArgs;
						ArgumentNumber = num;
						Argument = argumentInfo;
						ProvidedArgument = args[num];
					}
				end

				finalargs[num] = target or args[num]
			end

			if argType == enums.Arguments.Any then
				finalargs[num] = args[num]
			end
		else -- They are missing an argument. Check to see if the argument was necessary, and error if it was.
			if argumentInfo.Necessity == enums.Necessity.Required then
				WillError = true

				ErrorInformation = {
					Type = enums.FailureType.MissingArgs;
					ArgumentNumber = num;
					Argument = argumentInfo;
					ProvidedArgument = "None";
				}
			end
			-- If the argument was optional, just continue
		end
	end

	return WillError, finalargs, ErrorInformation
end

Util.Event:GetOrCreateFunction("GetCommands").OnServerInvoke = function(plr)
	local cmds = {}
	local alreadyAddedNames = {}
	for _, command in pairs(m:GetCommands()) do
		if table.find(alreadyAddedNames, command.Name) then
			continue
		end

		local new = {}
		new.Arguments = command.Arguments
		new.Name = command.Name
		new.PermissionLevel = command.PermissionLevel

		if PermissionsHandler:GetRank(plr.UserId) > new.PermissionLevel then -- make sure theyre actually allowed to run and see that command
			table.insert(cmds, new)
			table.insert(alreadyAddedNames, command.Name)
		end
	end

	table.sort(cmds, function(a, b)
		return a.Name < b.Name
	end)

	return cmds
end

Util.Event:GetOrCreateFunction("RunCommand").OnServerInvoke = function(plr, command)
	if type(command) ~= "table" then return false end
	local target = m:GetCommands()[command.Name]
	if target then
		
		-- ok this if statement looks really bad so heres what it means
		-- if all the correct data is there, and all the arguments are there, then proceed
		if (command and command.Arguments) and (#command.Arguments == #target.Arguments) then

			local WillError = false
			local args = command.Arguments
			local finalargs = {}
			local ErrorInformation = {}

			
			WillError, finalargs, ErrorInformation = m:CheckArguments(plr, target, args)

            if WillError then
                target.Error(plr, args, ErrorInformation)
                return false
            end

            target.Function(plr, finalargs)
            return true
		end
		Util.Event:Fire("Notification", plr, "Not all data was present. Make sure to fill out all the necessary argument fields.")
		return false
	else
		Util.Event:Fire("Notification", plr, "Not a real command.")
		return false
	end
end

return m
