--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService: RunService = game:GetService('RunService')
local UserInputService: UserInputService = game:GetService('UserInputService')
local SoundService: SoundService = game:GetService("SoundService")
local StarterGui: StarterGui = game:GetService('StarterGui')
local Players: Players = game:GetService('Players')

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)
local Signal: ModuleScript = require(ReplicatedStorage.Packages.Signal)
local AnimNation: ModuleScript = require(Knit.Modules.AnimNation) --- @module AnimNation
local Trove: ModuleScript = require(ReplicatedStorage.Packages.Trove) --- @module Trove

-- Variables
local LocalPlayer: Player = Players.LocalPlayer
local UIController, LoadingController
local RankService, TeamService, NotificationService

local onCooldown: boolean = false
local toggled: boolean = true

local UISelect: Sound = SoundService.UISelect
local UIHover: SoundGroup = SoundService.UIHover

-- GUI Variables
local PlayerGui: PlayerGui = LocalPlayer:WaitForChild('PlayerGui')
local GochiUI: GuiObject = PlayerGui:WaitForChild('GochiUI')
local TeamUI: GuiObject = GochiUI:WaitForChild('Teams')

local LeaderboardUI: GuiObject = PlayerGui:WaitForChild('Leaderboard').Main
local Scroll: GuiObject = LeaderboardUI:WaitForChild('Scroll')
local Template: GuiObject = LeaderboardUI:WaitForChild('Template')

local ShownPlayers: table = {}
local AllowedTeams: table = {}

-- Knit Controller
local TeamController = Knit.CreateController {
    Name = "TeamController",
    TeamSelected = Signal.new(),
}

-- Trove instance for cleanup
local trove = Trove.new()

-- Knit Start
function TeamController:KnitStart()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

    RankService = Knit.GetService('RankService')
    TeamService = Knit.GetService('TeamService')
    NotificationService = Knit.GetService('NotificationService')
    UIController = Knit.GetController('UIController')
    LoadingController = Knit.GetController('LoadingController')

    trove:Connect(TeamService.AssignTeam, function(player, team, rank, role)
        self:HandleLeaderboard(player, team, rank, role)
    end)

    trove:Connect(UserInputService.InputBegan, function(input, gameProcessed)
        self:ToggleLeaderboard(input, gameProcessed)
    end)

    self:Check()
    self:InitializePlayers()

    trove:Connect(Players.PlayerAdded, function(player)
        self:InitializePlayer(player)
    end)

    trove:Connect(Players.PlayerRemoving, function(player)
        self:RemovePlayer(player)
    end)

    if UserInputService.TouchEnabled or UserInputService.VREnabled then
        LeaderboardUI.Visible = false
    end
end

function TeamController:InitializePlayers()
    for _, player in pairs(Players:GetPlayers()) do
        self:InitializePlayer(player)
    end
end

function TeamController:InitializePlayer(player)
    local team = player:GetAttribute('Team')
    local rank = player:GetAttribute('Rank')
    local role = player:GetAttribute('Role')

    if team and rank and role then
        self:HandleLeaderboard(player, team, rank, role)
    else
        trove:Connect(player:GetAttributeChangedSignal('Team'), function()
            self:UpdatePlayerAttributes(player)
        end)
        trove:Connect(player:GetAttributeChangedSignal('Rank'), function()
            self:UpdatePlayerAttributes(player)
        end)
        trove:Connect(player:GetAttributeChangedSignal('Role'), function()
            self:UpdatePlayerAttributes(player)
        end)
    end
end

function TeamController:UpdatePlayerAttributes(player)
    local team = player:GetAttribute('Team')
    local rank = player:GetAttribute('Rank')
    local role = player:GetAttribute('Role')

    if team and rank and role then
        self:HandleLeaderboard(player, team, rank, role)

        if player == LocalPlayer then
            GochiUI.ChefQueue.Visible = false
            GochiUI.CreateOrder.Visible = false

            if team == 'Management' then
                GochiUI.ChefQueue.Visible = true
            elseif team == 'Server' then
                GochiUI.CreateOrder.Visible = true
            elseif team == 'Chef' then
                GochiUI.ChefQueue.Visible = true
            elseif RunService:IsStudio() then
                GochiUI.ChefQueue.Visible = true
                -- GochiUI.CreateOrder.Visible = true
            end
        end
    end
end

function TeamController:RemovePlayer(player)
    if ShownPlayers[player] then
        ShownPlayers[player]:Destroy()
        ShownPlayers[player] = nil
    end
end

function TeamController:Check()
    table.insert(AllowedTeams, 'Customer')
    TeamUI.List['Customer'].Interactable = true
    TeamUI.List['Chef'].Select.Label.Text = 'Locked'
    TeamUI.List['Server'].Select.Label.Text = 'Locked'
    TeamUI.List['Management'].Select.Label.Text = 'Locked'

    RankService:Get():andThen(function(Rank: number, Role: string)
        if Rank >= 4 or RunService:IsStudio() then
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

        if Rank >= 7 or RunService:IsStudio() then
            table.insert(AllowedTeams, 'Management')

            TeamUI.List['Management'].Interactable = true
            TeamUI.List['Management'].Select.Label.Text = 'Select'
        end
    end)

    for _, frame in pairs(TeamUI.List:GetChildren()) do
        if frame:IsA("Frame") then
            local originalSize = frame['Select'].Size

            trove:Connect(frame['Select'].MouseButton1Click, function()
                UISelect:Play()
                if table.find(AllowedTeams, frame.Name) then
                    self:ButtonSelected(frame.Name)
                end
            end)

            trove:Connect(frame['Select'].MouseEnter, function()
                AnimNation.target(frame.Select, {s = 10, d = 1}, {
                    Size = UDim2.new(originalSize.X.Scale + 0.025, originalSize.X.Offset,
                                     originalSize.Y.Scale + 0.015, originalSize.Y.Offset)
                })
                UIHover:Play()
            end)

            trove:Connect(frame['Select'].MouseLeave, function()
                AnimNation.target(frame.Select, {s = 10, d = 1}, {Size = originalSize})
            end)
        end
    end
end

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

function TeamController:ButtonSelected(Team: string)
    if table.find(AllowedTeams, Team) then
        TeamService:TeamSelected(Team):andThen(function(success, errorMessage)
            if success ~= nil and not success then
                if errorMessage then
                    NotificationService:CreateNotif(LocalPlayer, errorMessage)
                else
                    NotificationService:CreateNotif(LocalPlayer, "An error occurred while selecting the team.")
                end
                return
            end

            self.TeamSelected:Fire(Team)

                for _, frame in pairs(TeamUI.List:GetChildren()) do
                    if frame:IsA("Frame") then
                        frame.Background.Image = 'rbxassetid://90244196390560'
                        frame.Select.Image = 'rbxassetid://134624810349389'
                        frame.Select.Label.Text = (table.find(AllowedTeams, frame.Name) and 'Select' or 'Locked')
                        frame.Select.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                end
        
                local selectedFrame = TeamUI.List[Team]
                if selectedFrame then
                    selectedFrame.Background.Image = 'rbxassetid://92560465279538'
                    selectedFrame.Select.Label.Text = 'Selected'
                    selectedFrame.Select.Label.TextColor3 = Color3.fromRGB(30, 30, 30)
                    selectedFrame.Select.Image = 'rbxassetid://134713465405556'
                end
        end)
    end
end

function TeamController:ToggleLeaderboard(input: InputObject, gameProcessed: boolean)
    if input.KeyCode == Enum.KeyCode.Tab and not gameProcessed then
        if toggled and not onCooldown then
            toggled, onCooldown = false, true
            local position = LeaderboardUI.Position
            AnimNation.target(LeaderboardUI, {s = 10, d = 0.5}, {
                Position = UDim2.new(position.X.Scale + 0.22, position.X.Offset, position.Y.Scale, position.Y.Offset)
            }):AndThen(function()
                LeaderboardUI.Visible = false
                onCooldown = false
            end)
        elseif not toggled and not onCooldown then
            toggled, onCooldown = true, true
            local position = LeaderboardUI.Position
            LeaderboardUI.Visible = true
            AnimNation.target(LeaderboardUI, {s = 10, d = 0.7}, {
                Position = UDim2.new(position.X.Scale - 0.22, position.X.Offset, position.Y.Scale, position.Y.Offset)
            }):AndThen(function()
                onCooldown = false
            end)
        end
    end
end

-- Return Controller to Knit
return TeamController
