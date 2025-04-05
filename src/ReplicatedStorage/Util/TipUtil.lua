--[[
Author: alreadyfans
For: Gochi
]]

-- Services
local HttpService = game:GetService("HttpService")

-- Constants
local GAMES_URL = "https://games.roproxy.com/v2/users/%s/games?limit=50"
local PASS_URL = "https://games.roproxy.com/v1/games/%s/game-passes?limit=50"

-- Class
local TipUtil = {}
TipUtil.__index = TipUtil

-- Fetches all gamepasses for a single universe
function TipUtil:_fetchGamepassesFromUniverse(universeId: number, cursor: string?)
	local compiledGamepassIds = {}
	local hasNextPage = true

	while hasNextPage do
		local requestUrl = string.format(PASS_URL .. (cursor and "&cursor=" .. cursor or ""), universeId)
		local success, response = pcall(HttpService.GetAsync, HttpService, requestUrl, false)

		if not success then
			warn("Failed to fetch gamepasses for universe:", universeId, response)
			break
		end

		local decoded
		local ok, err = pcall(function()
			decoded = HttpService:JSONDecode(response)
		end)

		if not ok or not decoded or not decoded.data then
			warn("Failed to decode gamepass data for universe:", universeId)
			break
		end

		for _, data in decoded.data do
			table.insert(compiledGamepassIds, data.id)
		end

		cursor = decoded.nextPageCursor
		hasNextPage = cursor ~= nil
	end

	return compiledGamepassIds
end

-- Fetches all gamepasses owned by a user across their games
function TipUtil:GetUserGamepasses(userId: number, cursor: string?)
	local gamepasses = {}
	local hasNextPage = true

	while hasNextPage do
		local requestUrl = string.format(GAMES_URL .. (cursor and "&cursor=" .. cursor or ""), userId)
		local success, response = pcall(HttpService.GetAsync, HttpService, requestUrl, false)

		if not success then
			warn("Failed to fetch games for user:", userId, response)
			break
		end

		local decoded
		local ok, err = pcall(function()
			decoded = HttpService:JSONDecode(response)
		end)

		if not ok or not decoded or not decoded.data then
			warn("Failed to decode universe data for user:", userId)
			break
		end

		for _, universe in decoded.data do
			local universeGamepasses = self:_fetchGamepassesFromUniverse(universe.id)
			for _, gamepassId in universeGamepasses do
				table.insert(gamepasses, gamepassId)
			end
		end

		cursor = decoded.nextPageCursor
		hasNextPage = cursor ~= nil
	end

	return gamepasses
end

return TipUtil
