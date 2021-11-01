local m = {}
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

m.PermissionLevel = {
	Custom = -1;
	Visitor = 100;
	Mod = 200;
	Admin = 300;
	Owner = 400;
}

m.Arguments = {
	UsernameInGame = 0;
	DisplayNameInGame = 1;
	Username = 2;
	UserId = 3;
	Number = 4;
	Text = 5;
	Boolean = 6;
	Any = 7;
}

m.Necessity = {
	Required = 0;
	Optional = 1;
}

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
				CompiledCommands[LoadedCommand.Name] = LoadedCommand
				for _, alias in ipairs(LoadedCommand.Aliases) do
					CompiledCommands[alias] = LoadedCommand
				end
			end
		end
	end
end

function m:GetCommands()
	return CompiledCommands
end

return m
