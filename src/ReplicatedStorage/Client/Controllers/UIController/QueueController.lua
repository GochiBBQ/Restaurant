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
local SoundService = game:GetService("SoundService")
local PlayerService = game:GetService("Players")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)
local spr = require(ReplicatedStorage.Modules.spr)

local Trove = require(ReplicatedStorage.Packages.Trove)
local trove = Trove.new()

local Player = PlayerService.LocalPlayer
local UISelect = SoundService.UISelect
local UIHover = SoundService.UIHover

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Controller
local QueueController = Knit.CreateController {
    Name = "QueueController",
}

local UIController

-- ————————— ↢ ⭐️ ↣ —————————-
-- Client Functions
function QueueController:ElapsedTime()
    local ElapsedTime = 0
    task.spawn(function()
        while task.wait(1) do
            local SecondsFormatted = ElapsedTime % 60
            local MinutesFormatted = math.floor(ElapsedTime / 60)
            local CompareFormatted = 10 > SecondsFormatted and "0" .. SecondsFormatted
            ElapsedTime += 1

            return string.format("%s:%s Elapsed", MinutesFormatted, (CompareFormatted or SecondsFormatted))
        end
    end)
end

function QueueController:QueueLinkage(Player: Player, Position: number)
    local ClonedFrame = script.Template:Clone()

    ClonedFrame.Avatar.Image = PlayerService:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    ClonedFrame.Role.Text = Player:GetAttribute("GochiRank")
    ClonedFrame.Timer = self:ElapsedTime(Player)
    ClonedFrame.Username.Text = Player.Name
end

function QueueController:QueueUpdate(ChefQueue: table)
    for i, Chef in ipairs(ChefQueue) do
        self:QueueLinkage(Chef, i)
    end
end

function QueueController:QueueJoin()
    spr.target(self.ChefQueue.JoinQueue, 1, 4, { Color3.fromRGB(107, 76, 193)})
    task.wait(0.15)
    spr.target(self.ChefQueue.JoinQueue, 1, 4, { Color3.fromRGB(30, 30, 33)})
end

function QueueController:KnitStart()
    UIController = Knit.GetController("UIController")
    self.ChefQueue = UIController.Pages:WaitForChild("ChefQueue").Frame

    self.ChefQueue.JoinQueue.MouseButton1Down:Connect(function()
        self:QueueJoin()
    end)
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Controller to Knit.
return QueueController