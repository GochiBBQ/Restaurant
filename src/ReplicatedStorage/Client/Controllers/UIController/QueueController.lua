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

local UIController
local QueueService

-- ————————— ↢ ⭐️ ↣ —————————-
-- Client Functions

function QueueController:ElapsedTime(Player: Player, Label: TextLabel)
    task.spawn(function()
        local PlayerElapsed = Player:GetAttribute("ElapsedTime")
        
        if PlayerElapsed then
            local FormattedMinutes, FormattedSeconds = math.floor(PlayerElapsed / 60), PlayerElapsed % 60
            local FormattedCompare = 10 > FormattedSeconds and "0" .. FormattedSeconds
            Label.Text = string.format("%s:%s Elapsed", FormattedMinutes, (FormattedCompare or FormattedSeconds))
        end
    end)
end

function QueueController:QueueLinkage(Player: Player)
    local ClonedFrame = script.Template:Clone()

    ClonedFrame.Avatar.Image = PlayerService:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    ClonedFrame.Role.Text = Player:GetRoleInGroup(5874921)
    ClonedFrame.Username.Text = Player.Name
    ClonedFrame.Name = Player.Name

    ClonedFrame.Parent = self.ChefQueue.Holder.ScrollingFrame
    self:ElapsedTime(Player, ClonedFrame.Timer)
end

function QueueController:QueueUnlinkage(Player: Player)
    if Player == "Reset" then
        for _, Chefs in pairs(self.ChefQueue.Holder.ScrollingFrame:GetChildren()) do
            if Chefs:IsA("Frame") then
                Chefs:Destroy()
            end
        end
    else
        if self.ChefQueue.Holder.ScrollingFrame:FindFirstChild(Player.Name) then
            self.ChefQueue.Holder.ScrollingFrame:FindFirstChild(Player.Name):Destroy()
        end
    end
end

function QueueController:QueueUpdate(Promise: boolean, ChefQueue: table)
    self:QueueUnlinkage("Reset")

    for i, Chef in ipairs(ChefQueue) do
        self:QueueLinkage(Chef)
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

function QueueController:QueueLeave()
    spr.target(self.ChefQueue.LeaveQueue, 1, 3, { BackgroundColor3 = Color3.fromRGB(107, 76, 193)})
    task.wait(0.25)
    spr.target(self.ChefQueue.LeaveQueue, 1, 3, { BackgroundColor3 = Color3.fromRGB(30, 30, 33)})

    QueueService:QueueLeave():await()

    spr.target(self.ChefQueue.Holder.QueuePosition, 1, 3, { TextTransparency = 1})
    task.wait(0.25)
    self.ChefQueue.Holder.QueuePosition.Text = "You are <b>not</b> in the queue."
    spr.target(self.ChefQueue.Holder.QueuePosition, 1, 3, { TextTransparency = 0})
end

function QueueController:KnitStart()
    QueueService = Knit.GetService("QueueService")
    UIController = Knit.GetController("UIController")
    self.ChefQueue = UIController.Pages:WaitForChild("ChefQueue").Frame
    self:QueueUpdate(QueueService:QueueUpdate():await())

    QueueService.Add:Connect(function(Player: Player)
        self:QueueLinkage(Player)
    end)

    QueueService.Remove:Connect(function(Player: Player)
        self:QueueUnlinkage(Player)
    end)

    self.ChefQueue.JoinQueue.MouseButton1Down:Connect(function()
        self:QueueJoin()
    end)

    self.ChefQueue.LeaveQueue.MouseButton1Down:Connect(function()
        self:QueueLeave()
    end)
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Controller to Knit.
return QueueController