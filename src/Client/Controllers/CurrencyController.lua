--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local AnimNation = require(Knit.Modules.AnimNation) --- @module AnimNation

-- Create Knit Controller
local CurrencyController = Knit.CreateController {
    Name = "CurrencyController",
}

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local GochiUI = PlayerGui:WaitForChild("GochiUI")
local Profiler = GochiUI:WaitForChild("Profiler")

local Headshot = Profiler.Content.ProfileBase.Headshot

local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420
local content, isReady = Players:GetUserThumbnailAsync(Player.UserId, thumbType, thumbSize)

local RankService, CurrencyService

-- Client Functions
local function comma_value(amount)
    local formatted = amount
    while true do  
      formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
      if (k==0) then
        break
      end
    end
    return formatted
  end

local function LerpNumber(StartNumber, EndNumber)
    local StartTime = tick()
    local Duration = 3 -- Default duration of 3 seconds
    while true do
        local CurrentTime = tick()
        local ElapsedTime = CurrentTime - StartTime
        if ElapsedTime > Duration then break end
        local Alpha = ElapsedTime / Duration
        local CurrentValue = StartNumber + (EndNumber - StartNumber) * Alpha
        Profiler.Content.Coins.Text = `<b>{comma_value(math.round(CurrentValue))}</b> Coins`
        RunService.Stepped:Wait()
    end
    Profiler.Content.Coins.Text = `<b>{comma_value(EndNumber)}</b> Coins`
end

function CurrencyController:KnitStart()
    RankService = Knit.GetService("RankService")
    CurrencyService = Knit.GetService("CurrencyService")

    Profiler.Content.Username.Text = Player.Name
    Headshot.Image = content

    RankService:Get():andThen(function(Rank, Role)
        Profiler.Content.Rank.Text = Role
    end)

    CurrencyService:GetCoins():andThen(function(Coins)
        Profiler.Content.Coins.Text = `{comma_value(Coins)} Coins`
    end)

    CurrencyService.UpdateClient:Connect(function(Old, New)
       LerpNumber(tonumber(Old), tonumber(New))
    end)
end

 -- Return Controller to Knit.
return CurrencyController
