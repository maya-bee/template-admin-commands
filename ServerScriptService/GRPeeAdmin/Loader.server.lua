local Settings = require(script.Parent.Settings)
local ChatHandler = require(script.Parent.Source.ChatHandler)
local PermissionsHandler = require(script.Parent.Source.PermissionsHandler)

ChatHandler(Settings.Prefix)
PermissionsHandler(Settings)