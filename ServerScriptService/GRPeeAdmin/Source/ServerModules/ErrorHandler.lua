local Util = require(game:GetService("ReplicatedStorage"):WaitForChild("GRPeeAdminModules"):WaitForChild("Utility"))
local Enumerators = require(game:GetService("ReplicatedStorage"):WaitForChild("GRPeeAdminModules"):WaitForChild("Enumerators"))
local Events = Util.Event

Events:GetOrCreate("Notification")

return function (speaker, command, args, errorInfo)
    local str = ""
    
    if errorInfo.Type == Enumerators.FailureType.MissingArgs then
        str = "Missing argument " .. errorInfo.ArgumentNumber .. "!"
    elseif errorInfo.Type == Enumerators.FailureType.InvalidPerms then
        local permissionName = "[Redacted]"
        for i, v in pairs(Enumerators.PermissionLevel) do
            if v == command.PermissionLevel then
                permissionName = i
                break
            end
        end
        str = "You must be of the rank " .. permissionName .. " or higher to run this command!"
    elseif errorInfo.Type == Enumerators.FailureType.InvalidArgs then
        local argumentType = "[what]"
        for i, v in pairs(Enumerators.Arguments) do
            if errorInfo.Argument.Type == v then
                argumentType = i
            end
        end
        str = "Argument " .. errorInfo.ArgumentNumber .. " must be a(n) " .. argumentType .. "!"
    end

    Events:Fire("Notification", speaker, str)
end