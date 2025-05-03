--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService: RunService = game:GetService("RunService")
local Players: Players = game:GetService("Players")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)
local Trove: ModuleScript = require(ReplicatedStorage.Packages.Trove) --- @module Trove

-- Create Knit Controller
local CurrencyController = Knit.CreateController {
    Name = "CurrencyController",
}

-- Variables
local Player: Player = Players.LocalPlayer
local PlayerGui: Player = Player:WaitForChild("PlayerGui")

local GochiUI: GuiObject = PlayerGui:WaitForChild("GochiUI")
local Profiler: GuiObject = GochiUI:WaitForChild("Profiler")

local Headshot: GuiObject = Profiler.Content.ProfileBase.Headshot

local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420
local content, isReady = Players:GetUserThumbnailAsync(Player.UserId, thumbType, thumbSize)

local RankService, CurrencyService

local activeLerpConn: boolean = nil

-- Trove Instance
CurrencyController._trove = Trove.new()

-- Client Functions
local function comma_value(amount)
    local formatted = tostring(amount)
    formatted = formatted:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if formatted:sub(1, 1) == "," then
        formatted = formatted:sub(2)
    end
    return formatted
end

local function LerpNumber(StartNumber, EndNumber)
    if activeLerpConn then
        activeLerpConn:Disconnect()
    end

    local StartTime = tick()
    local Duration = 3

    activeLerpConn = RunService.Heartbeat:Connect(function()
        local ElapsedTime = tick() - StartTime
        if ElapsedTime > Duration then
            Profiler.Content.Coins.Text = string.format("<b>%s</b> Coins", comma_value(EndNumber))
            activeLerpConn:Disconnect()
            activeLerpConn = nil
            return
        end

        local Alpha = ElapsedTime / Duration
        local CurrentValue = StartNumber + (EndNumber - StartNumber) * Alpha
        Profiler.Content.Coins.Text = string.format("<b>%s</b> Coins", comma_value(math.round(CurrentValue)))
    end)

    CurrencyController._trove:Add(activeLerpConn)
end


function CurrencyController:KnitStart()
    RankService = Knit.GetService("RankService")
    CurrencyService = Knit.GetService("CurrencyService")

    Profiler.Content.Username.Text = Player.Name
    Headshot.Image = content

    RankService:Get():andThen(function(Rank, Role)
        Profiler.Content.Rank.Text = Role
    end):catch(function(err)
        warn("Failed to get rank: " .. tostring(err))
    end)

    CurrencyService:GetCoins():andThen(function(Coins)
        Profiler.Content.Coins.Text = string.format("%s Coins", comma_value(Coins))
    end):catch(function(err)
        warn("Failed to get coins: " .. tostring(err))
    end)

    local updateConn = CurrencyService.UpdateClient:Connect(function(Old, New)
        LerpNumber(tonumber(Old), tonumber(New))
    end)

    self._trove:Add(updateConn)
end

-- Return Controller to Knit.
return CurrencyController
