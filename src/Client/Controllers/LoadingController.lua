--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')
local StarterGui: StarterGui = game:GetService("StarterGui")
local Lighting: Lighting = game:GetService("Lighting")
local Players: Players = game:GetService("Players")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)
local Signal: ModuleScript = require(ReplicatedStorage.Packages.Signal)
local AnimNation: ModuleScript = require(Knit.Modules.AnimNation) --- @module AnimNation
local Trove: ModuleScript = require(ReplicatedStorage.Packages.Trove) --- @module Trove

-- Variables
local Player: Player = Players.LocalPlayer

local Skipped: boolean = false

local NotificationService, TeamService, RankService, DataService
local TeamController, UIController

-- GUI assets
local PlayerGui: PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI: GuiObject = PlayerGui:WaitForChild("GochiUI")
local TeamUI: GuiObject = GochiUI:WaitForChild("Teams")

local LoadingUI: GuiObject = PlayerGui:WaitForChild("LoadingScreen"):WaitForChild("LoadingScreen")
local Content: GuiObject = LoadingUI:WaitForChild("Content")
local ProgressHolder: GuiObject = Content:WaitForChild("Progress")
local ProgressBar: GuiObject = ProgressHolder:WaitForChild("Filler")
local Skip: GuiObject = Content:WaitForChild("Skip")
local LoadedText: GuiObject = Content:WaitForChild("Loaded")
local Percentage: GuiObject = Content:WaitForChild("Percentage")

-- Create Knit Controller
local LoadingController = Knit.CreateController {
    Name = "LoadingController",
    ShowTeams = Signal.new(),
}

local trove = Trove.new() -- Create a Trove instance

-- Client Functions
function LoadingController:KnitStart()
    UIController = Knit.GetController("UIController")
    TeamController = Knit.GetController("TeamController")
    TeamService = Knit.GetService("TeamService")
    RankService = Knit.GetService("RankService")
    DataService = Knit.GetService("DataService")
    
    local Blur = Instance.new("BlurEffect")
    trove:Add(Blur)
    AnimNation.target(Blur, {s = 3, d = 0.8}, { Size = 16 })
    Blur.Parent = Lighting

    local Character = Player.Character or Player.CharacterAdded:Wait()
    trove:Add(Character)
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

    local skipConnection = Skip.MouseButton1Click:Connect(function()
        Skipped = true
    end)
    trove:Add(skipConnection)

    task.delay(12, function()
        Skip.Visible = true
        Skip.Label.Visible = true
    end)

    local startTime = tick()
    local loadDuration = math.random(30, 40)
    
    while tick() - startTime < loadDuration do
        local elapsed = tick() - startTime
        local progress = elapsed / loadDuration
        Percentage.Text = string.format("%d%% Complete", math.floor(progress * 100))
        local dotCount = math.floor(elapsed % 3) + 1
        local dots = string.rep(".", dotCount)
        LoadedText.Text = "Your game is loading" .. dots
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

    local teamSelectedConnection = TeamController.TeamSelected:Connect(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
        UIController:Close(TeamUI)
        
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
    trove:Add(teamSelectedConnection)

    DataService:GetJoined():andThen(function(joinedBefore)
        if not joinedBefore then
            UIController:Open(GochiUI.GettingStarted)

            local closeConnection = GochiUI.GettingStarted.Close.MouseButton1Click:Connect(function()
                UIController:Close(GochiUI.GettingStarted)
            end)
            trove:Add(closeConnection)
        end
    end)
end

-- Return Controller to Knit.
return LoadingController
