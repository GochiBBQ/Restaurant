--[[
Author: alreadyfans
For: Gochi
]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit) -- @module Knit
local Trove = require(ReplicatedStorage.Packages.Trove) -- @module Trove

-- Create Knit Controller
local OrderController = Knit.CreateController {
    Name = "OrderController",
    SelectionBoxes = {},
    ClickDetectors = {},
    Trove = Trove.new()
}

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI = PlayerGui:WaitForChild("GochiUI")

local CreateOrder = GochiUI:WaitForChild("CreateOrder") -- @type ImageButton

local OrderBoard = PlayerGui:WaitForChild("SurfaceUIs"):WaitForChild("OrderBoard") -- @type SurfaceGui

local OrderService
local TableService
local NotificationService


-- Helper to clean up previous visuals
function OrderController:ClearSelections()
    self.Trove:Clean() -- Automatically destroys all previous SelectionBoxes and ClickDetectors
    self.SelectionBoxes = {}
    self.ClickDetectors = {}
end

-- Client Functions
function OrderController:KnitStart()
    OrderService = Knit.GetService("OrderService") -- @module OrderService
    TableService = Knit.GetService("TableService") -- @module TableService
    NotificationService = Knit.GetService("NotificationService") -- @module NotificationService

    CreateOrder.MouseButton1Click:Connect(function()
        if Player:GetAttribute('Table') ~= nil and Player:GetAttribute("Server") then
            TableService:GetOccupants(Player:GetAttribute('Table')):andThen(function(Occupants)
                if #Occupants <= 0 then
                    return NotificationService:CreateNotif(Player, 'Your party has no occupants to serve.')
                end

                self:ClearSelections() -- Clear existing selection visuals before creating new ones

                for _, Occupant in Occupants do
                    local Character = Occupant.Character or Occupant.CharacterAdded:Wait()

                    local SelectionBox = Instance.new("SelectionBox")
                    SelectionBox.Adornee = Character
                    SelectionBox.Color3 = Color3.fromHex('ab1eff')
                    SelectionBox.SurfaceColor3 = Color3.fromRGB(123, 22, 186)
                    SelectionBox.LineThickness = 0.05
                    SelectionBox.SurfaceTransparency = 0.5
                    SelectionBox.Parent = Character

                    self.Trove:Add(SelectionBox)
                    table.insert(self.SelectionBoxes, SelectionBox)

                    local ClickDetector = Instance.new("ClickDetector")
                    ClickDetector.MaxActivationDistance = 20
                    ClickDetector.Parent = Character

                    self.Trove:Add(ClickDetector)
                    table.insert(self.ClickDetectors, ClickDetector)

                    ClickDetector.MouseClick:Connect(function()
                        print("Clicked!")

                        self:ClearSelections()

                        -- Add order logic here, e.g., open menu or send order request
                    end)
                end
            end)
        else
            NotificationService:CreateNotif(Player, 'You need to serve a party to create an order!')
        end
    end)
end

-- Return Controller to Knit
return OrderController
