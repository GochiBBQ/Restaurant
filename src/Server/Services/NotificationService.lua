--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Create Knit Service
local NotificationService = Knit.CreateService {
    Name = "NotificationService",
    Client = {
        Notification = Knit.CreateSignal(),
    },
}

-- Server Functions

--- Sends a notification to a specific player.
--- @param Player Player The player to whom the notification will be sent.
--- @param Message string The message content of the notification.
function NotificationService:_createNotif(Player: Player, Message: string)
    self.Client.Notification:Fire(Player, Message)
end

--- Creates an announcement and sends it to all clients.
-- @param Message The message string to be sent as an announcement.
function NotificationService:CreateAnnouncement(Message: string)
    self.Client.Notification:FireAll(Message)
end

-- Client Functions
--- Sends an announcement to all players.
--- @param Initiator Player The player who initiated the announcement.
--- @param Message string The message to be announced.
function NotificationService.Client:Announcement(Initiator: Player, Message: string)
    self.Server:CreateAnnouncement(Message)
end

--- Creates a notification for a target player.
--- 
--- This function is invoked on the client side to create a notification for the specified target player.
--- It internally calls the server-side `_createNotif` method to handle the notification creation.
---
--- @param Initiator Player The player who initiated the notification.
--- @param Target Player The player who will receive the notification.
--- @param Message string The message content of the notification.
function NotificationService.Client:CreateNotif(Initiator: Player, Target: Player, Message: string)
    self.Server:_createNotif(Target, Message)
end

 -- Return Service to Knit.
return NotificationService
