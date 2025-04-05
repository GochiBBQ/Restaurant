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
function NotificationService:_createNotif(Player: Player, Message: string)
    self.Client.Notification:Fire(Player, Message)
end

function NotificationService:CreateAnnouncement(Message: string)
    self.Client.Notification:FireAll(Message)
end

-- Client Functions
function NotificationService.Client:Announcement(Initiator: Player, Message: string)
    self.Server:CreateAnnouncement(Message)
end

--- Creates a notification for a target player.
function NotificationService.Client:CreateNotif(Initiator: Player, Target: Player, Message: string)
    self.Server:_createNotif(Target, Message)
end

 -- Return Service to Knit.
return NotificationService
