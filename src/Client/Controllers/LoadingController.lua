--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService('RunService')
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local AnimNation = require(Knit.Modules.AnimNation) --- @module AnimNation
local spr = require(Knit.Modules.spr)

-- Variables
local Player = Players.LocalPlayer

local Skipped = false

local NotificationService, TeamService, RankService, DataService
local TeamController, UIController

-- GUI assets
local PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI = PlayerGui:WaitForChild("GochiUI")
local TeamUI = GochiUI:WaitForChild("Teams")

local LoadingUI = PlayerGui:WaitForChild("LoadingScreen"):WaitForChild("LoadingScreen")
local Content = LoadingUI:WaitForChild("Content")
local ProgressHolder = Content:WaitForChild("Progress")
local ProgressBar = ProgressHolder:WaitForChild("Filler")
local Skip = Content:WaitForChild("Skip")
local LoadedText = Content:WaitForChild("Loaded")
local Percentage = Content:WaitForChild("Percentage")


-- Create Knit Controller
local LoadingController = Knit.CreateController {
    Name = "LoadingController",
    ShowTeams = Signal.new(),
}

-- Client Functions
--[[
    Initializes the loading process for the game, displaying a loading screen with progress updates.
    Disables certain UI elements and player controls during the loading phase.
    Allows the player to skip the loading process after a delay.
    Once loading is complete or skipped, re-enables UI elements and player controls.
    Opens the team selection UI and waits for the player to select a team.
    Re-enables chat and other UI elements once a team is selected.

    @function KnitStart
    @within LoadingController
]]
function LoadingController:KnitStart()
    UIController = Knit.GetController("UIController")
    TeamController = Knit.GetController("TeamController")
    TeamService = Knit.GetService("TeamService")
    RankService = Knit.GetService("RankService")
    DataService = Knit.GetService("DataService")
    
    local Blur = Instance.new("BlurEffect")
    -- spr.target(Blur, 0.8, 1, { Size = 16 })
    AnimNation.target(Blur, {s = 3, d = 0.8}, { Size = 16 })
    Blur.Parent = Lighting

    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")

    Humanoid.WalkSpeed = 0
    Humanoid.JumpPower = 0
    Humanoid.AutoRotate = false

    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)

    PlayerGui:WaitForChild("Leaderboard").Enabled = false
    PlayerGui:WaitForChild("Backpack").Enabled = false
    GochiUI.Enabled = false
    PlayerGui:WaitForChild("TopbarStandard").Enabled = false
    PlayerGui:WaitForChild("Essentials Client").Enabled = false
    LoadingUI.Parent.Enabled = true

    task.delay(12, function()
        Skip.Visible = true
        Skip.Label.Visible = true
    end)

    Skip.MouseButton1Click:Connect(function()
        Skipped = true
    end)

    local startTime = tick()
    local loadDuration = math.random(30, 40)
    
    while tick() - startTime < loadDuration do
        local elapsed = tick() - startTime
        local progress = elapsed / loadDuration
        Percentage.Text = string.format("%d%% Complete", math.floor(progress * 100))
        LoadedText.Text = "Your game is loading..."
        local dotCount = math.floor(elapsed % 3) + 1
        local dots = string.rep(".", dotCount)
        LoadedText.Text = "Your game is loading" .. dots
        -- spr.target(ProgressBar, 1, 1, { Size = UDim2.new(progress, 0, 1, 0) })
        AnimNation.target(ProgressBar, {s = 3, d = 1}, { Size = UDim2.new(progress, 0, 1, 0) })

        if Skipped then
            break
        end

        task.wait(0.1)
    end

    Skipped = true

    Skip.Visible = false
    Skip.Label.Visible = false

    LoadingUI.Parent.Enabled = false

    UIController:HideHUD()
    GochiUI.Profiler.Visible = false
    GochiUI.Enabled = true

    UIController:Open(TeamUI, false)

    TeamController.TeamSelected:Connect(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
        UIController:Close(TeamUI)
        
        -- spr.target(Blur, 0.8, 1, { Size = 0 })
        AnimNation.target(Blur, {s = 3, d = 0.8}, { Size = 0 })
        UIController:ShowHUD()
        GochiUI.Profiler.Visible = true
        PlayerGui:WaitForChild("Leaderboard").Enabled = true
        PlayerGui:WaitForChild("Backpack").Enabled = true
        PlayerGui:WaitForChild("TopbarStandard").Enabled = true
        PlayerGui:WaitForChild("Essentials Client").Enabled = true

        local Character = Player.Character or Player.CharacterAdded:Wait()
        local Humanoid = Character:WaitForChild("Humanoid")

        Humanoid.WalkSpeed = (Player:GetAttribute("Walkspeed") and 32) or 16
        Humanoid.JumpPower = 50
        Humanoid.AutoRotate = true
    end)

    DataService:GetJoined():andThen(function(joinedBefore)
        if not joinedBefore then
            UIController:Open(GochiUI.GettingStarted)

            GochiUI.GettingStarted.Close.MouseButton1Click:Connect(function()
                UIController:Close(GochiUI.GettingStarted)
            end)
        end
    end)
end

 -- Return Controller to Knit.
return LoadingController
