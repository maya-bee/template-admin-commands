local m = {}
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

m.PermissionLevel = {
	Visitor = 1;
	Mod = 2;
	Admin = 3;
	Owner = 4;
}

m.Arguments = {
	Username = 0;
	UserId = 1;
	Number = 2;
	Text = 3;
	Boolean = 4;
	Any = 5;
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
			CompiledCommands[command.Name] = LoadedCommand
			for _, alias in ipairs(LoadedCommand.Aliases) do
				CompiledCommands[alias] = LoadedCommand
			end
		end
	end
end

function m:GetCommands()
	return CompiledCommands
end

return m
