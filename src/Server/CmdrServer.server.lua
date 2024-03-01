local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = require(ReplicatedStorage.Packages.Cmdr)

Cmdr:RegisterDefaultCommands()
Cmdr:RegisterHooksIn(script.Parent.Moderation.Hooks)