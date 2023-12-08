local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local ZonesPlus = require(ReplicatedStorage.Modules.ZonePlus)
local ZonesPlusController = require(ReplicatedStorage.Modules.ZonePlus.ZoneController)
local spr = require(ReplicatedStorage.Modules.spr)

local KaraokeGroup = ZonesPlusController.setGroup('Karaoke', {
    onlyEnterOnceExitedAll = false
})

local KaraokeController = Knit.CreateController {
    Name = "KaraokeController";
}

local KaraokeDir = workspace.Functionality.Activities.Karaoke

function KaraokeController:KnitStart()
    local Player = Players.LocalPlayer

    for _,roomSpace in ipairs(KaraokeDir.Spaces:GetChildren()) do
        local Zone = ZonesPlus.new(roomSpace)

        Zone:bindToGroup(KaraokeGroup)

        Zone.localPlayerEntered:Connect(function()
            spr.target(KaraokeDir.Music[roomSpace.Name], 1, 3, { Volume = 0.5})
            spr.target(workspace.Music, 1, 3, { Volume = 0})
        end)
        
        Zone.localPlayerExited:Connect(function()
            spr.target(KaraokeDir.Music[roomSpace.Name], 1, 3, { Volume = 0})
            spr.target(workspace.Music, 1, 3, { Volume = 0.5})
        end)
    end
end

return KaraokeController