local m = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
