local Settings = require(script.Parent.Settings)
local Util = require(script.Parent.Source.Client.Utility)
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- HANDLE SERVER STUFF

local stuff = Instance.new("Folder")
stuff.Name = "GRPeeAdminModules"
stuff.Parent = ReplicatedStorage

local serverStuff = Instance.new("Folder")
serverStuff.Name = "GRPeeAdminModulesServer"
serverStuff.Parent = ServerStorage

for _, v in ipairs(script.Parent.Source.ServerModules:GetChildren()) do
    v.Parent = serverStuff
end

for _, v in ipairs(script.Parent.Source.Client:GetChildren()) do
    v.Parent = stuff
end

script.Parent.Source.Client:Destroy()

script.Parent.Source.ServerModules:Destroy()

local ChatHandler = require(script.Parent.Source.ChatHandler)
local PermissionsHandler = require(script.Parent.Source.PermissionsHandler)
ChatHandler(Settings.Prefix)
PermissionsHandler(Settings)

-- HANDLE CLIENT STUFF

require(stuff.Sounds)

-- HANDLE UI



-- If you joined quick, none of this stuff will load. Below handles quick joiners.

for _, plr in ipairs(Players:GetPlayers()) do
    local QuickJoiner = script.Parent.Source.ClientPack.QuickJoiner:Clone()
    local clone = script.Parent.Source.ClientPack:Clone()
    clone.QuickJoiner:Destroy()
    clone.Parent = QuickJoiner
    script.Parent.Source.UI.GRPeeUI:Clone().Parent = QuickJoiner
    QuickJoiner.Parent = plr:WaitForChild("PlayerGui")
end