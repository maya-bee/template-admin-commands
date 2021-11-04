local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Util = require(game:GetService("ReplicatedStorage"):WaitForChild("GRPeeAdminModules"):WaitForChild("Utility"))
local Events = Util.Event
local plr = Players.LocalPlayer
local PlayerGui = plr:WaitForChild("PlayerGui")
local MainGui = PlayerGui:WaitForChild("GRPeeUI")
local notificationGui = MainGui:WaitForChild("NotificationContainer") 


-- General

local function MakeDraggable(Element)
    local originalPosition = Element.Position
    local dragging = false
    local dragStart = Vector2.new()

    Element.Active = true

    local function MoveUI(inputObject)
        local inputObjectPosition = Vector2.new(inputObject.Position.X, inputObject.Position.Y)
        local delta = inputObjectPosition - dragStart
        Element.Position = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset + delta.X, originalPosition.Y.Scale, originalPosition.Y.Offset + delta.Y)
    end

    local function WithinBounds(pos)
        local y_cond = Element.AbsolutePosition.Y <= pos.Y and pos.Y <= Element.AbsolutePosition.Y + Element.AbsoluteSize.Y
        local x_cond = Element.AbsolutePosition.X <= pos.X and pos.X <= Element.AbsolutePosition.X + Element.AbsoluteSize.X
    
        return (y_cond and x_cond)
    end

    UserInputService.InputBegan:Connect(function(input)
        if not dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            if WithinBounds(input.Position) then
                dragging = true
                originalPosition = Element.Position
                dragStart = Vector2.new(input.Position.X, input.Position.Y)
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            MoveUI(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
        end 
    end)
end

local function MakeDraggableMoveParent(Element)
    local originalPosition = Element.Parent.Position
    local dragging = false
    local dragStart = Vector2.new()

    Element.Active = true

    local function MoveUI(inputObject)
        local inputObjectPosition = Vector2.new(inputObject.Position.X, inputObject.Position.Y)
        local delta = inputObjectPosition - dragStart
        Element.Parent.Position = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset + delta.X, originalPosition.Y.Scale, originalPosition.Y.Offset + delta.Y)
    end

    local function WithinBounds(pos)
        local y_cond = Element.AbsolutePosition.Y <= pos.Y and pos.Y <= Element.AbsolutePosition.Y + Element.AbsoluteSize.Y
        local x_cond = Element.AbsolutePosition.X <= pos.X and pos.X <= Element.AbsolutePosition.X + Element.AbsoluteSize.X
    
        return (y_cond and x_cond)
    end

    UserInputService.InputBegan:Connect(function(input)
        if not dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            if WithinBounds(input.Position) then
                dragging = true
                originalPosition = Element.Parent.Position
                dragStart = Vector2.new(input.Position.X, input.Position.Y)
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            MoveUI(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
        end 
    end)
end

-- Notifications

local NotificationQueue = {}
local PlayingTweens = {}

local NotificationDisplayTime = 4 -- in seconds

local function PositionElements()
    for _, notification in ipairs(notificationGui:GetChildren()) do
        if notification:IsA("Frame") then
            if notification:GetAttribute("Killing") then
                continue
            end

            local position = table.find(NotificationQueue, notification)
            print(position)

            if PlayingTweens[notification] then
                PlayingTweens[notification]:Cancel()
                PlayingTweens[notification] = nil
            end

            local finalPos = UDim2.new(0.5, 0, 0.3, position * -(notification.AbsoluteSize.Y + 5))
            if finalPos.Y.Scale < 0 then
                coroutine.wrap(function()
                    notification:SetAttribute("Killing", true)

                    local tween = TweenService:Create(notification, TweenInfo.new(), {Position = UDim2.new(0.5, 0, -1, 0)})
                    tween:Play()

                    tween.Completed:Wait()

                    notification:Destroy()
                    table.remove(NotificationQueue, position)
                end)()
            
                continue
            end

            PlayingTweens[notification] = TweenService:Create(notification, TweenInfo.new(0.1), {Position = finalPos})
            PlayingTweens[notification]:Play()
        end
    end
    
end

Events:Get("Notification").OnClientEvent:Connect(function(msg)
    local notification = {GUI = notificationGui.Template.Notification:Clone(); Time = -5;}
    notification.GUI.message.Text = msg
    notification.GUI.Visible = true
    notification.GUI.Parent = notificationGui
    table.insert(NotificationQueue, 1, notification.GUI)

    PositionElements()

    coroutine.wrap(function()
        local tween = TweenService:Create(notification.GUI.BarBackground.Bar, TweenInfo.new(NotificationDisplayTime, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,1,0)})
        tween:Play()
        tween.Completed:Wait()

        if notification.GUI:GetAttribute("Killing") then
            return
        end

        notification.GUI:SetAttribute("Killing", true)

        PlayingTweens[notification.GUI] = TweenService:Create(notification.GUI, TweenInfo.new(), {Position = UDim2.new(0.5, 0, -2, 0)})
        PlayingTweens[notification.GUI]:Play()
        
        PlayingTweens[notification.GUI].Completed:Wait()

        notification.GUI:Destroy()
        table.remove(NotificationQueue, table.find(NotificationQueue, notification.GUI))
    end)()
end)

-- Alerts

Events:Get("AlertPlayer").OnClientEvent:Connect(function(msg)
    local AlertUI = MainGui.Alert:Clone()
    AlertUI.Parent = MainGui
    AlertUI.Visible = true
    AlertUI.message.Text = msg
    MakeDraggableMoveParent(AlertUI.topBar)
end)

-- General stuff

MainGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    PositionElements()
end)