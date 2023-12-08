local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local KaraokeService = Knit.CreateService {
    Name = "KaraokeService";
    Client = {
        NewSong = Knit:CreateSignal();
    };
    KaraokeRooms = {};
}

function KaraokeService.Client:GetPlaying(Player:Player, roomName: string)
    if KaraokeService.KaraokeRooms[roomName] then
        return KaraokeService.KaraokeRooms[roomName]
    end

    return false
end

function KaraokeService:KnitStart()
    local KaraokeRoom = require(script.KaraokeRoom)

    for _, roomSpace in ipairs(workspace.Functionality.Activities.Karaoke.Spaces:GetChildren()) do
        local karaokeRoom = KaraokeRoom.new(roomSpace)

        karaokeRoom.NewSong.Event:Connect(function()
            self.Client.NewSong:FireAll(roomSpace.Name, karaokeRoom)
        end)

        karaokeRoom:Initialize()

        self.KaraokeRooms[roomSpace.Name] = karaokeRoom
    end
end

return KaraokeService