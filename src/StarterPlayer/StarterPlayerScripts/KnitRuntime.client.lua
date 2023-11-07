if game:GetService("RunService"):IsStudio() then task.wait(2) end -- stoooodio

local Player = game:GetService("Players").LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Client = ReplicatedStorage:WaitForChild("Client")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Knit = require(Packages:WaitForChild("Knit"))

Knit.Modules = Client:WaitForChild("Modules")
Knit.Data = ReplicatedStorage:WaitForChild("Data")
Knit.Static = ReplicatedStorage:WaitForChild("Static")

Knit.AddControllersDeep(Client:WaitForChild("Controllers"))

Knit.Start():andThen(function()
	warn("🥩 Hey there, " .. Player.DisplayName .. "! Welcome to Gochí. Knit has successfully loaded its controllers.")
	warn("❗Errors will be highlighted in red and warnings in yellow. Report anything listed in either red or yellow.")
end):catch(warn)
	
