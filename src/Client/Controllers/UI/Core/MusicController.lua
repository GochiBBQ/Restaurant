--[[

█▀▀▄ █▀▀█ █▀▀▄ █▀▀█ █░░█ █▀▀▄ ▀▀█▀▀ ▀▀█ █▀▀█ █▀▀ █░█ 
█░░█ █░░█ █░░█ █░░█ █░░█ █▀▀▄ ░░█░░ ▄▀░ █▄▄█ █░░ █▀▄ 
▀░░▀ ▀▀▀▀ ▀▀▀░ ▀▀▀▀ ░▀▀▀ ▀▀▀░ ░░▀░░ ▀▀▀ ▀░░▀ ▀▀▀ ▀░▀

Author: nodoubtzack
For: Gochí Restaurant 🥩
https://www.roblox.com/groups/5874921/Goch#!/about

]]

-- »»————————————　★　————————————-««
-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- »»————————————　★　————————————-««
-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local spr = require(Knit.Modules.spr)

-- »»————————————　★　————————————-««
-- Variables
local MusicPlayer = workspace.Music
local UIController = nil
local MusicService = nil

-- »»————————————　★　————————————-««
-- Create Knit Controller
local MusicController = Knit.CreateController {
    Name = "MusicController",
    MuteDebounce = false,
    CurrentVolume = 0
}

-- »»————————————　★　————————————-««
-- Client Functions
function MusicController:InformationLinkage(SongName: string, SongVolume: number)
    self.GochiRadio.Song.Text = SongName or "Loading..."
    self.CurrentVolume = SongVolume
end

function MusicController:RegisterMuteSong()
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
    self.GochiRadio = UIController.UI.Parent:WaitForChild("Radio").GochiMusic

    MusicService:GetCurrentSong():andThen(function(SongName: string, SongVolume: number)
        self:InformationLinkage(SongName, SongVolume)
    end)

    MusicService.Update:Connect(function(SongName: string, SongVolume: number)
        self:SongInformation(true, SongName, SongVolume)
    end)

    self.GochiRadio.MuteButton.MouseButton1Down:Connect(function()
        self:RegisterMuteSong()
    end)
end

-- »»————————————　★　————————————-««
 -- Return Controller to Knit.
return MusicController
