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
local spr = require(ReplicatedStorage.Modules.spr)

local Trove = require(ReplicatedStorage.Packages.Trove)
local trove = Trove.new() -- USE TROVE TO DISCONNECT REMOTE CONNECTIONS (ONLY DISCONNECT IF ITS ONLY USED ONCE) (DONT USE ON PLAYERADDED N STUFF)

local MusicPlayer = workspace.Music

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Controller
local MusicController = Knit.CreateController {
    Name = "MusicController",
}

local UIController
local MusicService

-- ————————— ↢ ⭐️ ↣ —————————-
-- Client Functions
function MusicController:SongInformation(Promise: boolean, SongName: string)
    self.GochiRadio.Song.Text = SongName or "Loading..."
end

function MusicController:MuteSong(Debounce: boolean)
    self.GochiRadio.MuteButton.MouseButton1Down:Connect(function()
        if Debounce then
            self.GochiRadio.MuteButton.Unmuted.Visible = true
            self.GochiRadio.MuteButton.Muted.Visible = false

            spr.target(MusicPlayer, 1, 2, { Volume = 1})
            Debounce = false
        else
            self.GochiRadio.MuteButton.Unmuted.Visible = false
            self.GochiRadio.MuteButton.Muted.Visible = true

            spr.target(MusicPlayer, 1, 2, { Volume = 0})
            Debounce = true
        end
    end)
end

function MusicController:KnitStart()
    UIController = Knit.GetController("UIController")
    MusicService = Knit.GetService("MusicService")

    self.GochiRadio = UIController.Pages.Parent:WaitForChild("Radio").GochiMusic
    self:SongInformation(MusicService:SongInformation():await())
    self:MuteSong()

    MusicService.Update:Connect(function(SongName: string)
        self:SongInformation(true, SongName)
    end)

end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Controller to Knit.
return MusicController