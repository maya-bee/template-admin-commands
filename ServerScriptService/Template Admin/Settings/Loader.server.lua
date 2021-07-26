local Settings = require(script.Parent)
local ChatHandler = require(script.Parent.Parent.Source.ChatHandler)
local PermissionsHandler = require(script.Parent.Parent.Source.PermissionsHandler)

ChatHandler(Settings.Prefix)
PermissionsHandler(Settings)