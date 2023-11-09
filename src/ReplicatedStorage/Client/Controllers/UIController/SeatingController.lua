--[[

█▀▀▄ █▀▀█ █▀▀▄ █▀▀█ █░░█ █▀▀▄ ▀▀█▀▀ ▀▀█ █▀▀█ █▀▀ █░█ 
█░░█ █░░█ █░░█ █░░█ █░░█ █▀▀▄ ░░█░░ ▄▀░ █▄▄█ █░░ █▀▄ 
▀░░▀ ▀▀▀▀ ▀▀▀░ ▀▀▀▀ ░▀▀▀ ▀▀▀░ ░░▀░░ ▀▀▀ ▀░░▀ ▀▀▀ ▀░▀

Author: nodoubtzack
For: Gochí Restaurant 🥩
https://www.roblox.com/groups/5874921/Goch#!/about

]]

-- ————————— ↢ ⭐️ ↣ —————————
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local PlayerService = game:GetService("Players")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)
local spr = require(ReplicatedStorage.Modules.spr)

local Trove = require(ReplicatedStorage.Packages.Trove)
local trove = Trove.new()

local Player = PlayerService.LocalPlayer
local UISelect = SoundService.UISelect
local UIHover = SoundService.UIHover

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Controller
local SeatingController = Knit.CreateController {
    Name = "SeatingController",
}

SeatingController.ActiveTable = false
SeatingController.Timer = 1500
local UIController

-- ————————— ↢ ⭐️ ↣ —————————-
-- Client Functions
function SeatingController:ElapsedTime()
    local ElapsedTime = 0
    task.spawn(function()
        while self.ActiveTable and task.wait(1) do
            local SecondsFormatted = ElapsedTime % 60
            local MinutesFormatted = math.floor(ElapsedTime / 60)
            local CompareFormatted = 10 > SecondsFormatted and "0" .. SecondsFormatted
            ElapsedTime += 1

            self.TableTicket.Time.Text = string.format("%s:%s Elapsed", MinutesFormatted, (CompareFormatted or SecondsFormatted))
        end
    end)
end

function SeatingController:DiningTimer()
    local PlayerTimed = Player:GetAttribute("DiningTimer")
        
    if PlayerTimed then
        local FormattedMinutes, FormattedSeconds = math.floor(PlayerTimed / 60), PlayerTimed % 60
        local FormattedCompare = 10 > FormattedSeconds and "0" .. FormattedSeconds
         return FormattedMinutes, (FormattedCompare or FormattedSeconds)
    end
end


function SeatingController:CloseButton(Button: GuiButton)
    Button.MouseEnter:Connect(function()
        spr.target(Button, 0.75, 4, { Size = UDim2.fromScale(0.25, 0.25)})
        UIHover:Play()
    end)

    Button.MouseLeave:Connect(function()
        spr.target(Button, 0.75, 4, { Size = UDim2.fromScale(0.236, 0.217)})
    end)

    trove:Add(self.TableTicket.DoneButton.MouseButton1Click:Connect(function()
        spr.target(self.TableTicket.Parent, 0.85, 1, { GroupTransparency = 1, Position = UDim2.fromScale(0.88, 0.91)})
        self.ActiveTable = false
        UISelect:Play()
    end))
end

function SeatingController:KnitStart()
    UIController = Knit.GetController("UIController")
    self.TableTicket = UIController.Pages.Parent:WaitForChild("TableTicket").Frame

    task.wait(3)
    self:SeatCustomer(10)
end

function SeatingController:SeatCustomer(TableNumber: number)
    self.TableTicket.PlayerAvatar.Image = PlayerService:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    self.TableTicket.Description.Text = "Thank you for choosing to dine with Gochi! If you require any assistance, let your server know!"
    self.TableTicket.Table.Text = "Table #" .. TableNumber
    self.ActiveTable = true

    spr.target(self.TableTicket.Parent, 0.85, 1, { GroupTransparency = 0, Position = UDim2.fromScale(0.88, 0.9)})
    self:CloseButton(self.TableTicket.DoneButton)
    self:ElapsedTime()
end

function SeatingController:TimeEnding()
    while task.wait(1) do
        spr.target(self.TableTicket.Description, 1, 3, { TextTransparency = 1})
        task.wait(0.25)
        self.TableTicket.Description.Text = string.format("Your time with us is unfortunately coming to an end. You have %:%s more minutes left in your party.", self:DiningTimer())
        spr.target(self.TableTicket.Description, 1, 3, { TextTransparency = 0})
    end
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Controller to Knit.
return SeatingController