--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Create Knit Controller
local ChatController = Knit.CreateController {
    Name = "ChatController",

}

-- Variables
local ChatMessageToFormat = "<font color='#%s'>%s</font>"
local PrefixToFormat = "<font color='#%s'>[%s]</font> %s"

local Tags = {
    [106192999] = { -- arjun
        BackgroundColor = Color3.fromHex("393b3d"),
        MessageColor = Color3.fromHex("89cff0"),
    },
}

local PremiumTag = {
    PrefixColor = Color3.fromRGB(92, 66, 100),
    Prefix = "VIP"
}

local BoosterTag = {
    PrefixColor = Color3.fromRGB(228, 151, 208),
    Prefix = "BOOSTER"
}

-- Client Functions
function ChatController:KnitStart()
    self:CheckBubble()
    self:CheckText()
end

function ChatController:CheckBubble()
    TextChatService.OnBubbleAdded = function(message: TextChatMessage, adornee: Instance)
        local chatProperties = Instance.new("BubbleChatMessageProperties")

        if message.TextSource then
            local PlayerId = message.TextSource.UserId

            if Tags[PlayerId] then
                if Tags[PlayerId].BackgroundColor then
                    chatProperties.BackgroundColor3 = Tags[PlayerId].BackgroundColor
                    chatProperties.BackgroundTransparency = 0.1
                end
            end
        end

        return chatProperties
    end
end

function ChatController:CheckText()
    TextChatService.OnIncomingMessage = function(message: TextChatMessage)

        if message.Metadata == "Roblox.Team.Success.NowInTeam" then
            local override = Instance.new("TextChatMessageProperties")
            override.Text = " "
            return override
        end

        local properties = Instance.new("TextChatMessageProperties")

        if message.TextSource then
            local PlayerId = message.TextSource.UserId
            local Player = Players:GetPlayerByUserId(PlayerId)

            properties.PrefixText = (message.PrefixText:gsub(Player.DisplayName, Player.Name))

            if Player:GetAttribute("VIP") then
                properties.PrefixText = string.format(PrefixToFormat, PremiumTag.PrefixColor:ToHex(), PremiumTag.Prefix, Player.Name)
                properties.Text = string.format(ChatMessageToFormat, PremiumTag.PrefixColor:ToHex(), message.Text)
            end

            -- if Player:GetAttribute("Booster") then
            --     properties.PrefixText = string.format(PrefixToFormat, BoosterTag.PrefixColor:ToHex(), BoosterTag.Prefix, Player.Name)
            --     properties.Text = string.format(ChatMessageToFormat, BoosterTag.PrefixColor:ToHex(), message.Text)
            -- end

            if Tags[PlayerId] then
                if Tags[PlayerId].MessageColor then
                    properties.Text = string.format(ChatMessageToFormat, Tags[PlayerId].MessageColor:ToHex(), message.Text)
                end
            end
        end

        return properties
    end
end

 -- Return Controller to Knit.
return ChatController
