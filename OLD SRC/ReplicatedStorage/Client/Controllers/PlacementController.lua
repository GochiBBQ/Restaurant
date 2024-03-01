--[[
    __ __  _   _  _   _  ___  __  __  __  _  
    |  V  || \ / || \ / || _ \/ _]/  \|  \| | 
    | \_/ |`\ V /'`\ V /'| v / [/\ /\ | | ' | 
    |_| |_|  \_/    \_/  |_|_\\__/_||_|_|\__| 

    Author: mvvrgan
    For: Sakura Kitchen 🥢
    https://www.roblox.com/groups/6975354/Sakura-Kitchen#!/about

]]

-- ————————— ↢ ⭐️ ↣ —————————
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Controller
local PlacementController = Knit.CreateController { 
    Name = "PlacementController",
    GhostModel = false,
    Tool = false,
    GhostModeToggle = false
}

local PlacementService = nil

-- ————————— ↢ ⭐️ ↣ —————————
-- Raycast Parameters
local RaycastParams = RaycastParams.new()
RaycastParams.FilterType = Enum.RaycastFilterType.Include
RaycastParams.FilterDescendantsInstances = {workspace.Functionality.TableManagement.Placement.Surfaces, workspace.Functionality.TableManagement.Grills}
RaycastParams.IgnoreWater = true

-- ————————— ↢ ⭐️ ↣ —————————
-- Client Functions
function PlacementController:SetGhostModel(model: Model)
    for _,Part in ipairs(model:GetDescendants()) do
        if Part:IsA('BasePart') then
            Part.Anchored = true
        elseif Part:IsA('Weld') then
            Part:Destroy()
        end
    end
    
    model.Name = "GhostModel"
    
    local Highlight = Instance.new('Highlight')
    Highlight.FillTransparency = 1
    Highlight.OutlineColor = Color3.fromRGB(128, 255, 82)
    Highlight.Parent = model
    self.Highlight = Highlight

    local PlacementUi = ReplicatedStorage.Static.PlacementGui:Clone()
    PlacementUi.Parent = Player.PlayerGui
    self.PlacementUi = PlacementUi

    --RaycastParams.FilterDescendantsInstances = {Player.Character, model}

    self.GhostModel = model
end

function PlacementController:FindAcceptableGhostModel()
    for _,Inst in pairs(Player.Character:GetChildren()) do
        if Inst:IsA('Tool') and Inst:FindFirstChild('Model') then
            Conn = Inst.Unequipped:Connect(function()
                PlacementController:ToggleGhostMode()
                Conn:Disconnect()
            end)
            self.Tool = Inst
            return self:SetGhostModel(Inst.Model:Clone())
        end
    end
    self.GhostModel = nil
    return
end

function PlacementController:ToggleGhostMode()
    if self.GhostModeToggle then
        if not self.GhostModel then return end
        self.GhostModel:Destroy()
        self.GhostModeToggle = false
        self.CanPlace = false
    else
        self:FindAcceptableGhostModel()
        if not self.GhostModel then return end
        local trove = Trove.new()
        self.GhostModeToggle = true

        trove:Add(Mouse.Move:Connect(function()
            local RaycastResult = workspace:Raycast(Mouse.UnitRay.Origin, Mouse.UnitRay.Direction * 100, RaycastParams)
            
            self.CanPlace = false

            if RaycastResult then
                if RaycastResult.Instance.Parent == workspace.Functionality.TableManagment.Placement.Surfaces then
                    self.CanPlace = true
                    self.Highlight.OutlineColor = Color3.fromRGB(128, 255, 82)
                    self.PlacementUi.ImageLabel.ImageColor3 = Color3.fromRGB(128, 255, 82)
                else
                    self.CanPlace = false
                    self.Highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                    self.PlacementUi.ImageLabel.ImageColor3 = Color3.fromRGB(255, 0, 0)
                end
                if not self.GhostModel.Parent then 
                    self.GhostModel.Parent = workspace.Functionality.TableManagment.Placement
                    self.PlacementUi.Adornee = self.GhostModel.PrimaryPart
                    trove:Add(self.PlacementUi)
                    trove:AttachToInstance(self.GhostModel.PrimaryPart)
                end
                local GoalPos = RaycastResult.Position
                GoalPos = GoalPos + Vector3.new(0, self.GhostModel.PrimaryPart.Size.Y / 2, 0)
                self.GhostModel:PivotTo(CFrame.new(GoalPos))
            elseif self.GhostModel.Parent then
                self.CanPlace = false
                self.GhostModel.Parent = nil
            end
        end))
    end
end

function PlacementController:KnitStart()
    PlacementService = Knit.GetService("PlacementService")

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if self.CanPlace then
                PlacementService:PlaceModel(self.Tool, self.GhostModel.PrimaryPart.CFrame)
            end
        end

        if input.KeyCode == Enum.KeyCode.LeftControl then
            self:ToggleGhostMode()
        end
    end)
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Controller to Knit.
return PlacementController