--[[
    Initializes the Cmdr command framework and registers default commands and hooks.
    Retrieves the Cmdr module from ReplicatedStorage, registers the default commands provided by Cmdr,
    and registers hooks located in the Moderation.Hooks directory.

    @function InitCmdr
    @within CmdrServer
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = require(ReplicatedStorage.Packages.Cmdr)

Cmdr:RegisterDefaultCommands()
Cmdr:RegisterHooksIn(script.Parent.Moderation.Hooks)