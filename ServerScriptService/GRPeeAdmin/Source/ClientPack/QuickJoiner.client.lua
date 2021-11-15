local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local pscripts = plr:WaitForChild("PlayerScripts")
local pgui = plr:WaitForChild("PlayerGui")
local ClientPack = script:WaitForChild("ClientPack")


ClientPack.GRPeeStarterPlayer.Disabled = false
if not pscripts:FindFirstChild("GRPeeStarterPlayer") then
    ClientPack.GRPeeStarterPlayer.Parent = pscripts
end

ClientPack.GRPeeUIHandler.Disabled = false
if not pscripts:FindFirstChild("GRPeeUIHandler") then
    ClientPack.GRPeeUIHandler.Parent = pscripts
end

if not pgui:FindFirstChild("GRPeeUI") then
    script:WaitForChild("GRPeeUI").Parent = plr.PlayerGui
end

task.wait()
script:Destroy()