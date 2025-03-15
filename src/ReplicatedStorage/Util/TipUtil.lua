--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local GAMES_URL = "https://games.roproxy.com/v2/users/%s/games?limit=50"
local PASS_URL = "https://games.roproxy.com/v1/games/%s/game-passes?limit=50"

-- Class
local TipUtil = {}
TipUtil.__index = TipUtil

function TipUtil:_fetchGamepassesFromUniverse(universeId: number, cursor: string?)
    local compiledGamepassIds = {}
    local hasNextPage = true

    while hasNextPage do
        local requestUrl = string.format(PASS_URL..(cursor and "&cursor="..cursor or ""), universeId)
        local response = HttpService:GetAsync(requestUrl, false)
        local gamepassData = HttpService:JSONDecode(response)

        for _, data in gamepassData.data do
            table.insert(compiledGamepassIds, data.id)
        end

        cursor = gamepassData.nextPageCursor
        hasNextPage = cursor ~= nil
    end

    return compiledGamepassIds
end

function TipUtil:GetUserGamepasses(userId: number, cursor: string?)
    local gamepasses = {}
    local hasNextPage = true

    while hasNextPage do
        local requestUrl = string.format(GAMES_URL..(cursor and "&cursor="..cursor or ""), userId)
        local response = HttpService:GetAsync(requestUrl, false)
        local universeData = HttpService:JSONDecode(response)

        for _, universe in universeData.data do
            local universeGamepasses = self:_fetchGamepassesFromUniverse(universe.id)

            for _, gamepassId in universeGamepasses do
                table.insert(gamepasses, gamepassId)
            end
        end

        cursor = universeData.nextPageCursor
        hasNextPage = cursor ~= nil
    end

    return gamepasses
end

return TipUtil
