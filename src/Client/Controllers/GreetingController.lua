--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove) --- @module Trove

-- Create Knit Controller
local GreetingController = Knit.CreateController {
    Name = "GreetingController",
    Cooldown = 2,
    OnCooldown = false,
}

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local defaultMessages = {
	welcomeMessage = "Greetings, welcome to Gochí! I'll be assisting you today. How many people are in your party?",
	areaMessage = "Would you prefer to be arranged indoors, outdoors, or in our underwater dining?",
	seatingMessage = "Where would you liked to be seated? We offer tables and booths.",
	seatingConfirmationMessage = "Is this arrangement alright? If not, I would be happy to relocate you elsewhere.",
	beveragesMessage = "To start off, can I interest you in any of our beverages?",
	appetizersMessage = "Moving on, may I interest you in any of our appetizers?",
	entreesMessage = "Next up, can I interest you in any of our entrees?",
	dessertsMessage = "Finally, may I interest you in any of our desserts?",
	conclusionMessage = "Thanks for dining at Gochí! Please note that tips are available if you so choose, and we hope to see you again!",
}

local GreetingService

-- UI Elements
local GreetingUI = PlayerGui:WaitForChild("GochiUI"):WaitForChild("Greetings")
local ScrollingFrame = GreetingUI.Main.ScrollingFrame

-- Client Functions
function GreetingController:KnitStart()
    self._trove = Trove.new()
    self._saveTrove = Trove.new()
    self._editTrove = Trove.new()
    self._sendTrove = Trove.new()

    GreetingService = Knit.GetService("GreetingService")

    GreetingUI.Main.Draggable = true
    GreetingUI.Main.Active = true
    GreetingUI.Main.Selectable = true

    self._trove:Connect(GreetingService.Update, function(messages)
        for _, frame in pairs(ScrollingFrame:GetChildren()) do
            if frame:IsA("Frame") then
                frame.Greeting.Text = messages[frame.Name] or defaultMessages[frame.Name]
            end
        end
    end)

    self:Save()
    self:Edit()
    self:Send()
end

function GreetingController:Save()
    self._saveTrove:Clean()
    for _, frame in pairs(ScrollingFrame:GetChildren()) do
        if frame:IsA("Frame") then
            self._saveTrove:Connect(frame['Save'].MouseButton1Click, function()
                frame['Save'].Visible = false
                frame['Edit'].Visible = true
                frame.Greeting.TextEditable = false

                local messageType = frame.Name
                if frame.Greeting.Text == "" then
                    frame.Greeting.Text = defaultMessages[messageType]
                end

                GreetingService:ClientSave(messageType, frame.Greeting.Text)
            end)
        end
    end
end

function GreetingController:Edit()
    self._editTrove:Clean()
    for _, frame in pairs(ScrollingFrame:GetChildren()) do
        if frame:IsA("Frame") then
            self._editTrove:Connect(frame['Edit'].MouseButton1Click, function()
                frame['Save'].Visible = true
                frame['Edit'].Visible = false
                frame.Greeting.TextEditable = true
                frame.Greeting.ClearTextOnFocus = false
            end)
        end
    end
end

function GreetingController:Send()
    self._sendTrove:Clean()

    for _, frame in pairs(ScrollingFrame:GetChildren()) do
        if frame:IsA("Frame") then
            self._sendTrove:Connect(frame['Send'].MouseButton1Click, function()
                if not self.OnCooldown then
                    self.OnCooldown = true

                    local messageType = frame.Name

                    if frame.Greeting.Text == "" then
                        frame.Greeting.Text = defaultMessages[messageType]
                    end

                    GreetingService:ClientSend(frame.Greeting.Text):andThen(function()
                        task.delay(self.Cooldown, function()
                            self.OnCooldown = false
                        end)
                    end)
                end
            end)
        end
    end

    if not self.sendMessageConnected then
        self.sendMessageConnected = true
        self._sendTrove:Connect(GreetingService.SendMessage, function(senderPlayer, message)
            local Name = senderPlayer.Name
            local Color = senderPlayer.TeamColor.Color

            if senderPlayer.DisplayName then
                Name = senderPlayer.DisplayName
            end

            local rgbColor = string.format("%d, %d, %d", Color.R * 255, Color.G * 255, Color.B * 255)
            local formattedMessage = string.format('<font color="rgb(%s)">%s:</font> %s', rgbColor, Name, message)

            TextChatService:WaitForChild('TextChannels').RBXGeneral:DisplaySystemMessage(formattedMessage)
        end)
    end
end

-- Return Controller to Knit.
return GreetingController
