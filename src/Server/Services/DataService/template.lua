--[[
    Template for storing player data in the game.
    This table contains various fields to track player progress, settings, inventory, and quests.

    @table template
    @field XP number The player's experience points.
    @field Level number The player's level.
    @field TipsReceived number The number of tips received by the player.
    @field TipsGiven number The number of tips given by the player.

    @field Greetings table A table containing various greeting messages used in the game.
    @field Greetings.welcomeMessage string The welcome message for the player.
    @field Greetings.areaMessage string The message asking the player for their preferred dining area.
    @field Greetings.seatingMessage string The message asking the player for their preferred seating.
    @field Greetings.seatingConfirmationMessage string The message confirming the seating arrangement.
    @field Greetings.beveragesMessage string The message offering beverages to the player.
    @field Greetings.appetizersMessage string The message offering appetizers to the player.
    @field Greetings.entreesMessage string The message offering entrees to the player.
    @field Greetings.dessertsMessage string The message offering desserts to the player.
    @field Greetings.conclusionMessage string The message thanking the player for dining.

    @field Settings table A table for storing player settings.

    @field Gamepasses table A table for storing game pass information.

    @field Notepad string A notepad for the player to store notes.

    @field Quests table A table for tracking player quests.
    @field Quests.Completed table A list of completed quests.
    @field Quests.InProgress table A list of quests in progress.
    @field Quests.Available table A list of available quests.
    
    @field Inventory table A table for storing player inventory.
    @field Inventory.Currency number The amount of currency the player has.
    @field Inventory.Nametags table A list of nametags the player owns.
    @field Inventory.Trails table A list of trails the player owns.
    @field Inventory.Particles table A list of particles the player owns.
    @field Inventory.Tricks table A list of tricks the player owns.
    @field Inventory.EquippedItems table A table for storing equipped items.
    @field Inventory.EquippedItems.Nametag string The currently equipped nametag.
    @field Inventory.EquippedItems.Trail string The currently equipped trail.
    @field Inventory.EquippedItems.Particle string The currently equipped particle.
    @field Inventory.EquippedItems.Trick string The currently equipped trick.
]]
local template = {
    XP = 0,
    Level = 0,

    TipsReceived = 0,
    TipsGiven = 0,

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

    },

    Gamepasses= {

    },

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

        EquippedItems = {
            Nametag = nil,
            Trail = nil,
            Particle = nil,
            Trick = nil,
        },
    },
    
}

return template