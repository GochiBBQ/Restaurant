--[[
                    __            __    __    _                __          
     ____  ____  ____/ /___  __  __/ /_  / /_  (_)___  _________/ /___ _____ 
    / __ \/ __ \/ __  / __ \/ / / / __ \/ __/ / / __ \/ ___/ __  / __ `/ __ \
     / / / / /_/ / /_/ / /_/ / /_/ / /_/ / /_  / / /_/ / /  / /_/ / /_/ / / / /
    /_/ /_/\____/\__,_/\____/\__,_/_.___/\__/_/ /\____/_/   \__,_/\__,_/_/ /_/ 
                                       /___/                               

    Author: nodoubtjordan
    For: Gochi Restaurant 🥩
    https://www.roblox.com/games/14203094444/Goch-Restaurant

]]

-- ————————— 🂡 —————————
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local PlayerService = game:GetService("Players")

-- ————————— 🂡 —————————
-- Modules
local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))

local PromiseModule = require(script:WaitForChild("Promise"))
local AssertModule = require(script:WaitForChild("Assert"))

-- ————————— 🂡 —————————
-- Variables
local DonationsLeaderboard = DataStoreService:GetOrderedDataStore("DonationsLeaderboard")

-- ————————— 🂡 —————————
-- Create the Knit Service
local LeaderboardService = Knit.CreateService {
	Name = "LeaderboardService",

	Client = {},
}

-- ————————— 🂡 —————————
-- Server Functions
function LeaderboardService:FormatNumbers(Amount: number)
    AssertModule.Ensure(Amount, "number")
end

function LeaderboardService:ReturnDonationAmount(Player: Player)
    local Profile: table? = Knit.Profiles[Player]["Data"]
    local Donations: number = Profile["Donations"]

    return Donations
end

function LeaderboardService:SetupLeaderboard()
    return PromiseModule.new(function(Resolve: any, Reject: any)
        local LeaderboardNumber = 100
        local MinimumValue = 1
        local MaximumValue = 999999999
        local SortedPages = DonationsLeaderboard:GetSortedPages(false, LeaderboardNumber, MinimumValue, MaximumValue)

        local TopPlayers = SortedPages:GetCurrentPage()
        local LeaderboardData = {}

        Resolve("Leaderboard setup!")
    end)
end

function LeaderboardService:KnitStart()
	while task.wait() do
        self:SetupLeaderboard():andThen(function()
            print("[LeaderboardService]: Successfully setup!")
        end):catch(function(Error: string)
            error("[LeaderboardService: "..Error)
        end)

        task.wait(300)
    end
end

-- ————————— 🂡 —————————
-- Return the service to Knit
return LeaderboardService