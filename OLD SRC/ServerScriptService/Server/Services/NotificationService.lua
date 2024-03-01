--[[

█▀▀▄ █▀▀█ █▀▀▄ █▀▀█ █░░█ █▀▀▄ ▀▀█▀▀ ▀▀█ █▀▀█ █▀▀ █░█ 
█░░█ █░░█ █░░█ █░░█ █░░█ █▀▀▄ ░░█░░ ▄▀░ █▄▄█ █░░ █▀▄ 
▀░░▀ ▀▀▀▀ ▀▀▀░ ▀▀▀▀ ░▀▀▀ ▀▀▀░ ░░▀░░ ▀▀▀ ▀░░▀ ▀▀▀ ▀░▀

Author: nodoubtzack
For: Gochí Restaurant 🥩
https://www.roblox.com/groups/5874921/Goch#!/about

]]

-- ————————— ↢ ⭐️ ↣ —————————
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)

local Trove = require(ReplicatedStorage.Packages.Trove)
local trove = Trove.new() -- USE TROVE TO DISCONNECT REMOTE CONNECTIONS (ONLY DISCONNECT IF ITS ONLY USED ONCE) (DONT USE ON PLAYERADDED N STUFF)

local RateLimiter = require(Knit.Modules.RateLimiter)
local RequestRateLimiter = RateLimiter.NewRateLimiter(4) -- USE TO CREATE A RATE LIMIT RequestRateLimiter:CheckRate() can be used to check rate limit (true means no rate limit)

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Service
local NotificationService = Knit.CreateService {
    Name = "NotificationService",
	Client = {
        Send = Knit:CreateSignal()
	},
}

-- ————————— ↢ ⭐️ ↣ —————————-
-- Server Functions
function NotificationService:PlayerNotification(Player: Player, Title: string, Message: string)
    self.Client.Send:Fire(Player, {Title = Title, Text = Message, Icon = PlayerService:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420), Duration = 02})
end

function NotificationService:ServerNotification(Title: string, Message: string)
    self.Client.Send:FireAll({Title = Title, Text = Message, Duration = 02})
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Service to Knit.
return NotificationService