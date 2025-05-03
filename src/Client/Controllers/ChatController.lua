--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local TextChatService: TextChatService = game:GetService("TextChatService")
local Players: Players = game:GetService("Players")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)
local Trove: ModuleScript = require(ReplicatedStorage.Packages.Trove) --- @module Trove

-- Create Knit Controller
local ChatController = Knit.CreateController {
    Name = "ChatController",
}

-- Constants
local ChatMessageToFormat: string = "<font color='#%s'>%s</font>"
local PrefixToFormat: string = "<font color='#%s'>[%s]</font> %s"

local Tags: table = {
    [106192999] = { -- arjun
        BackgroundColor = Color3.fromHex("393b3d"),
        MessageColor = Color3.fromHex("89cff0"),
    },
}

local PremiumTag: table = {
    PrefixColor = Color3.fromRGB(92, 66, 100),
    Prefix = "VIP"
}

local BoosterTag: table = {
    PrefixColor = Color3.fromRGB(228, 151, 208),
    Prefix = "BOOSTER"
}

-- Trove Instance
ChatController._trove = Trove.new()

-- Knit Start
function ChatController:KnitStart()
    self:CheckBubble()
    self:CheckText()
end

-- Bubble Chat Formatting
function ChatController:CheckBubble()
    local bubbleHandler = function(message: TextChatMessage, adornee: Instance)
        local chatProperties = Instance.new("BubbleChatMessageProperties")

        if message.TextSource then
            local PlayerId = message.TextSource.UserId

            if Tags[PlayerId] and Tags[PlayerId].BackgroundColor then
                chatProperties.BackgroundColor3 = Tags[PlayerId].BackgroundColor
                chatProperties.BackgroundTransparency = 0.1
            end
        end

        return chatProperties
    end

    TextChatService.OnBubbleAdded = bubbleHandler
    self._trove:Add(function()
        if TextChatService.OnBubbleAdded == bubbleHandler then
            TextChatService.OnBubbleAdded = nil
        end
    end)
end

-- Text Chat Formatting
function ChatController:CheckText()
    local textHandler = function(message: TextChatMessage)
        if message.Metadata == "Roblox.Team.Success.NowInTeam" then
            local override = Instance.new("TextChatMessageProperties")
            override.Text = " "
            return override
        end

        local properties = Instance.new("TextChatMessageProperties")

        if message.TextSource then
            local PlayerId = message.TextSource.UserId
            local Player = Players:GetPlayerByUserId(PlayerId)

            if Player then
                properties.PrefixText = (message.PrefixText:gsub(Player.DisplayName, Player.Name))

                -- VIP
                if Player:GetAttribute("VIP") then
                    local hex = PremiumTag.PrefixColor:ToHex()
                    properties.PrefixText = string.format(PrefixToFormat, hex, PremiumTag.Prefix, Player.Name)
                    properties.Text = string.format(ChatMessageToFormat, hex, message.Text)
                end

                -- Custom Tag Coloring
                if Tags[PlayerId] and Tags[PlayerId].MessageColor then
                    properties.Text = string.format(ChatMessageToFormat, Tags[PlayerId].MessageColor:ToHex(), message.Text)
                end
            end
        end

        return properties
    end

    TextChatService.OnIncomingMessage = textHandler
    self._trove:Add(function()
        if TextChatService.OnIncomingMessage == textHandler then
            TextChatService.OnIncomingMessage = nil
        end
    end)
end

-- Return Controller to Knit.
return ChatController
