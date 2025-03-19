--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local AnimNation = require(Knit.Modules.AnimNation) --- @module AnimNation

-- Create Knit Controller
local NotificationController = Knit.CreateController {
    Name = "NotificationController",
}

local ActiveNotifications = {}

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI = PlayerGui:WaitForChild("GochiUI")

local Container = GochiUI:WaitForChild("Notifications")
local AnnouncementTemplate = Container:WaitForChild("Tip")

local NotificationService

-- Client Functions
function NotificationController:KnitStart()
    NotificationService = Knit.GetService('NotificationService')

    NotificationService.Notification:Connect(function(message)
        self:CreateAnnouncement(message)
    end)
    
end

function NotificationController:TweenExistingAnnouncements()
    for i, announcement in ipairs(ActiveNotifications) do
        local targetPosition = UDim2.new(announcement.Position.X.Scale, announcement.Position.X.Offset, announcement.Position.Y.Scale - 0.09, announcement.Position.Y.Offset)
        -- spr.target(announcement, 1, 3, {Position = targetPosition})
        AnimNation.target(announcement, {s = 10, d = 1}, {Position = targetPosition})
    end
end

function NotificationController:CreateAnnouncement(Message: string)
    self:TweenExistingAnnouncements()

    local Announcement = AnnouncementTemplate:Clone()
    Announcement.Description.Text = ""
    Announcement.Parent = Container
    Announcement.Visible = true
    Announcement.Position = UDim2.new(0.499, 0,0.96, 0) -- Start from the bottom

    table.insert(ActiveNotifications, Announcement)

    for i = 1, #Message do
        Announcement.Description.Text = string.sub(Message, 1, i)
        task.wait(0.05)
    end

    task.delay(8, function()
        -- Add exit animation for removal
        -- spr.target(Announcement, 1, 3, {Position = UDim2.new(0.499, 0, 1.2, 0)})
        AnimNation.target(Announcement, {s = 10, d = 1}, {Position = UDim2.new(0.499, 0, 1.2, 0)}):Await()
            Announcement:Destroy()
            table.remove(ActiveNotifications, table.find(ActiveNotifications, Announcement))
    end)
end

-- Return Controller to Knit.
return NotificationController
