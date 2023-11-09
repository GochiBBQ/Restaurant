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
function MusicService:KnitStart()
    while task.wait() do
        if not MusicPlayer.IsPlaying then
            local ChosenSong = Playlist[math.random(1, #Playlist)]
            local Asset = MarketplaceService:GetProductInfo(tonumber(string.split(ChosenSong.SoundId, "rbxassetid://")[2]))
            if Asset.Name ~= "(Removed for copyright)" then
                MusicPlayer.SoundId = ChosenSong.SoundId
                MusicPlayer.Volume = ChosenSong.Volume
                self.CurrentSong = ChosenSong.Name
                self.CurrentVolume = ChosenSong.Volume

                if ChosenSong:FindFirstChild("ChorusSoundEffect") then 
                    local ClonedEffect = ChosenSong:FindFirstChild("ChorusSoundEffect"):Clone()
                    ClonedEffect.Parent = MusicPlayer
                end

                if ChosenSong:FindFirstChild("PitchShiftSoundEffect") then
                    local ClonedEffect = ChosenSong:FindFirstChild("PitchShiftSoundEffect"):Clone()
                    ClonedEffect.Parent = MusicPlayer
                end

                MusicPlayer:Play()
                self.Client.Update:FireAll(ChosenSong.Name, ChosenSong.Volume)
                MusicPlayer.Ended:Wait()

                if MusicPlayer:FindFirstChild("ChorusSoundEffect") then 
                    MusicPlayer:FindFirstChild("ChorusSoundEffect"):Destroy()
                end

                if MusicPlayer:FindFirstChild("PitchShiftSoundEffect") then
                    MusicPlayer:FindFirstChild("PitchShiftSoundEffect"):Destroy()
                end
            end
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