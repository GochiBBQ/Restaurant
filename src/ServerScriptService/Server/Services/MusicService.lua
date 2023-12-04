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
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local trove = Trove.new()

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Service
local MusicService = Knit.CreateService {
    Name = "MusicService",
	Client = {
        Update = Knit:CreateSignal()
	},
}

local MusicPlayer = workspace.Music
local Playlist = script.SongList:GetChildren()

MusicService.CurrentSong = nil
MusicService.CurrentVolume = 0
MusicService.PastSong = nil

-- ————————— ↢ ⭐️ ↣ —————————-
-- Server Functions
function MusicService:SongSelection(CurrentSong: Sound)
    repeat CurrentSong = Playlist[math.random(1, #Playlist)] until CurrentSong.Name ~= self.PastSong
    return CurrentSong
end

function MusicService:CheckCopyright(CurrentSong: Sound)
    local Asset = MarketplaceService:GetProductInfo(tonumber(string.split(CurrentSong.SoundId, "rbxassetid://")[2]))
    if Asset.Name == "(Removed for copyright)" then return true end
end

function MusicService:SoundEffects(CurrentSong: Sound)
    MusicPlayer.TimePosition = 0
    MusicPlayer.PlaybackSpeed = CurrentSong.PlaybackSpeed
    MusicPlayer.SoundId = CurrentSong.SoundId
    MusicPlayer.Volume = CurrentSong.Volume
end

function MusicService:SkipSong()
    MusicPlayer.TimePosition = self.CurrentSong.TimeLength
end

function MusicService:KnitStart()
    while task.wait() do
        if not MusicPlayer.IsPlaying then
            local CurrentSong = self:SongSelection()
            if self:CheckCopyright(CurrentSong) then return end

            self:SoundEffects(CurrentSong)
            self.CurrentSong = CurrentSong
            MusicPlayer:Play()

            self.Client.Update:FireAll(CurrentSong.Name, CurrentSong.Volume)
            MusicPlayer.Ended:Wait()

            self.PastSong = CurrentSong
            self.CurrentSong = nil
        end
    end
end

-- ————————— ↢ ⭐️ ↣ —————————-
-- Client Functions
function MusicService.Client:SongInformation(Player: Player)
    return MusicService.CurrentSong, MusicService.CurrentVolume
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Service to Knit.
return MusicService