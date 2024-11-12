--[[

Author: alreadyfans
For: Gochi

]]

-- ————————— 🂡 —————————
-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TextChatService = game:GetService("TextChatService")
local TextService = game:GetService("TextService")
local Players = game:GetService('Players')
local Chat = game:GetService("Chat")

-- ————————— 🂡 —————————
-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

-- ————————— 🂡 —————————
-- Create Knit Service
local GreetingService = Knit.CreateService({
	Name = "GreetingService",
	MessageSent = Signal.new(),

	Client = {
		SendMessage = Knit.CreateSignal(),
		Save = Knit.CreateSignal(),
		Update = Knit.CreateSignal(),
	},
})

-- ————————— 🂡 —————————
-- Variables

--[[
    Contains default greeting messages for the restaurant service.
    These messages are used to interact with customers and guide them through the dining experience.

    @table defaultMessages
    @within GreetingService
    @field welcomeMessage The initial greeting message for customers.
    @field areaMessage The message asking customers for their seating preference.
    @field seatingMessage The message asking customers where they would like to be seated.
    @field seatingConfirmationMessage The message confirming the seating arrangement.
    @field beveragesMessage The message offering beverages to customers.
    @field appetizersMessage The message offering appetizers to customers.
    @field entreesMessage The message offering entrees to customers.
    @field dessertsMessage The message offering desserts to customers.
    @field conclusionMessage The final message thanking customers for dining and mentioning tips.
]]
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

local DataService

-- ————————— 🂡 —————————
-- Server Functions
--[[
    Starts the GreetingService by setting up the PlayerAdded event listener.
    Waits until the player's "Loaded" attribute is true, then fires the Update event on the client with the player's messages data.

    @function KnitStart
    @within GreetingService
]]
function GreetingService:KnitStart() 
    DataService = Knit.GetService("DataService")

    Players.PlayerAdded:Connect(function(Player)
        repeat task.wait() until Player:GetAttribute("Loaded")

        if Knit.Profiles[Player] then
            self.Client.Update:Fire(Player, Knit.Profiles[Player].Data.Greetings)
        end
    end)
end

--[[
    Sets a greeting message for a player based on the message type.
    If the player profile does not exist, the function returns immediately.
    If the message type already exists in the player's greetings, it updates the message.
    If the provided message is an empty string, it sets the message to a default value.

    @function Set
    @param Player Player -- The player for whom the greeting message is being set.
    @param MessageType string -- The type of greeting message (e.g., welcome, goodbye).
    @param message string -- The greeting message to set. If empty, the default message is used.
    @within GreetingService
]]
function GreetingService:Set(Player: Player, MessageType: string, message: string)
    local Profile = Knit.Profiles[Player]
    if not Profile then
        return
    end

    if Profile.Data.Greetings[MessageType] then
        if message == "" then
            Profile.Data.Greetings[MessageType] = defaultMessages[MessageType]
        else
            Profile.Data.Greetings[MessageType] = message  
        end
    end
end

--[[
    Sends a filtered chat message from the server to a specific player and broadcasts it to all clients.
    Filters the message to ensure it adheres to Roblox's chat filtering guidelines, then sends the filtered message to the specified player and all other clients. Also triggers a chat event for the player's character.

    @function Send
    @within GreetingService
    @param Player Player -- The player to whom the message is being sent.
    @param message string -- The message to be sent, which will be filtered before sending.
]]
function GreetingService:Send(Player: Player, message: string)
    local success, error = pcall(function()
        local filtered = TextService:FilterStringAsync(message, Player.UserId)
		local finalFilter = tostring(filtered:GetChatForUserAsync(Player.UserId))
		local channel = TextChatService:WaitForChild('TextChannels'):WaitForChild('RBXSystem')
		local character = Player.Character or Player.CharacterAdded:Wait()

        self.MessageSent:Fire(Player, finalFilter)
        self.Client.SendMessage:FireAll(Player, finalFilter)
        Chat:Chat(character, finalFilter, Enum.ChatColor.White)
    end)
end

-- Client Functions

--[[
    Sends a message from the client to the server.
    This function is called by the client to send a message to the server, which then handles the message accordingly.

    @function ClientSend
    @param Player Player -- The player sending the message.
    @param message string -- The message being sent.
    @within GreetingService.Client
]]
function GreetingService.Client:ClientSend(Player: Player, message: string)
    self.Server:Send(Player, message)
end

--[[
    Handles the client-side save operation for a player.
    This function is called by the client to save a message of a specific type for the player.
    It delegates the actual saving operation to the server-side `Set` method.

    @function ClientSave
    @param Player Player -- The player who is saving the message.
    @param MessageType string -- The type of the message being saved.
    @param message string -- The content of the message being saved.
    @within GreetingService.Client
]]
function GreetingService.Client:ClientSave(Player: Player, MessageType: string, message: string)
    self.Server:Set(Player, MessageType, message)
end

-- ————————— 🂡 —————————
-- Return Service to Knit.
return GreetingService
