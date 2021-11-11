local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local _maid = require(ReplicatedStorage:WaitForChild("GRPeeAdminModules"):WaitForChild("Maid"))
local m = {}
m.__index = m

local plr = Players.LocalPlayer
local PlayerGui = plr:WaitForChild("PlayerGui")
local MainGui = PlayerGui:WaitForChild("GRPeeUI")


local function GenerateUI(parent)
    local DropdownMenu = Instance.new("ScrollingFrame")
    local maid = _maid.new()
    DropdownMenu.Name = "DropdownMenu"
    DropdownMenu.Selectable = false
    DropdownMenu.Size = UDim2.new(0, parent.AbsoluteSize.X, 0.46, 0)
    DropdownMenu.Position = UDim2.new(0, 0, 1, 0)
    DropdownMenu.Active = true
    DropdownMenu.Visible = false
    DropdownMenu.BorderSizePixel = 0
    DropdownMenu.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    DropdownMenu.BackgroundColor3 = Color3.fromRGB(102, 102, 102)

    local UIGridLayout = Instance.new("UIGridLayout")
    UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIGridLayout.CellSize = UDim2.new(1, 0, 0, 0)
    UIGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
    UIGridLayout.Parent = DropdownMenu

    local TemplateDark = Instance.new("TextButton")
    TemplateDark.Name = "TemplateDark"
    TemplateDark.Selectable = false
    TemplateDark.Visible = false
    TemplateDark.Size = UDim2.new(0, 100, 0, 100)
    TemplateDark.BackgroundTransparency = 0.8
    TemplateDark.Active = true
    TemplateDark.BorderSizePixel = 0
    TemplateDark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TemplateDark.TextColor3 = Color3.fromRGB(255, 255, 255)
    TemplateDark.TextWrap = true
    TemplateDark.Font = Enum.Font.SourceSansSemibold
    TemplateDark.TextWrapped = true
    TemplateDark.TextScaled = true
    TemplateDark.Parent = DropdownMenu

    local TemplateLight = Instance.new("TextButton")
    TemplateLight.Name = "TemplateLight"
    TemplateLight.Selectable = false
    TemplateLight.Visible = false
    TemplateLight.Size = UDim2.new(0, 100, 0, 100)
    TemplateLight.BackgroundTransparency = 0.8
    TemplateLight.Active = true
    TemplateLight.BorderSizePixel = 0
    TemplateLight.BackgroundColor3 = Color3.fromRGB(121, 129, 163)
    TemplateLight.TextColor3 = Color3.fromRGB(255, 255, 255)
    TemplateLight.TextWrap = true
    TemplateLight.Font = Enum.Font.SourceSansSemibold
    TemplateLight.TextWrapped = true
    TemplateLight.TextScaled = true
    TemplateLight.Parent = DropdownMenu

    DropdownMenu.Parent = MainGui

    local ps = DropdownMenu.AbsoluteSize
	UIGridLayout.CellSize = UDim2.new(0, 1 * ps.X, 0, 0.16 * ps.Y)

    DropdownMenu.CanvasSize = UDim2.new(0, 0, 0, UIGridLayout.AbsoluteContentSize.Y)

    UIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() -- this'll disconnect itself when the dropdown menu is destroyed ( thank you garbage collection :) )
        DropdownMenu.CanvasSize = UDim2.new(0, 0, 0, UIGridLayout.AbsoluteContentSize.Y)
    end)

    maid.mainGuiAbsoluteSizeEvent = MainGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        UIGridLayout.CellSize = UDim2.new(0, 1 * ps.X, 0, 0.16 * ps.Y)
    end)

    maid.absoluteSizeEvent = parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        DropdownMenu.Size = UDim2.new(0, parent.AbsoluteSize.X, 0.46, 0)
    end)

    maid.childRemovedEvent = parent.Parent.ChildRemoved:Connect(function(child)
        if child == parent then 
            maid:DoCleaning()
            maid = nil
        end
    end)

    return DropdownMenu
end

function m.new(button, ...)
    local new = {
        Button = button;
        Visible = false;
        Ui = GenerateUI(button);
        Maid = _maid.new();

        ChoiceMade = function(number, text, object)
            
        end;

        OnClose = function()
            
        end;

        OnOpen = function()
            
        end;
    }

    local choices = {}

    for i, choice in ipairs(table.pack(...)) do
        local IsEven = i % 2 == 0
        local clone

        if IsEven then
            clone = new.Ui.TemplateDark:Clone()
        else
            clone = new.Ui.TemplateLight:Clone()
        end

        clone.Text = choice
        clone.Parent = new.Ui
        clone.Visible = true

        clone.Activated:Connect(function()
            new.ChoiceMade(i, choice, clone)
        end)

        table.insert(choices, clone)
    end

    new.Options = choices
    return setmetatable(new, m)
end

function m:Open()

    local function IsOverlappingEdge()
        local frame = self.Ui
        local bottomOfFrame = frame.AbsolutePosition.Y + frame.AbsoluteSize.Y
        local bottomOfScreen = MainGui.AbsoluteSize.Y

        return bottomOfFrame >= bottomOfScreen
    end

    local function Position()
        self.Ui.Position = UDim2.new(0, self.Button.AbsolutePosition.X, 0, self.Button.AbsolutePosition.Y + self.Button.AbsoluteSize.Y)

        if IsOverlappingEdge() then -- it is PARTIALLY OR FULLY OUT OF BOUNDS!!! PUT IT ABOVE THE where
            self.Ui.Position = UDim2.new(0, self.Button.AbsolutePosition.X, 0, self.Button.AbsolutePosition.Y - self.Ui.AbsoluteSize.Y)
        end
    end

    Position()

    self.Maid.Position = MainGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(Position)
    self.Maid.Moved = self.Button:GetPropertyChangedSignal("AbsolutePosition"):Connect(Position)
    self.Ui.Visible = true
    self.Visible = true


    self.OnOpen()
end

function m:Close()
    self.Maid:DoCleaning()
    self.Visible = false
    self.Ui.Visible = false

    self.OnClose()
end

function m:Toggle()
    if self.Visible then
        self:Close()
    else
        self:Open()
    end
end

function m:Destroy()
    self.Ui:Destroy()
    self.Maid:DoCleaning()
end

return m