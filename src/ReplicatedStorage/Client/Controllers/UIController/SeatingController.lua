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
function SeatingController:EclapsedTime()
    local ElapsedTime = 0
    coroutine.wrap(function()
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
    self.TableTicket.PlayerAvatar.Image = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%s&width=420&height=420&format=png", Player.UserId)
    self.TableTicket.Description.Text = "Thank you for choosing to dine with Gochi! If you require any assistance, let your server know!"
    self.TableTicket.Table.Text = "Table #" .. TableNumber

    spr.target(self.TableTicket.Parent, 0.75, 2, { GroupTransparency = 0, Position = UDim2.fromScale(0.88, 0.9)})
    self:EclapsedTime()

    trove:Add(self.TableTicket.DoneButton.MouseButton1Click:Connect(function()
        spr.target(self.TableTicket.Parent, 0.75, 2, { GroupTransparency = 1, Position = UDim2.fromScale(0.88, 1.2)})
    end))
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Controller to Knit.
return SeatingController