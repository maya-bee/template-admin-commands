local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GroupService = game:GetService("GroupService")
local Util = require(ReplicatedStorage:WaitForChild("GRPeeAdminModules"):WaitForChild("Utility"))
local Enumerators = require(ReplicatedStorage:WaitForChild("GRPeeAdminModules"):WaitForChild("Enumerators"))
local _maid = require(ReplicatedStorage:WaitForChild("GRPeeAdminModules"):WaitForChild("Maid"))
local Events = Util.Event
local plr = Players.LocalPlayer
local PlayerGui = plr:WaitForChild("PlayerGui")
local MainGui = PlayerGui:WaitForChild("GRPeeUI")
local notificationGui = MainGui:WaitForChild("NotificationContainer") 
local Sounds = require(ReplicatedStorage:WaitForChild("GRPeeAdminModules"):WaitForChild("Sounds"))
local DropdownMenu = require(ReplicatedStorage:WaitForChild("GRPeeAdminModules"):WaitForChild("DropdownMenu"))


-- General

local function MakeDraggable(Element)
    local Maid = _maid.new()
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

    Maid.Began = UserInputService.InputBegan:Connect(function(input)
        if not dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            if WithinBounds(input.Position) then
                dragging = true
                originalPosition = Element.Position
                dragStart = Vector2.new(input.Position.X, input.Position.Y)
            end
        end
    end)

    Maid.Changed = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            MoveUI(input)
        end
    end)

    Maid.Ended = UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
        end 
    end)

    Maid.Removed = Element.Parent.ChildRemoved:Connect(function(child)
        if child == Element then
            Element = nil
            Maid:DoCleaning()
        end
    end)
end

local draggingAnElement = false

local function MakeDraggableMoveParent(Element, ...) -- ... are any things we want to make the ui not drag when hovering over
    local Maid = _maid.new()
    local originalPosition = Element.Parent.Position
    local dragging = false
    local dragStart = Vector2.new()
    local deadZones = table.pack(...)

    Element.Active = true

    local function MoveUI(inputObject)
        local inputObjectPosition = Vector2.new(inputObject.Position.X, inputObject.Position.Y)
        local delta = inputObjectPosition - dragStart
        Element.Parent.Position = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset + delta.X, originalPosition.Y.Scale, originalPosition.Y.Offset + delta.Y)
    end

    local function WithinBounds(pos)
        local y_cond = Element.AbsolutePosition.Y <= pos.Y and pos.Y <= Element.AbsolutePosition.Y + Element.AbsoluteSize.Y
        local x_cond = Element.AbsolutePosition.X <= pos.X and pos.X <= Element.AbsolutePosition.X + Element.AbsoluteSize.X

        local hoveringOverDeadZone = false
        for _, v in ipairs(deadZones) do
            local y_cond = v.AbsolutePosition.Y <= pos.Y and pos.Y <= v.AbsolutePosition.Y + v.AbsoluteSize.Y
            local x_cond = v.AbsolutePosition.X <= pos.X and pos.X <= v.AbsolutePosition.X + v.AbsoluteSize.X

            if y_cond and x_cond then
                hoveringOverDeadZone = true
                break
            end
        end

        return (y_cond and x_cond) and (not hoveringOverDeadZone)
    end

    Maid.Began = UserInputService.InputBegan:Connect(function(input)
        if not draggingAnElement and not dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            if WithinBounds(input.Position) then
                dragging = true
                draggingAnElement = true
                originalPosition = Element.Parent.Position
                dragStart = Vector2.new(input.Position.X, input.Position.Y)
            end
        end
    end)

    Maid.Changed = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            MoveUI(input)
        end
    end)

    Maid.Ended = UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            draggingAnElement = false
        end 
    end)

    Maid.Removed = Element.Parent.ChildRemoved:Connect(function(child)
        if child == Element then
            Element = nil
            if dragging then
                draggingAnElement = false
            end
            Maid:DoCleaning()
        end
    end)
end

local function ScaleText(text, divBy)
    local x = MainGui.AbsoluteSize.X --you can also do Y, but I prefer X
            
    text.TextSize = math.ceil(x / divBy)
end

-- Notifications

local NotificationQueue = {}
local PlayingTweens = {}

local function PositionElements()
    for _, notification in ipairs(notificationGui:GetChildren()) do
        if notification:IsA("Frame") then
            if notification:GetAttribute("Killing") then
                continue
            end

            local position = 1

            if not notification:GetAttribute("Important") then
                position = table.find(NotificationQueue, notification)
            end
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

-- Length is in seconds btw
local function SendNotification(msg, length)
    length = length or 4
    local notification = notificationGui.Template.Notification:Clone()
    notification.Name = "clone"
    notification.message.Text = msg
    notification.Visible = true
    notification.Parent = notificationGui
    table.insert(NotificationQueue, 1, notification)

    if length <= -1 then
        notification:SetAttribute("Important", true) -- it will always be the first notification now
    end

    PositionElements()

    coroutine.wrap(function()
        if length > -1 then
            local tween = TweenService:Create(notification.BarBackground.Bar, TweenInfo.new(length, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,1,0)})
            tween:Play()
            tween.Completed:Wait()

            -- the bar finished tweening: now get rid of notification

            if notification:GetAttribute("Killing") then
                return
            end

            notification:SetAttribute("Killing", true)

            tween = TweenService:Create(notification, TweenInfo.new(), {Position = UDim2.new(0.5, 0, -1, 0)})
            tween:Play()

            tween.Completed:Wait()

            notification:Destroy()
            table.remove(NotificationQueue, table.find(NotificationQueue, notification))
            notification = nil
        end
    end)()

    return function () -- this function immediately kills the notification when called. for infinite notifications
        coroutine.wrap(function()
            notification:SetAttribute("Killing", true)

            local tween = TweenService:Create(notification, TweenInfo.new(), {Position = UDim2.new(0.5, 0, -1, 0)})
            tween:Play()
            
            tween.Completed:Wait()

            notification:Destroy()
            table.remove(NotificationQueue, table.find(NotificationQueue, notification))
            notification = nil
        end)()
    end
end

Events:Get("Notification").OnClientEvent:Connect(SendNotification)

-- More command panel
local function OpenCommandPanel(presetFields)
    local Commands = Events:FireFunction("GetCommands")
    local CmdMaid = _maid.new()
    local ArgMaid = _maid.new()
    CmdMaid.Thing = MainGui.CommandPanel:Clone()
    CmdMaid.Thing.Name = "clone"
    CmdMaid.Thing.Parent = MainGui
    CmdMaid.Thing.Visible = true

    MakeDraggableMoveParent(CmdMaid.Thing.topBar, CmdMaid.Thing.topBar.exitButton)
    local holder = CmdMaid.Thing.holder

    local commandField

    if presetFields and presetFields.Command then
        for _, cmd in ipairs(Commands) do
            if cmd.Name == presetFields.Command then
                commandField = cmd 
                break
            end
        end
    end

    local PlayerField = presetFields and presetFields.Player or nil
    local argumentField = {}

    CmdMaid.Hover = Instance.new("SelectionBox")
    CmdMaid.Hover.Color3 = Color3.new(0,1,0) -- neon green
    CmdMaid.Hover.SurfaceTransparency = 1
    CmdMaid.Hover.Transparency = 0.3
    CmdMaid.Hover.LineThickness = 0.2
    CmdMaid.Hover.Parent = MainGui
    CmdMaid.Hover.Adornee = PlayerField and PlayerField.Character or nil

    -- this is just for the extra player arguments. there should never be more than 3 player targets per command so this is good for now.
    CmdMaid["hoverclone1"] = CmdMaid.Hover:Clone()
    CmdMaid["hoverclone2"] = CmdMaid.Hover:Clone()
    CmdMaid["hoverclone1"].Parent = MainGui
    CmdMaid["hoverclone2"].Parent = MainGui
    CmdMaid["hoverclone1"].Adornee = nil
    CmdMaid["hoverclone2"].Adornee = nil

    -- this notes if the first hoverclone is taken.
    local cloneIsTaken = false
    local playerFieldAffectsAnArgument = false

    local picking = false
    local function PickPlayer(isUsedInNormalArgument, argumentObject)
        CmdMaid.Stepped = nil
        CmdMaid.Alert = {
            Alert = SendNotification("Click on any player to choose them.", -1);
        }
        function CmdMaid.Alert:Destroy() -- this is so the maid knows to run this function when its cleaning up the alert
            self.Alert()
        end
        CmdMaid.HoverOutline = nil
        CmdMaid.Clicked = nil
        picking = true
        
        local target

        CmdMaid.HoverOutline = Instance.new("SelectionBox")
        CmdMaid.HoverOutline.Color3 = Color3.new(1, 1, 1) -- white
        CmdMaid.HoverOutline.SurfaceTransparency = 1
        CmdMaid.HoverOutline.Transparency = 0.3
        CmdMaid.HoverOutline.LineThickness = 0.1
        CmdMaid.HoverOutline.Parent = MainGui
    

        CmdMaid.Stepped = RunService.Heartbeat:Connect(function()
            local location = UserInputService:GetMouseLocation()
            if location then
                local unitRay = workspace.CurrentCamera:ViewportPointToRay(location.X, location.Y )
                local params = RaycastParams.new()
                params.IgnoreWater = true
                params.FilterType = Enum.RaycastFilterType.Blacklist
                local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 5000, params)

                if result and result.Instance then
                    local p = Players:GetPlayerFromCharacter(result.Instance.Parent) or Players:GetPlayerFromCharacter(result.Instance.Parent.Parent)
                    if p then
                        target = p
                        CmdMaid.HoverOutline.Adornee = p.Character
                    end
                end
            end
        end)

        CmdMaid.Clicked = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
            if target and not gameProcessedEvent then
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    CmdMaid.Stepped = nil
                    CmdMaid.Clicked = nil
                    CmdMaid.TouchTap = nil
                    CmdMaid.HoverOutline = nil
                    CmdMaid.Alert = nil
                    if not isUsedInNormalArgument then
                        PlayerField = target
                        CmdMaid.Hover.Adornee = target.Character

                        if playerFieldAffectsAnArgument then
                            argumentField[1] = PlayerField.Name
                        end
                        
                        holder.PlayerField.Title.Text = target.Name
                    else
                        argumentField[isUsedInNormalArgument] = target 
                        argumentObject.Title.Text = target.Name
                    end
                    picking = false
                end
            end
        end)

        CmdMaid.TouchTap = UserInputService.TouchTapInWorld:Connect(function(position, processedByUI)
            if not processedByUI then
                local unitRay = workspace.CurrentCamera:ViewportPointToRay(position.X, position.Y)
                local params = RaycastParams.new()
                params.IgnoreWater = true
                params.FilterType = Enum.RaycastFilterType.Blacklist
                local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 5000, params)

                if result.Instance then
                    local p = Players:GetPlayerFromCharacter(result.Instance.Parent) or Players:GetPlayerFromCharacter(result.Instance.Parent.Parent)
                    if p then
                        CmdMaid.Stepped = nil
                        CmdMaid.Clicked = nil
                        CmdMaid.TouchTap = nil
                        CmdMaid.HoverOutline = nil
                        CmdMaid.Alert = nil
                        if not isUsedInNormalArgument then
                            PlayerField = p
                            CmdMaid.Hover.Adornee = p.Character

                            if playerFieldAffectsAnArgument then
                                argumentField[1] = PlayerField.Name
                            end
                            
                            holder.PlayerField.Title.Text = p.Name
                        else
                            argumentField[isUsedInNormalArgument] = p 
                            argumentObject.Title.Text = p.Name
                        end

                        
                        
                        picking = false
                    end
                end
            end
        end)
    end

    local function OnArgumentFieldChanged()
        print(argumentField, #argumentField, #commandField.Arguments)
        if #argumentField == #commandField.Arguments then
            CmdMaid.Execute = holder.execute.Activated:Connect(function()
                local Success = Events:FireFunction("RunCommand", {
                    Name = commandField.Name;
                    Arguments = argumentField;
                })

                if Success then
                    Sounds.UI.Success:Play()
                else
                    Sounds.UI.Fail:Play()
                end
            end)

            holder.execute.AutoButtonColor = true
            holder.execute.BackgroundColor3 = Color3.fromRGB(255, 78, 78)
        else
            CmdMaid.Execute = nil
            holder.execute.AutoButtonColor = false
            holder.execute.BackgroundColor3 = Color3.fromRGB(140, 140, 140)
        end
    end
    
    local function UpdateArguments() -- update arguments when chosen command is changed
        -- reset everything
        ArgMaid:DoCleaning()
        argumentField = {}
        playerFieldAffectsAnArgument = false

        -- reset the hoverclones
        cloneIsTaken = false
        CmdMaid["hoverclone1"].Adornee = nil
        CmdMaid["hoverclone2"].Adornee = nil

        -- generate arguments from chosen command
        for i, arg in ipairs(commandField.Arguments) do
            if arg.Type == Enumerators.Arguments.Text or arg.Type == Enumerators.Arguments.Username or arg.Type == Enumerators.Arguments.Any then
                ArgMaid[i] = holder.arguments.TemplateBox:Clone()
                ArgMaid[i].PlaceholderText = i .. ".) " .. Enumerators.ArgStrings[arg.Type]

                ArgMaid[i].ClearTextOnFocus = false
                ArgMaid[i].MultiLine = true

                argumentField[i] = "" -- sometimes we want to omit the text in the argument. set it to blank automatically so omitting is possible.
                
                ArgMaid[i].FocusLost:Connect(function()
                    argumentField[i] = ArgMaid[i].Text
                    OnArgumentFieldChanged()
                end)
            elseif arg.Type == Enumerators.Arguments.Number then
                ArgMaid[i] = holder.arguments.TemplateBox:Clone()
                ArgMaid[i].PlaceholderText = i .. ".) Number"

                ArgMaid[i]:GetPropertyChangedSignal("Text"):Connect(function()
                    ArgMaid[i].Text = ArgMaid[i].Text:gsub("[^%d]+", "")
                end)
                
                ArgMaid[i].FocusLost:Connect(function()
                    argumentField[i] = ArgMaid[i].Text
                    OnArgumentFieldChanged()
                end)
            elseif arg.Type == Enumerators.Arguments.UsernameInGame or arg.Type == Enumerators.Arguments.DisplayNameInGame then
                if i == 1 then -- this is what the Player Target dropdown menu is for, so just tell them to use that.
                    playerFieldAffectsAnArgument = true
                    ArgMaid[i] = holder.arguments.TemplateNotice:Clone()
                    ArgMaid[i].Text = i .. ".) Player (select target above)"
                    ArgMaid[i].Parent = holder.arguments
                    ArgMaid[i].Visible = true 
                    continue
                else
                    ArgMaid[i] = holder.arguments.TemplateDropdown:Clone()
                    ArgMaid[i].Text = i .. ".) Player"
                    ArgMaid[i].Parent = holder.arguments
                    ArgMaid[i].Visible = true

                    ArgMaid[i].Activated:Connect(function()
                        ArgMaid[i .. "dropdown"] = nil 
                        if ArgMaid[i .. "dropdown"] then
                            ArgMaid[i .. "dropdown"] = nil 
                            ArgMaid[i].plus.Image = "rbxassetid://7072720824"
                        else
                            ArgMaid[i].plus.Image = "rbxassetid://7072719290"
                            local plrs = {}
                            for _, v in ipairs(Players:GetPlayers()) do
                                table.insert(plrs, v.Name)
                            end
                            table.sort(plrs, function(a,b)
                                return a:lower() < b:lower()
                            end) -- sort alphabetically 
            
                            table.insert(plrs, 1, "Pick Player")
                    
                            ArgMaid[i .. "dropdown"] = DropdownMenu.new(ArgMaid[i], unpack(plrs))
                    
                            ArgMaid[i .. "dropdown"].ChoiceMade = function(number, text, object)
                                if picking then return end
                                ArgMaid[i .. "dropdown"] = nil
                                ArgMaid[i].plus.Image = "rbxassetid://7072720824"
                                if number == 1 then
                                    PickPlayer(i, ArgMaid[i]) -- this just tells PickPlayer to update our button instead of the Player Target thing
                                else
                                    argumentField[i] = Players:FindFirstChild(text)
                                    OnArgumentFieldChanged()
                                    if not cloneIsTaken then
                                        CmdMaid["hoverclone1"].Adornee = argumentField[i]
                                        cloneIsTaken = true
                                    else
                                        CmdMaid["hoverclone2"].Adornee = argumentField[i]
                                    end
                                    
                                    ArgMaid[i].Title.Text = argumentField[i].Name
                                    ArgMaid[i].Title.TextColor3 = Color3.new(1, 1, 1)
                                end
                            end
                            
                            CmdMaid.Dropdown:Open()
                        end
                    end)
                end 
            elseif arg.Type == Enumerators.Arguments.Boolean then
                ArgMaid["booleanDropdown"] = DropdownMenu.new(ArgMaid[i], "True", "False")

                ArgMaid["booleanDropdown"].ChoiceMade = function(number, text, object)
                    ArgMaid[i].plus.Image = "rbxassetid://7072720824"
                    ArgMaid[i].Title.TextColor3 = Color3.new(1, 1, 1)
                    if text == "True" then
                        argumentField[i] = true
                        ArgMaid[i].Title.Text = "True"
                    elseif text == "False" then
                        argumentField[i] = false
                        ArgMaid[i].Title.Text = "False"
                    end

                    OnArgumentFieldChanged()
                    ArgMaid["booleanDropdown"]:Close()
                end

                ArgMaid[i].Activated:Connect(function()
                    -- if its about to become visible, show minus. else, show plus
                    ArgMaid[i].plus.Image = ArgMaid["booleanDropdown"].Visible and "rbxassetid://7072720824" or "rbxassetid://7072719290"
                    ArgMaid["booleanDropdown"]:Toggle()
                end)
            end
            ArgMaid[i].Parent = holder.arguments
            ArgMaid[i].Visible = true

            if arg.Necessity == Enumerators.Necessity.Optional then
                ArgMaid[i].BackgroundColor3 = Color3.fromRGB(170, 255, 255)
            end
        end

        -- hide the player field if it isnt necessary (dont reset it so that the data they left there is still there when it is necessary)
        holder.PlayerField.Visible = playerFieldAffectsAnArgument
        holder.pTitle.Visible = playerFieldAffectsAnArgument

        if playerFieldAffectsAnArgument then
            argumentField[1] = PlayerField and PlayerField.Name or nil
        end

        OnArgumentFieldChanged()
    end

    local names = {}

    for _, cmd in ipairs(Commands) do
        table.insert(names, cmd.Name)
    end
    print(holder.CommandField)
    CmdMaid.CommandDropdown = DropdownMenu.new(holder.CommandField, unpack(names))
    holder.CommandField.Activated:Connect(function()
        -- if its about to become visible, show minus. else, show plus
        holder.CommandField.plus.Image = CmdMaid.CommandDropdown.Visible and "rbxassetid://7072720824" or "rbxassetid://7072719290"
        CmdMaid.CommandDropdown:Toggle()
    end)

    CmdMaid.CommandDropdown.ChoiceMade = function(number, text, object)
        if picking then return end 
        commandField = Commands[number]
        holder.CommandField.Title.Text = text
        holder.CommandField.Title.TextColor3 = Color3.new(1, 1, 1)
        holder.CommandField.plus.Image = "rbxassetid://7072720824"
        CmdMaid.CommandDropdown:Close()
        UpdateArguments()
    end

    holder.PlayerField.Title.Text = PlayerField and PlayerField.Name or "[Player]"
    holder.PlayerField.Activated:Connect(function()
        CmdMaid.Stepped = nil
        CmdMaid.Clicked = nil
        if CmdMaid.Dropdown then -- remove if the dropdown exists (so that it can update when someone joins), else create one
            CmdMaid.Dropdown = nil 
            holder.PlayerField.plus.Image = "rbxassetid://7072720824"
        else
            holder.PlayerField.plus.Image = "rbxassetid://7072719290"

            local plrs = {}
            for _, v in ipairs(Players:GetPlayers()) do
                table.insert(plrs, v.Name)
            end
            table.sort(plrs, function(a,b)
                return a:lower() < b:lower()
            end) -- sort alphabetically 

            table.insert(plrs, 1, "Pick Player")
    
            CmdMaid.Dropdown = DropdownMenu.new(holder.PlayerField, unpack(plrs))
    
            CmdMaid.Dropdown.ChoiceMade = function(number, text, object)
                if picking then return end
                CmdMaid.Dropdown = nil
                holder.PlayerField.plus.Image = "rbxassetid://7072720824"
                if number == 1 then
                    PickPlayer()
                else
                    PlayerField = Players:FindFirstChild(text)
                    CmdMaid.Hover.Adornee = PlayerField and PlayerField.Character or nil
                    holder.PlayerField.Title.Text = PlayerField and PlayerField.Name or "[Player]"

                    if playerFieldAffectsAnArgument then
                        argumentField[1] = PlayerField.Name
                    end
                end
                
            end
            
            CmdMaid.Dropdown:Open()
        end 
    end)

    CmdMaid.Thing.topBar.exitButton.Activated:Connect(function()
        CmdMaid:DoCleaning()
        ArgMaid:DoCleaning()
    end)
end

Events:Get("CommandPanel").OnClientEvent:Connect(OpenCommandPanel)

-- Chatlogs
Events:Get("ShowChatlogs").OnClientEvent:Connect(function(optionalShowPhrase)
    local Maid = _maid.new()
    local LogMaid = _maid.new()
    Maid.Chatlogs = MainGui.Chatlogs:Clone()
    Maid.Chatlogs.Parent = MainGui
    Maid.Chatlogs.Visible = true
    Maid.Chatlogs.Name = "clone"
    MakeDraggableMoveParent(Maid.Chatlogs.topBar, Maid.Chatlogs.topBar.exitButton, Maid.Chatlogs.topBar.refreshButton)

    local function Search()
        local text = Maid.Chatlogs.Entry.Text
        if text ~= "" and not text:match("^%s*$") then -- if there is a message there
            LogMaid:DoCleaning()
            local Messages = Events:FireFunction("RequestLogs", text)

            if Messages == "stop" then
                SendNotification("You're doing this too fast!", 3)
                return
            end

            if Messages then
                SendNotification("Loading chatlogs...", 2)
                for i, msg in ipairs(Messages) do
                    
                    LogMaid["message-" .. i] = Maid.Chatlogs.logs.MessageTemplate:Clone()
                    LogMaid["message-" .. i].Text = "[" .. i .. "] " .. msg.Speaker .. ": " .. msg.Message
                    LogMaid["message-" .. i].Visible = true
                    LogMaid["message-" .. i].Parent = Maid.Chatlogs.logs
                    LogMaid["message-" .. i].Size = UDim2.new(0.98, 0, 0, math.max(20, LogMaid["message-" .. i].TextBounds.Y))
                    
                    LogMaid["message-" .. i].MouseEnter:Connect(function()
                        Maid.Chatlogs.MessageBox.Text = LogMaid["message-" .. i].Text
                    end)
                    
                    LogMaid["message-" .. i].MouseLeave:Connect(function()
                        Maid.Chatlogs.MessageBox.Text = ""
                    end)
                    
                    LogMaid["message-" .. i].TouchTap:Connect(function()
                        Maid.Chatlogs.MessageBox.Text = LogMaid["message-" .. i].Text
                    end)
                end
                SendNotification("Chatlogs loaded!", 2)
            else
                SendNotification("Could not fetch chatlogs for user/phrase \"" .. text .. "\"", 4)
            end
        end
    end

    if optionalShowPhrase then
        Maid.Chatlogs.Entry.Text = optionalShowPhrase
        Search()
    end

    Maid.Chatlogs.topBar.exitButton.Activated:Connect(function()
        LogMaid:DoCleaning() 
        Maid:DoCleaning()
    end)

    Maid.Chatlogs.Entry.FocusLost:Connect(Search)
    Maid.Chatlogs.topBar.refreshButton.Activated:Connect(Search)
end)

-- Group list
local SIZE = Vector2.new(1, 0.15) -- size of uigrid layout

Events:Get("ShowGroups").OnClientEvent:Connect(function(target)
    local GroupsMaid = _maid.new()
    GroupsMaid.Thing = MainGui.GroupsList:Clone()
    GroupsMaid.Thing.Parent = MainGui
    GroupsMaid.Thing.Visible = true
    GroupsMaid.Thing.Name = "clone"
    GroupsMaid.Thing.topBar.title.Text = target.Name .. "'s Groups"
    MakeDraggableMoveParent(GroupsMaid.Thing.topBar, GroupsMaid.Thing.topBar.exitButton)

    for i, group in ipairs(GroupService:GetGroupsAsync(target.UserId)) do
        GroupsMaid[i] = GroupsMaid.Thing.Frame.Template:Clone()
        GroupsMaid[i].Parent = GroupsMaid.Thing.Frame
        GroupsMaid[i].Visible = true
        GroupsMaid[i].Name = "clone"
        GroupsMaid[i].Emblem.Image = group.EmblemUrl
        GroupsMaid[i].GroupName.Text = group.Name
        GroupsMaid[i].RankName.Text = group.Role
    end
    
	GroupsMaid.Thing.Frame.UIGridLayout.CellSize = UDim2.new(0, SIZE.X * GroupsMaid.Thing.Frame.AbsoluteSize.X, 0, SIZE.Y * GroupsMaid.Thing.Frame.AbsoluteSize.Y)

    GroupsMaid.Event = MainGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        local ps = GroupsMaid.Thing.Frame.AbsoluteSize
	    GroupsMaid.Thing.Frame.UIGridLayout.CellSize = UDim2.new(0, SIZE.X * ps.X, 0, SIZE.Y * ps.Y)
    end)

    GroupsMaid.Thing.Frame.UIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function ()
        GroupsMaid.Thing.Frame.CanvasSize = UDim2.new(0, 0, 0, GroupsMaid.Thing.Frame.UIGridLayout.AbsoluteContentSize.Y)
    end)

    GroupsMaid.Thing.topBar.exitButton.Activated:Connect(function()
        GroupsMaid:DoCleaning()
    end)
end)

-- Alerts

Events:Get("AlertPlayer").OnClientEvent:Connect(function(msg)
    local Maid = _maid.new()
    Maid.AlertUI = MainGui.Alert:Clone()
    Maid.AlertUI.Parent = MainGui
    Maid.AlertUI.topBar.title.Text = "Alert"
    Maid.AlertUI.Visible = true
    Maid.AlertUI.message.Text = msg
    Maid.AlertUI.Name = "clone"
    MakeDraggableMoveParent(Maid.AlertUI.topBar, Maid.AlertUI.topBar.exitButton)

    ScaleText(Maid.AlertUI.message, 35)

    Maid.Changed = MainGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        ScaleText(Maid.AlertUI.message, 35)
    end)

    Maid.AlertUI.topBar.exitButton.Activated:Connect(function()
        Maid:DoCleaning()
        if Sounds:Get().Playing and Sounds:Get().SoundId == Sounds.UI.Alert.Id then
            Sounds:Stop()
        end
    end)
end)

-- Player list


Events:Get("ShowPlayers").OnClientEvent:Connect(function()
    local PlayerlistMaid = _maid.new()
    PlayerlistMaid.Thing = MainGui.Playerlist:Clone()
    PlayerlistMaid.Thing.Parent = MainGui
    PlayerlistMaid.Thing.Visible = true
    PlayerlistMaid.Thing.Name = "clone"
    MakeDraggableMoveParent(PlayerlistMaid.Thing.topBar, PlayerlistMaid.Thing.topBar.exitButton)
    PlayerlistMaid.Thing.topBar.title.Text = "Player list"

    local function AddPlayer(player)
        PlayerlistMaid[player.Name] = PlayerlistMaid.Thing.Frame.Template:Clone()
        PlayerlistMaid[player.Name].CharacterImage.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
        PlayerlistMaid[player.Name].DisplayName.Text = "\"" .. player.DisplayName .. "\""
        PlayerlistMaid[player.Name].UserName.Text = player.Name
        PlayerlistMaid[player.Name].Visible = true
        PlayerlistMaid[player.Name].Parent = PlayerlistMaid.Thing.Frame

        PlayerlistMaid[player.Name].Activated:Connect(function()
            OpenCommandPanel({Player = player})
        end)
    end

    PlayerlistMaid.Event = MainGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        local ps = PlayerlistMaid.Thing.Frame.AbsoluteSize
	    PlayerlistMaid.Thing.Frame.UIGridLayout.CellSize = UDim2.new(0, SIZE.X * ps.X, 0, SIZE.Y * ps.Y)
    end)

    PlayerlistMaid.Thing.Frame.UIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function ()
        PlayerlistMaid.Thing.Frame.CanvasSize = UDim2.new(0, 0, 0, PlayerlistMaid.Thing.Frame.UIGridLayout.AbsoluteContentSize.Y)
    end)

    for _, v in ipairs(Players:GetPlayers()) do
        AddPlayer(v)
    end

    PlayerlistMaid.Joined = Players.PlayerAdded:Connect(AddPlayer)

    PlayerlistMaid.Removed = Players.PlayerRemoving:Connect(function(player)
        PlayerlistMaid[player.Name] = nil
    end)

    PlayerlistMaid.Thing.topBar.exitButton.Activated:Connect(function()
        PlayerlistMaid:DoCleaning()
    end)
end)

-- General stuff

MainGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    PositionElements()
end)