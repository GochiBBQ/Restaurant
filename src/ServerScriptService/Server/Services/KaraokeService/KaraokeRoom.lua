local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local ZonesPlus = require(ReplicatedStorage.Modules.ZonePlus)
local SongLyrics = require(script.Parent.SongsLyrics)
local HttpService = game:GetService("HttpService")

local KaraokeRoom = {}
KaraokeRoom.__index = KaraokeRoom

function KaraokeRoom.new(roomSpace: Part)
    local self = setmetatable({}, KaraokeRoom)

    self.RoomSpace = roomSpace
    self.Sound = workspace.Functionality.Karaoke.Music[roomSpace.Name]
    self.SelectedSound = nil
    self.PreviousId = nil
    self.Lyrics = nil
    self.Players = {}

    self.NewSong = Instance.new("BindableEvent")

    return self
end

function KaraokeRoom:GetLyrics()
    local response
    pcall(function()
        response = HttpService:GetAsync(`https://spotify-lyric-api-984e7b4face0.herokuapp.com/?url=https://open.spotify.com/track/{self.SelectedSound.SpotifyId}?autoplay=true`)
    end)

	if response then
	    response = HttpService:JSONDecode(response)
	    if response.error then return false end
        return response.lines
    else
        return false
	end
end

function KaraokeRoom:PlayRandom()
	local SelectedSound = SongLyrics[math.random(1, #SongLyrics)]

    if self.PreviousId then
        while self.PreviousId == SelectedSound do
            SelectedSound = SongLyrics[math.random(1, #SongLyrics)]
        end
    end

	self.SelectedSound = SelectedSound
	self:Play(SelectedSound.Id, SelectedSound.Speed)
    
    self.Lyrics = self:GetLyrics()

    self.NewSong:Fire()
end

function KaraokeRoom:Play(MusicId: number, Speed: number)
    self.PreviousId = MusicId
    self.Sound.SoundId = "rbxassetid://" .. MusicId
    self.Sound.PlaybackSpeed = Speed
    self.Sound.TimePosition = 0
    print('Playing!')
    self.Sound:Play()
end

function KaraokeRoom:Initialize()
    local Zone = ZonesPlus.new(self.RoomSpace)
    
    Zone.playerEntered:Connect(function(player)
        table.insert(self.Players, player)
        --print(player.Name .. " entered the karaoke room")
    end)

    Zone.playerExited:Connect(function(player)
        table.remove(self.Players, table.find(self.Players, player))
        --print(player.Name .. " left the karaoke room")
    end)

    task.wait(10)

    self:PlayRandom()

    self.Sound.Ended:Connect(function()
        self:PlayRandom()
    end)
end

return KaraokeRoom