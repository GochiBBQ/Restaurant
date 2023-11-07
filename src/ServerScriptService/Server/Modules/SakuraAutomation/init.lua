-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Services
local HttpService = game:GetService("HttpService")
local HttpQueue = require(script.HttpQueue)

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Variables
local SakuraModule = {}

--[[
	Queueing a new request
	- HttpQueue.HttpRequest.new()

	PLEASE USE THIS JORDAN AS IT QUEUES REQUEST AND HELPS KEEP US WITHIN THE RATE LIMIT
]]

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Activity Tracking
function SakuraModule:CreateSession(Player: Player)
	-- Creates a new activity sessions for player so that the website knows the minutes are live.
end

function SakuraModule:EndSession(Player: Player, Minutes: number)
	-- Ends the activity session for player so that minutes are added to the website.

	if Minutes >= 1 then
		-- log and end session
	else
		-- dont log minutes but end the session so that they aren't live on dashboard
	end
end

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Blacklist Tracking
function SakuraModule:CheckBlacklist(Player: Player)
	-- return true for blacklist with reason, return false if not
	-- staff blacklists
end

function SakuraModule:Blacklist(Player: Player, Reason: string)
	-- post request to blacklist user
	-- staff blacklists
end

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Discord Tracking
function SakuraModule:CheckBooster(Player: Player)
	-- return true for boosting false if not
end

return SakuraModule