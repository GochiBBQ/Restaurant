--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local AnimNation = require(Knit.Modules.AnimNation) --- @module AnimNation

-- Create Knit Controller
local ExperienceController = Knit.CreateController {
    Name = "ExperienceController",
}

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local GochiUI = PlayerGui:WaitForChild("GochiUI")
local Profiler = GochiUI:WaitForChild("Profiler")

local Headshot = Profiler.Content.ProfileBase.Headshot
local ProgressBase = Profiler.Content.ProgressBase

local ProgressBar = ProgressBase.Progress.Filler
local XP = ProgressBase.XP

local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420
local content, isReady = Players:GetUserThumbnailAsync(Player.UserId, thumbType, thumbSize)

local RankService, ExperienceService

-- Client Functions
function ExperienceController:KnitStart()
    RankService = Knit.GetService("RankService")
    ExperienceService = Knit.GetService("ExperienceService")

    Profiler.Content.Username.Text = Player.Name
    Headshot.Image = content

    ExperienceService:GetXP():andThen(function(Experience, Required, Level)
        XP.Text = `{Experience} / {Required} XP`
        if Experience / Required < 1 then
            AnimNation.target(ProgressBar, {s = 8}, {Size = UDim2.new(Experience / Required, 0, 1, 0)})
        else
            AnimNation.target(ProgressBar, {s = 8}, {Size = UDim2.new(1, 0, 1, 0)})
        end
        Profiler.Content.Level.Text = `Level <b>{Level}</b>`
    end)


    ExperienceService.UpdateClient:Connect(function(Experience, Required, Level)
        XP.Text = `{Experience} / {Required} XP`
        if Experience / Required < 1 then
            AnimNation.target(ProgressBar, {s = 8}, {Size = UDim2.new(Experience / Required, 0, 1, 0)})
        else
            AnimNation.target(ProgressBar, {s = 8}, {Size = UDim2.new(1, 0, 1, 0)})
        end
        Profiler.Content.Level.Text = `Level <b>{Level}</b>`
    end)
end

 -- Return Controller to Knit.
return ExperienceController
