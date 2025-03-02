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
function NotificationService:CreateNotif(Player: Player, Message: string)
    self.Client.Notification:Fire(Player, Message)
end

function NotificationService:CreateAnnouncement(Message: string)
    self.Client.Notification:FireAll(Message)
end

-- Client Functions
function NotificationService.Client:Announcement(Message: string)
    self.Server:CreateAnnouncement(Message)
end

 -- Return Service to Knit.
return NotificationService
