--[[

█▀▀▄ █▀▀█ █▀▀▄ █▀▀█ █░░█ █▀▀▄ ▀▀█▀▀ ▀▀█ █▀▀█ █▀▀ █░█ 
█░░█ █░░█ █░░█ █░░█ █░░█ █▀▀▄ ░░█░░ ▄▀░ █▄▄█ █░░ █▀▄ 
▀░░▀ ▀▀▀▀ ▀▀▀░ ▀▀▀▀ ░▀▀▀ ▀▀▀░ ░░▀░░ ▀▀▀ ▀░░▀ ▀▀▀ ▀░▀

Author: nodoubtzack
For: Sakura Kitchen 🥢
https://www.roblox.com/groups/6975354/Sakura-Kitchen#!/about

]]

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)

local Trove = require(ReplicatedStorage.Packages.Trove)
local trove = Trove.new()

local RateLimiter = require(Knit.Modules.RateLimiter)
local RequestRateLimiter = RateLimiter.NewRateLimiter(4)

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Create Knit Service
local SubscriptionService = Knit.CreateService {
	Name = "SubscriptionService",
	Client = {
		Send = Knit.CreateSignal()
	},
}

local FreeSubscriptions = {
    -- Leadership Team
    54753551, -- Zack's Account
    117862085, -- Yoselyn's Account
    261702036, -- Ellie's Account

    -- Development Team
    383896135, -- Jordan's Account
    101402788, -- Icy's Account
    114097134, -- Light's Account
    284307731, -- Morgan's Account

    -- Alternative Accounts
    3332680162, -- Zack's Alt Account
    118398411, -- Zack's Friend's Account
}

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Functions
local function checkDate(Expiration: number, Current: number)
    return os.difftime(os.time(Expiration), os.time(Current)) < 0
end

local function getFormatted(unix)
    unix = unix or os.time()

    local Formatted = {
        year = tonumber(os.date('%Y', unix)),
        month = tonumber(os.date('%m', unix)),
        day = tonumber(os.date('%d', unix)),
    }

    return Formatted
end

--- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Server Functions
function SubscriptionService:AddSubscription(Player: Player, Days: number)
    local Active, Expiration = self:GetSubscription(Player)
    local Profile = Knit.Profiles[Player]
    
    local Seconds = Days * 24 * 60 * 60
    local NewExpiration

    if (Active) and (Expiration.year) then
        NewExpiration = os.time(Expiration) + Seconds
    else
        NewExpiration = os.time() + Seconds
    end

    local Formatted = getFormatted(NewExpiration)
	Profile.Data.SakuraPremium.Active = true
	Profile.Data.SakuraPremium.Expiration = Formatted

    self:ValidateSubscription(Player)

    return true, Formatted
end

function SubscriptionService:RemoveSubscription(Player: Player)
    local Profile = Knit.Profiles[Player]

    Profile.Data.SakuraPremium.Active = false
	Profile.Data.SakuraPremium.Expiration = {}

    SubscriptionService:ValidateSubscription(Player)
end

function SubscriptionService:ValidateSubscription(Player: Player)
    local Active, Expiration = self:GetSubscription(Player)
    local Profile = Knit.Profiles[Player]

    if table.find(FreeSubscriptions, Player.UserId) then
		Profile.Data.SakuraPremium.Active = true
		Profile.Data.SakuraPremium.Expiration = {}
    end

    if Active then
        if Expiration.year then
            local CurrentLoginFormatted = getFormatted()

			if checkDate(Profile.Data.SakuraPremium.Expiration, CurrentLoginFormatted) then
				Profile.Data.SakuraPremium.Active = false
				Profile.Data.SakuraPremium.Expiration = {}

                -- Check for the Legacy V1 VIP
				if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, 13589024) then
					if Profile.Data.SakuraPremium.Legacy ~= true then
						Profile.Data.SakuraPremium.Legacy = true
                        local Seconds = 91 * 24 * 60 * 60
                        local NewExpiration = os.time() + Seconds

                        local Formatted = getFormatted(NewExpiration)
						Profile.Data.SakuraPremium.Expiration = Formatted
                    end
                end
            end
        else
            if not table.find(FreeSubscriptions, Player.UserId) then
				Profile.Data.SakuraPremium.Active = false
				Profile.Data.SakuraPremium.Expiration = {}
            end
        end
    end

    self.Client.Send:Fire(Player)
end

function SubscriptionService:GetSubscription(Player: Player)
    repeat task.wait() until Knit.Profiles[Player]
    
	local PremiumData = Knit.Profiles[Player].Data.SakuraPremium
    
    if PremiumData.Active then
        return PremiumData.Active, PremiumData.Expiration
    else
        return nil
    end
end

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Client Functions
function SubscriptionService.Client:GetSubscription(Player)
    return self.Server:GetSubscription(Player)
end

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Loaded Functions
trove:Add(Knit.Signals.PlayerLoaded:Connect(function(Player: Player)
    SubscriptionService:ValidateSubscription(Player)
end))

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Return Service to Knit
return SubscriptionService