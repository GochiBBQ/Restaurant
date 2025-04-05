--[[
	Initializes and starts the Knit framework for the server-side of the game.
	Loads necessary modules and services, sets up data and static references, and defines custom signals.
	Once the Knit framework is successfully started, it logs a welcome message and highlights potential errors and warnings.

	@function KnitRuntime
	@within Server
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Server = game:GetService("ServerScriptService")
local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)
local Signal = require(Packages.Signal)

Knit.Modules = Server.Modules
Knit.Classes = Server.Classes
Knit.Structures = Server.Structures
Knit.Data = ReplicatedStorage.Data

Knit.Profiles = {}

Knit.Data = ReplicatedStorage:WaitForChild("Data")
Knit.Static = ReplicatedStorage:WaitForChild("Static")
Knit.Signals = {
	PlayerLoaded = Signal.new()
}

Knit.AddServicesDeep(Server:WaitForChild("Services"))

Knit.Start():andThen(function()
	warn("🥩 Welcome back to Gochi. The server services for Knit have successfully loaded.")
	warn("❗Errors will be highlighted in red and warnings in yellow. This will help determine issues on the server side.")
end)