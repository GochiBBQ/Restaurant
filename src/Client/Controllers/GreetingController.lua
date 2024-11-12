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
--[[
    Initializes the GreetingController by setting up the GreetingService and configuring the GreetingUI.
    Makes the main GreetingUI draggable, active, and selectable.
    Connects to the GreetingService's Update event to update greeting messages in the UI.
    Calls Save, Edit, and Send methods for additional functionality.

    @function KnitStart
    @within GreetingController
]]
function GreetingController:KnitStart()

    GreetingService = Knit.GetService("GreetingService")

    GreetingUI.Main.Draggable = true
    GreetingUI.Main.Active = true
    GreetingUI.Main.Selectable = true

    GreetingService.Update:Connect(function(messages)
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

--[[
    Saves the current state of the greeting frames.
    Iterates through all children of the ScrollingFrame, and for each frame, connects the Save button's click event to a function that hides the Save button, shows the Edit button, makes the greeting text non-editable, sets a default message if the greeting text is empty, and calls the GreetingService to save the message.

    @function Save
    @within GreetingController
]]
local saveConnections = {}

function GreetingController:Save()
    for _, frame in pairs(ScrollingFrame:GetChildren()) do
        if frame:IsA("Frame") then
            if saveConnections[frame] then
                saveConnections[frame]:Disconnect()
            end
            saveConnections[frame] = frame['Save'].MouseButton1Click:Connect(function()

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

--[[
    @function Edit
    @within GreetingController
]]
local editConnections = {}

function GreetingController:Edit()
    for _, frame in pairs(ScrollingFrame:GetChildren()) do
        if frame:IsA("Frame") then
            if editConnections[frame] then
                editConnections[frame]:Disconnect()
            end
            editConnections[frame] = frame['Edit'].MouseButton1Click:Connect(function()
                
                frame['Save'].Visible = true
                frame['Edit'].Visible = false

                frame.Greeting.TextEditable = true
                frame.Greeting.ClearTextOnFocus = false
            end)
        end
    end
end

--[[
    Sends a greeting message when a button is clicked.
    Iterates through all frames in the ScrollingFrame, connects the MouseButton1Click event of the 'Send' button to a function that sends a greeting message if not on cooldown.
    Sets the greeting text to a default message if it is empty, sends the message using GreetingService, and handles the cooldown period.
    Also connects to the GreetingService.SendMessage event to display formatted messages in the TextChatService.

    @function Send
    @within GreetingController
]]
local sendConnections = {}

function GreetingController:Send()
    for _, frame in pairs(ScrollingFrame:GetChildren()) do
        if frame:IsA("Frame") then
            if sendConnections[frame] then
                sendConnections[frame]:Disconnect()
            end
            sendConnections[frame] = frame['Send'].MouseButton1Click:Connect(function()
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
        GreetingService.SendMessage:Connect(function(senderPlayer, message)
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

return GreetingController
