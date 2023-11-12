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

local MusicPlayer = workspace.Music

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Controller
local MusicController = Knit.CreateController {
    Name = "MusicController",
}

local UIController
local MusicService

MusicController.MuteDebounce = false
MusicController.CurrentVolume = 1

-- ————————— ↢ ⭐️ ↣ —————————-
-- Client Functions
function MusicController:SongInformation(Promise: boolean, SongName: string, SongVolume: number)
    self.GochiRadio.Song.Text = SongName or "Loading..."
    self.CurrentVolume = SongVolume
end

function MusicController:RegisterMuteSong(MuteDebounce: boolean)
    if self.MuteDebounce then
        spr.target(self.GochiRadio.MuteButton.Muted, 1, 3, { ImageTransparency = 1})
        task.wait(0.25)
        spr.target(self.GochiRadio.MuteButton.Unmuted, 1, 3, { ImageTransparency = 0})

        spr.target(MusicPlayer, 1, 3, { Volume = self.CurrentVolume})
        self.MuteDebounce = false
    else
        spr.target(self.GochiRadio.MuteButton.Unmuted, 1, 3, { ImageTransparency = 1})
        task.wait(0.25)
        spr.target(self.GochiRadio.MuteButton.Muted, 1, 3, { ImageTransparency = 0})

        spr.target(MusicPlayer, 1, 3, { Volume = 0})
        self.MuteDebounce = true
    end
end

function MusicController:KnitStart()
    UIController = Knit.GetController("UIController")
    MusicService = Knit.GetService("MusicService")

    self.GochiRadio = UIController.Pages.Parent:WaitForChild("Radio").GochiMusic
    self:SongInformation(MusicService:SongInformation():await())
    self:MuteSong()

    MusicService.Update:Connect(function(SongName: string, SongVolume: number)
        self:SongInformation(true, SongName, SongVolume)
    end)

    self.GochiRadio.MuteButton.MouseButton1Down:Connect(function()
        self:RegisterMuteSong()
    end)
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Controller to Knit.
return MusicController