--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players: Players = game:GetService("Players")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)
local Trove: ModuleScript = require(ReplicatedStorage.Packages.Trove) --- @module Trove
local AnimNation: ModuleScript = require(Knit.Modules.AnimNation)

-- Create Knit Controller
local NotificationController = Knit.CreateController {
    Name = "NotificationController",
}

-- Active announcements (max 2 visible)
local ActiveNotifications: table = {}

-- Queue for waiting messages
local NotificationQueue: table = {}

-- Variables
local Player: Player = Players.LocalPlayer
local PlayerGui: PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI: GuiObject = PlayerGui:WaitForChild("GochiUI")

local Container: GuiObject = GochiUI:WaitForChild("Notifications")
local AnnouncementTemplate: GuiObject = Container:WaitForChild("Tip")

local NotificationService

-- Knit Init
function NotificationController:KnitStart()
    NotificationService = Knit.GetService('NotificationService')

    NotificationService.Notification:Connect(function(message)
        self:HandleNotification(message)
    end)
end

-- Public interface to queue or create immediately
function NotificationController:HandleNotification(message: string)
    if #ActiveNotifications >= 2 then
        table.insert(NotificationQueue, message)
    else
        self:CreateAnnouncement(message)
    end
end

-- Moves all active notifications upward
function NotificationController:TweenExistingAnnouncements()
    for _, entry in ipairs(ActiveNotifications) do
        local announcement = entry.Announcement
        local targetPosition = UDim2.new(
            announcement.Position.X.Scale,
            announcement.Position.X.Offset,
            announcement.Position.Y.Scale - 0.12,
            announcement.Position.Y.Offset
        )
        AnimNation.target(announcement, {s = 10, d = 1}, {Position = targetPosition})
    end
end

-- Creates and animates a new notification
function NotificationController:CreateAnnouncement(message: string)
    self:TweenExistingAnnouncements()

    local Announcement = AnnouncementTemplate:Clone()
    Announcement.Description.Text = ""
    Announcement.Parent = Container
    Announcement.Visible = true
    Announcement.Position = UDim2.new(0.495, 0, 0.929, 0)

    local trove = Trove.new()
    local entry = {
        Announcement = Announcement,
        Trove = trove,
    }

    table.insert(ActiveNotifications, entry)

    -- Typing animation
    trove:Add(task.spawn(function()
        for i = 1, #message do
            Announcement.Description.Text = string.sub(message, 1, i)
            task.wait(0.05)
        end
    end))

    -- Delay + cleanup logic
    trove:Add(task.delay(8, function()
        AnimNation.target(Announcement, {s = 10, d = 1}, {Position = UDim2.new(0.499, 0, 1.2, 0)}):Await()
        Announcement:Destroy()

        -- Remove from active list
        for i, existing in ipairs(ActiveNotifications) do
            if existing.Announcement == Announcement then
                table.remove(ActiveNotifications, i)
                break
            end
        end

        trove:Clean()

        -- Show next in queue if available
        if #NotificationQueue > 0 then
            local nextMessage = table.remove(NotificationQueue, 1)
            self:CreateAnnouncement(nextMessage)
        end
    end))
end

return NotificationController
