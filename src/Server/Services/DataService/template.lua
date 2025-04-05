--[[
    Template for storing player data in the game.
    This table contains various fields to track player progress, settings, inventory, and quests.
]]
    
local template = {
    Points = 0,

    TipsReceived = 0,
    TipsGiven = 0,

    JoinedBefore = false,

    Greetings = {
		welcomeMessage = "Greetings, welcome to Gochí! I'll be assisting you today. How many people are in your party?",
		areaMessage = "Would you prefer to be arranged indoors, outdoors, or in our underwater dining?",
		seatingMessage = "Where would you liked to be seated? We offer tables and booths.",
		seatingConfirmationMessage = "Is this arrangement alright? If not, I would be happy to relocate you elsewhere.",
		beveragesMessage = "To start off, can I interest you in any of our beverages?",
		appetizersMessage = "Moving on, may I interest you in any of our appetizers?",
		entreesMessage = "Next up, can I interest you in any of our entrees?",
		dessertsMessage = "Finally, may I interest you in any of our desserts?",
		conclusionMessage = "Thanks for dining at Gochí! Please note that tips are available if you so choose, and we hope to see you again!",
    },

    Settings = {
        Settings = {
            LowGraphicsMode = false,
            MuteMusic = false,
            ShowTips = true,
            DisableEffects = false,
        },
        Gamepasses = {
            Headless = false,
            Korblox = false,
            Walkspeed = false,
            DisableUniform = false,
        }
    },

    Gamepasses = {},

    Notepad = "",

    Quests = {
        Completed = {},
        InProgress = {},
        Available = {},
    },

    Inventory = {
        Currency = 0,

        Nametags = {},
        Trails = {},
        Particles = {},
        Tricks = {},

        Equipped = {
            Nametags = nil,
            Trails = nil,
            Particles = nil,
            Tricks = nil,
        },
    },
    
}

return template