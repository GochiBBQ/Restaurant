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

QueueController.InQueue = false
QueueController.Elapsed = {}

local UIController
local QueueService

-- ————————— ↢ ⭐️ ↣ —————————-
-- Client Functions
function QueueController:ElapsedTime(Player, Label: TextLabel)
    local ElapsedTime = self.Elapsed[Player]
    task.spawn(function()
        while task.wait(1) do
            local SecondsFormatted = ElapsedTime % 60
            local MinutesFormatted = math.floor(ElapsedTime / 60)
            local CompareFormatted = 10 > SecondsFormatted and "0" .. SecondsFormatted
            ElapsedTime += 1

            Label.Text = string.format("%s:%s Elapsed", MinutesFormatted, (CompareFormatted or SecondsFormatted))
        end
    end)
end

function QueueController:QueueLinkage(Player: Player, Position: number)
    local ClonedFrame = script.Template:Clone()

    ClonedFrame.Avatar.Image = PlayerService:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    ClonedFrame.Role.Text = Player:GetRoleInGroup(5874921)
    ClonedFrame.Username.Text = Player.Name
    ClonedFrame.Parent = self.ChefQueue.Holder.ScrollingFrame
    ClonedFrame.LayoutOrder = Position

    if not self.Elapsed[Player] then self.Elapsed[Player] = 0 end
    self:ElapsedTime(Player, ClonedFrame.Timer)
end

function QueueController:QueueUnlinkage()
    for _, Chefs in pairs(self.ChefQueue.Holder.ScrollingFrame:GetChildren()) do
        if Chefs:IsA("Frame") then
            Chefs:Destroy()
        end
    end
end

function QueueController:QueueUpdate(Promise: boolean, ChefQueue: table)
    print(Promise, ChefQueue)
    for i, Chef in ipairs(ChefQueue) do
        self:QueueUnlinkage()
        self:QueueLinkage(Chef, i)
    end
end

function QueueController:QueueJoin()
    spr.target(self.ChefQueue.JoinQueue, 1, 3, { BackgroundColor3 = Color3.fromRGB(107, 76, 193)})
    task.wait(0.25)
    spr.target(self.ChefQueue.JoinQueue, 1, 3, { BackgroundColor3 = Color3.fromRGB(30, 30, 33)})

    local Success, Place = QueueService:QueueJoin():await()
    if Success and Place then
        spr.target(self.ChefQueue.Holder.QueuePosition, 1, 3, { TextTransparency = 1})
        task.wait(0.25)
        self.ChefQueue.Holder.QueuePosition.Text = "You are <b>" .. Place .. "</b> in the queue."
        spr.target(self.ChefQueue.Holder.QueuePosition, 1, 3, { TextTransparency = 0})
    end
end

function QueueController:KnitStart()
    QueueService = Knit.GetService("QueueService")
    UIController = Knit.GetController("UIController")
    self.ChefQueue = UIController.Pages:WaitForChild("ChefQueue").Frame
    self:QueueUpdate(QueueService:QueueUpdate():await())

    QueueService.Update:Connect(function(ChefQueue: table)
        self:QueueUpdate(true, ChefQueue)
    end)

    self.ChefQueue.JoinQueue.MouseButton1Down:Connect(function()
        self:QueueJoin()
    end)
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Controller to Knit.
return QueueController