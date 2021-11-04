local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local ClientPack = script:WaitForChild("ClientPack")


ClientPack.GRPeeStarterPlayer.Disabled = false
ClientPack.GRPeeStarterPlayer.Parent = plr:WaitForChild("PlayerScripts")

ClientPack.GRPeeUI.Disabled = false
ClientPack.GRPeeUI.Parent = plr:WaitForChild("PlayerScripts")

script.GRPeeUI.Parent = plr:WaitForChild("PlayerGui")

wait()
script:Destroy()