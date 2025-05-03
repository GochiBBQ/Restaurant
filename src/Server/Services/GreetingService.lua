--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local TextChatService: TextChatService = game:GetService("TextChatService")
local TextService: TextService = game:GetService("TextService")
local Players: Players = game:GetService('Players')
local Chat: Chat = game:GetService("Chat")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)
local Signal: ModuleScript = require(ReplicatedStorage.Packages.Signal)

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

-- Variables
local defaultMessages: table = {
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

-- Server Functions
function GreetingService:KnitStart() 
    DataService = Knit.GetService("DataService")

    Players.PlayerAdded:Connect(function(Player)
        repeat task.wait() until Player:GetAttribute("Loaded")

        if Knit.Profiles[Player] then
            self.Client.Update:Fire(Player, Knit.Profiles[Player].Data.Greetings)
        end
    end)
end

function GreetingService:Set(Player: Player, MessageType: string, message: string)
    local Profile = Knit.Profiles[Player]
    if not Profile then
        return
    end

    local isValidType = Profile.Data.Greetings[MessageType]
    if isValidType then
        Profile.Data.Greetings[MessageType] = message ~= "" and message or defaultMessages[MessageType]
    end    
end

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
function GreetingService.Client:ClientSend(Player: Player, message: string)
    self.Server:Send(Player, message)
end

function GreetingService.Client:ClientSave(Player: Player, MessageType: string, message: string)
    self.Server:Set(Player, MessageType, message)
end

-- Return Service to Knit.
return GreetingService
