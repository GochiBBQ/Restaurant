local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = require(ReplicatedStorage.Packages.Cmdr)

Cmdr:RegisterHooksIn(script.Parent.Moderation.Cmdr.Hooks)
Cmdr:RegisterCommandsIn(script.Parent.Moderation.Cmdr.Commands)
Cmdr:RegisterDefaultCommands()