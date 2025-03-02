--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService = game:GetService('UserInputService')
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService('StarterGui')
local Players = game:GetService('Players')

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local AnimNation = require(Knit.Modules.AnimNation) --- @module AnimNation
local spr = require(Knit.Modules.spr)

-- Variables
local LocalPlayer = Players.LocalPlayer
local UIController, LoadingController
local RankService, TeamService

local onCooldown = false
local toggled = true

local UISelect = SoundService.UISelect
local UIHover = SoundService.UIHover

-- GUI Variables
local PlayerGui = LocalPlayer:WaitForChild('PlayerGui')
local GochiUI = PlayerGui:WaitForChild('GochiUI')
local TeamUI = GochiUI:WaitForChild('Teams')

local LeaderboardUI = PlayerGui:WaitForChild('Leaderboard').Main
local Scroll = LeaderboardUI:WaitForChild('Scroll')
local Template = LeaderboardUI:WaitForChild('Template')

local ShownPlayers = {}
local AllowedTeams = {}

-- Knit Controller
local TeamController = Knit.CreateController {
    Name = "TeamController",
    TeamSelected = Signal.new(),
}

-- Knit Start
function TeamController:KnitStart()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

    RankService = Knit.GetService('RankService')
    TeamService = Knit.GetService('TeamService')
    UIController = Knit.GetController('UIController')
    LoadingController = Knit.GetController('LoadingController')

    TeamService.AssignTeam:Connect(function(player, team, rank, role)
        self:HandleLeaderboard(player, team, rank, role)
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        self:ToggleLeaderboard(input, gameProcessed)
    end)

    self:Check()
    self:InitializePlayers()

    Players.PlayerAdded:Connect(function(player)
        self:InitializePlayer(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:RemovePlayer(player)
    end)
end

-- Initialize all players in the game
function TeamController:InitializePlayers()
    for _, player in pairs(Players:GetPlayers()) do
        self:InitializePlayer(player)
    end
end

-- Initialize a single player
function TeamController:InitializePlayer(player)
    local team = player:GetAttribute('Team')
    local rank = player:GetAttribute('Rank')
    local role = player:GetAttribute('Role')

    if team and rank and role then
        self:HandleLeaderboard(player, team, rank, role)
    else
        -- Listen for attribute changes if the attributes are not ready yet
        player:GetAttributeChangedSignal('Team'):Connect(function()
            self:UpdatePlayerAttributes(player)
        end)
        player:GetAttributeChangedSignal('Rank'):Connect(function()
            self:UpdatePlayerAttributes(player)
        end)
        player:GetAttributeChangedSignal('Role'):Connect(function()
            self:UpdatePlayerAttributes(player)
        end)
    end
end

-- Update player attributes and refresh their leaderboard entry
function TeamController:UpdatePlayerAttributes(player)
    local team = player:GetAttribute('Team')
    local rank = player:GetAttribute('Rank')
    local role = player:GetAttribute('Role')

    if team and rank and role then
        self:HandleLeaderboard(player, team, rank, role)
    end
end

-- Remove a player from the leaderboard
function TeamController:RemovePlayer(player)
    if ShownPlayers[player] then
        ShownPlayers[player]:Destroy()
        ShownPlayers[player] = nil
    end
end

-- Check player's rank and set allowed teams
function TeamController:Check()
    -- Default setup
    table.insert(AllowedTeams, 'Customer')
    TeamUI.List['Customer'].Interactable = true
    TeamUI.List['Chef'].Select.Label.Text = 'Locked'
    TeamUI.List['Server'].Select.Label.Text = 'Locked'
    TeamUI.List['Management'].Select.Label.Text = 'Locked'

    RankService:Get():andThen(function(Rank: number, Role: string)
        if Rank >= 4 then
            table.insert(AllowedTeams, 'Chef')
            table.insert(AllowedTeams, 'Server')

            table.remove(AllowedTeams, table.find(AllowedTeams, 'Customer'))

            TeamUI.List['Chef'].Interactable = true
            TeamUI.List['Chef'].Select.Label.Text = 'Select'
            TeamUI.List['Server'].Interactable = true
            TeamUI.List['Server'].Select.Label.Text = 'Select'
            TeamUI.List['Customer'].Interactable = false
            TeamUI.List['Customer'].Select.Label.Text = 'Locked'
        end

        if Rank >= 7 then
            table.insert(AllowedTeams, 'Management')

            TeamUI.List['Management'].Interactable = true
            TeamUI.List['Management'].Select.Label.Text = 'Select'
        end
    end)

    -- Add button interaction for team selection
    for _, frame in pairs(TeamUI.List:GetChildren()) do
        if frame:IsA("Frame") then
            local originalSize = frame['Select'].Size

            frame['Select'].MouseButton1Click:Connect(function()
                UISelect:Play()
                if table.find(AllowedTeams, frame.Name) then
                    self:ButtonSelected(frame.Name)
                end
            end)

            frame['Select'].MouseEnter:Connect(function()
                -- spr.target(frame.Select, 1, 3, {Size = UDim2.new(originalSize.X.Scale + 0.025, originalSize.X.Offset, originalSize.Y.Scale + 0.015, originalSize.Y.Offset)})
                AnimNation.target(frame.Select, {s = 10, d = 1}, {Size = UDim2.new(originalSize.X.Scale + 0.025, originalSize.X.Offset, originalSize.Y.Scale + 0.015, originalSize.Y.Offset)})
                UIHover:Play()
            end)

            frame['Select'].MouseLeave:Connect(function()
                -- spr.target(frame.Select, 1, 3, {Size = originalSize})
                AnimNation.target(frame.Select, {s = 10, d = 1}, {Size = originalSize})
            end)
        end
    end
end

-- Handle leaderboard
function TeamController:HandleLeaderboard(player: Player, Team: string, Rank: number, Role: string)
    self:RemovePlayer(player)

    local order
    if Team == "Customer" then
        order = 2300 - Rank
    elseif Team == "Server" then
        order = 1800 - Rank
    elseif Team == "Chef" then
        order = 1300 - Rank
    elseif Team == "Management" then
        order = 800 - Rank
    end

    local clone = Template:Clone()
    clone.Name = player.Name
    clone.Role.Text = Role
    clone.User.Text = player.Name
    clone.LayoutOrder = order
    clone.Parent = Scroll
    clone.Visible = true

    ShownPlayers[player] = clone
end

-- Handles the selection of a team button in the UI
function TeamController:ButtonSelected(Team: string)
    -- unselected background: rbxassetid://90244196390560
    -- selected background: rbxassetid://92560465279538

    -- unselected button: rbxassetid://134624810349389
    -- selected button: rbxassetid://134713465405556

    if table.find(AllowedTeams, Team) then
        TeamService:TeamSelected(Team)
        self.TeamSelected:Fire(Team)

        -- Update all team UI buttons to reflect the new selection
        for _, frame in pairs(TeamUI.List:GetChildren()) do
            if frame:IsA("Frame") then
                frame.Background.Image = 'rbxassetid://90244196390560'
                frame.Select.Image = 'rbxassetid://134624810349389'
                frame.Select.Label.Text = (table.find(AllowedTeams, frame.Name) and 'Select' or 'Locked')
                frame.Select.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end

        -- Highlight the selected team
        if TeamUI.List[Team] then
            TeamUI.List[Team].Background.Image = 'rbxassetid://92560465279538'
            TeamUI.List[Team].Select.Label.Text = 'Selected'
            TeamUI.List[Team].Select.Label.TextColor3 = Color3.fromRGB(30, 30, 30)
            TeamUI.List[Team].Select.Image = 'rbxassetid://134713465405556'
        end
    end
end

-- Toggle leaderboard visibility
function TeamController:ToggleLeaderboard(input: InputObject, gameProcessed: boolean)
    if input.KeyCode == Enum.KeyCode.Tab and not gameProcessed then
        if toggled and not onCooldown then
            toggled, onCooldown = false, true
            local position = LeaderboardUI.Position
            -- spr.target(LeaderboardUI, 1, 3, {Position = UDim2.new(position.X.Scale + 0.22, position.X.Offset, position.Y.Scale, position.Y.Offset)})
            AnimNation.target(LeaderboardUI, {s = 10, d = 0.5}, {Position = UDim2.new(position.X.Scale + 0.22, position.X.Offset, position.Y.Scale, position.Y.Offset)}):AndThen(function()
                LeaderboardUI.Visible = false
                onCooldown = false 
            end)
        elseif not toggled and not onCooldown then
            toggled, onCooldown = true, true
            local position = LeaderboardUI.Position
            LeaderboardUI.Visible = true
            -- spr.target(LeaderboardUI, 1, 3, {Position = UDim2.new(position.X.Scale - 0.22, position.X.Offset, position.Y.Scale, position.Y.Offset)})
            AnimNation.target(LeaderboardUI, {s = 10, d = 0.7}, {Position = UDim2.new(position.X.Scale - 0.22, position.X.Offset, position.Y.Scale, position.Y.Offset)}):AndThen(function()
                onCooldown = false
            end)
        end
    end
end

return TeamController

