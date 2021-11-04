local s = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(game:GetService("ReplicatedStorage"):WaitForChild("GRPeeAdminModules"):WaitForChild("Utility"))
local Events = Util.Event
local DatastoreService = game:GetService("DataStoreService")

local AllScopes = Instance.new("DataStoreOptions")
AllScopes.AllScopes = true

local GRPeeData = DatastoreService:GetDataStore("GRPeeAdminData", "", AllScopes)



return s