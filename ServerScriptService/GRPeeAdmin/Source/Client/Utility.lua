local util = {}
util.Event = {}

local Players = game:GetService("Players")

local UsernameCache = {}
local UserIdCache = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EventFolder = ReplicatedStorage:FindFirstChild("GRPeeAdminEvents")
if not EventFolder then
    EventFolder = Instance.new("Folder")
    EventFolder.Name = "GRPeeAdminEvents"
    EventFolder.Parent = ReplicatedStorage
end

function util:GetPlayerFromPartialString(str)
    str = str:lower()
    for _, player in ipairs(Players:GetPlayers()) do
        local name = player.Name:lower()
        if name:sub(1, str:len()) == str then
            return player
        end
    end

    return nil
end

function util:GetPlayerFromPartialStringDisplayNames(str)
    str = str:lower()
    for _, player in ipairs(Players:GetPlayers()) do
        local name = player.DisplayName:lower()
        if name:sub(1, str:len()) == str then
            return player
        end
    end

    return nil
end

function util:GetIdByUsername(username)
    local FromCache = UsernameCache[username]
    if FromCache ~= nil then
        return FromCache
    end

    local player = Players:FindFirstChild(username)
    if player then
        UsernameCache[username] = player.UserId
        return player.UserId
    end

    local id
    pcall(function ()
        id = Players:GetUserIdFromNameAsync(username)
    end)

    UsernameCache[username] = id
    return id
end

function util:GetNameByUserId(id)
    local FromCache = UserIdCache[id]
    if FromCache ~= nil then
        return FromCache
    end

    local player = Players:GetPlayerByUserId(id)
    if player then
        UserIdCache[id] = player.Name
        return player.UserId
    end

    local plr
    pcall(function ()
        plr = Players:GetUserIdFromNameAsync(id)
    end)

    UserIdCache[id] = plr
    return plr
end

function util:GetUsernameCache()
    return UsernameCache
end

function util:GetUserIdCache()
    return UserIdCache
end

---------------------------------------------------------------------

-- Create a new remote event
function util.Event.new(name)
    local e = Instance.new("RemoteEvent")
    e.Name = name
    e.Parent = EventFolder
    return e
end

-- Get remote/bindable events/functions.
function util.Event:Get(name)
    return EventFolder:WaitForChild(name)
end

---------------------------------------------------------------------

-- Create a new remote function
function util.Event.newFunction(name)
    local e = Instance.new("RemoteFunction")
    e.Name = name
    e.Parent = EventFolder
    return e
end

-- Get a remote function. If it doesn't exist, create it.
function util.Event:GetOrCreateFunction(name)
    return EventFolder:FindFirstChild(name) or util.Event.newFunction(name)
end

function util.Event:FireFunction(name, ...)
    local event = EventFolder:WaitForChild(name)
    if event then
        return event:InvokeServer(...)
    end
end

---------------------------------------------------------------------

-- Get a remote event. If it doesn't exist, create it.
function util.Event:GetOrCreate(name)
    return EventFolder:FindFirstChild(name) or util.Event.new(name)
end

function util.Event:Fire(name, player, ...)
    local event = EventFolder:WaitForChild(name)
    if event then
        event:FireClient(player, ...)
    end
end

---------------------------------------------------------------------

-- Create a new bindable event
function util.Event.newBindable(name)
    local e = Instance.new("BindableEvent")
    e.Name = name
    e.Parent = EventFolder
    return e
end

-- Get a bindable event. If it doesn't exist, create it.
function util.Event:GetOrCreateBindable(name)
    return EventFolder:FindFirstChild(name) or util.Event.newBindable(name)
end

-- Get or fire bindable events
function util.Event:GetBindable(name)
    return EventFolder:WaitForChild(name)
end

function util.Event:FireBindable(name, ...)
    local event = EventFolder:WaitForChild(name)
    if event then
        event:Fire(...)
    end
end

---------------------------------------------------------------------

-- Create a new bindable function
function util.Event.newBindableFunction(name)
    local e = Instance.new("BindableFunction")
    e.Name = name
    e.Parent = EventFolder
    return e
end

-- Get a bindable event. If it doesn't exist, create it.
function util.Event:GetOrCreateBindableFunction(name)
    return EventFolder:FindFirstChild(name) or util.Event.newBindableFunction(name)
end

-- Get or fire bindable events
function util.Event:GetBindableFunction(name)
    return EventFolder:WaitForChild(name)
end

function util.Event:FireBindableFunction(name, ...)
    local event = EventFolder:WaitForChild(name)
    if event then
        return event:Invoke(...)
    end
end

---------------------------------------------------------------------

return util