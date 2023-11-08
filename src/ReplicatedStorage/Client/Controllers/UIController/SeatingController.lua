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
local PlayerService = game:GetService("Players")
local StarterPack = game:GetService("StarterPack")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)
local spr = require(ReplicatedStorage.Modules.spr)

local Trove = require(ReplicatedStorage.Packages.Trove)
local trove = Trove.new()

local Player = PlayerService.LocalPlayer

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Controller
local SeatingController = Knit.CreateController {
    Name = "SeatingController",
}

SeatingController.ActiveTable = false
local UIController

-- ————————— ↢ ⭐️ ↣ —————————-
-- Client Functions
function SeatingController:ElapsedTime()
    local ElapsedTime = 0
    task.delay(0.2, function()
        while self.ActiveTable and task.wait(1) do
            local SecondsFormatted = ElapsedTime % 60
            local MinutesFormatted = math.floor(ElapsedTime / 60)
            local CompareFormatted = 10 > SecondsFormatted and "0" .. SecondsFormatted
            ElapsedTime += 1

            self.TableTicket.Time.Text = string.format("%s:%s Elapsed", MinutesFormatted, (CompareFormatted or SecondsFormatted))
        end
    end)
end

function SeatingController:KnitStart()
    UIController = Knit.GetController("UIController")
    self.TableTicket = UIController.Pages.Parent:WaitForChild("TableTicket").Frame
    self:SeatCustomer(10)
end

function SeatingController:SeatCustomer(TableNumber: number)
    local State, PlayerAvatar = pcall(PlayerService:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420))
    local NoAvatar = PlayerService:GetUserThumbnailAsync(1, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

    self.TableTicket.Description.Text = "Thank you for choosing to dine with Gochi! If you require any assistance, let your server know!"
    self.TableTicket.PlayerAvatar.Image = State and PlayerAvatar or NoAvatar
    self.TableTicket.Table.Text = "Table #" .. TableNumber
    self.ActiveTable = true

    spr.target(self.TableTicket.Parent, 0.85, 1, { GroupTransparency = 0, Position = UDim2.fromScale(0.88, 0.9)})
    self:ElapsedTime()

    trove:Add(self.TableTicket.DoneButton.MouseButton1Click:Connect(function()
        spr.target(self.TableTicket.Parent, 0.85, 1, { GroupTransparency = 1, Position = UDim2.fromScale(0.88, 0.91)})
        self.ActiveTable = false
    end))
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Controller to Knit.
return SeatingController