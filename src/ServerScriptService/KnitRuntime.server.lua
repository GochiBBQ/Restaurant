local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Server = script.Parent:WaitForChild("Server")
local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)
local Signal = require(Knit.Util.Signal)

Knit.Modules = Server.Modules
Knit.Components = Server.Components

Knit.Data = ReplicatedStorage:WaitForChild("Data")
Knit.Static = ReplicatedStorage:WaitForChild("Static")
Knit.Signals = {
	PlayerLoaded = Signal.new()
}

Knit.AddServicesDeep(Server:WaitForChild("Services"))

Knit.Start():andThen(function()
	warn("🥩 Welcome back to Gochí. The server services for Knit have successfully loaded.")
	warn("❗Errors will be highlighted in red and warnings in yellow. This will help determine issues on the server side.")
end)