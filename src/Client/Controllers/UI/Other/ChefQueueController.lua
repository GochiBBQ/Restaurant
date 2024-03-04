--[[

█▀▀▄ █▀▀█ █▀▀▄ █▀▀█ █░░█ █▀▀▄ ▀▀█▀▀ ▀▀█ █▀▀█ █▀▀ █░█ 
█░░█ █░░█ █░░█ █░░█ █░░█ █▀▀▄ ░░█░░ ▄▀░ █▄▄█ █░░ █▀▄ 
▀░░▀ ▀▀▀▀ ▀▀▀░ ▀▀▀▀ ░▀▀▀ ▀▀▀░ ░░▀░░ ▀▀▀ ▀░░▀ ▀▀▀ ▀░▀

Author: nodoubtzack
For: Gochí Restaurant 🥩
https://www.roblox.com/groups/5874921/Goch#!/about

]]

-- »»————————————　★　————————————-««
-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local PlayerService = game:GetService('Players')

-- »»————————————　★　————————————-««
-- Modules
local Trove = require(ReplicatedStorage.Packages.Trove)
local Knit = require(ReplicatedStorage.Packages.Knit)
local spr = require(Knit.Modules.spr)

-- »»————————————　★　————————————-««
-- Variables
local KitchenService = nil
local UIController = nil
local RankService = nil

local LocalPlayer = PlayerService.LocalPlayer

-- »»————————————　★　————————————-««
-- Create Knit Controller
local ChefQueueController = Knit.CreateController {
    Name = "ChefQueueController",
    Queued = false,
}

-- »»————————————　★　————————————-««
-- Player Queue Position Functions

--[[
    Initalizes a timer that periodically updates how long the person has been in queue
    @param PLayer: Player
    @param Label: TextLabel
    @returns nil
]]
function ChefQueueController:ElapsedTime(Player: Player, Label: TextLabel)
    task.spawn(function()
        local PlayerElapsed: number = PlayerService[Player.Name] and Player:GetAttribute("ElapsedTime") or nil
        
        if PlayerElapsed then
            local Minutes: number, Seconds: number = math.floor(PlayerElapsed / 60), PlayerElapsed % 60
            Seconds = Seconds < 10 and "0" .. Seconds or Seconds

            Label.Text = string.format("%s:%s Elapsed", Minutes, Seconds)
        end
    end)
end

--[[
    Creates a new spot for the player and adds them to the queue UI
    @param Player: Player
    @returns nil
]]
function ChefQueueController:EnqueuePlayer(Player: Player)
    local ClonedFrame: Instance = script.Template:Clone()
    
    local Success, Response
    repeat
        Success, Response = PlayerService:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    until Success

    ClonedFrame.Role.Text = RankService:GetRoleInGroup(Player)
    ClonedFrame.Avatar.Image = Success and Response
    ClonedFrame.Username.Text = Player.Name
    ClonedFrame.Name = Player.Name

    ClonedFrame.Parent = self.QueueList
    self:ElapsedTime(Player, ClonedFrame.Timer)
end

--[[
    Removes the player from the queue UI
    @param Player: Player
    @returns nil
]]
function ChefQueueController:DequeuePlayer(Player: Player)
    if self.QueueList:FindFirstChild(Player.Name) then
        self.QueueList:FindFirstChild(Player.Name):Destroy()
    end
end

--[[
    Updates the queue UI based on the queue
    @param Queue: ChefQueue
    @returns nil
]]
function ChefQueueController:UpdateQueue(ChefQueue: table)
    for _, Chef in next, ChefQueue do
        if PlayerService[Chef.Name] then
            self:EnqueuePlayer(Chef)
        end
    end
end

--[[
    Clears the chef queue UI
    @returns nil
]]
function ChefQueueController:ClearQueue()
    for _, Chef in next, self.QueueList:GetChildren() do
        if Chef:IsA("Frame") then
            Chef:Destroy()
        end
    end
end

-- »»————————————　★　————————————-««
-- Chef Queue Functions

--[[
    Creates a tween effect and shows new position on chef queue.
    @returns nil
]]
function ChefQueueController:RegisterEnqueue(Position: number)
    spr.target(self.MainFrame.LeaveQueue, 1, 3, { BackgroundColor3 = Color3.fromRGB(107, 76, 193)})
    task.wait(0.25)
    spr.target(self.MainFrame.LeaveQueue, 1, 3, { BackgroundColor3 = Color3.fromRGB(30, 30, 33)})

    spr.target(self.MainFrame.Holder.QueuePosition, 1, 3, { TextTransparency = 1})
    task.wait(0.25)
    self.MainFrame.Holder.QueuePosition.Text = `You are <b>{Position}</b> in the queue.`
    spr.target(self.MainFrame.Holder.QueuePosition, 1, 3, { TextTransparency = 0})
end

--[[
    Creates a tween effect and shows no position in the queue
    @returns nil
]]
function ChefQueueController:RegisterDequeue()
    spr.target(self.MainFrame.LeaveQueue, 1, 3, { BackgroundColor3 = Color3.fromRGB(107, 76, 193)})
    task.wait(0.25)
    spr.target(self.MainFrame.LeaveQueue, 1, 3, { BackgroundColor3 = Color3.fromRGB(30, 30, 33)})

    spr.target(self.MainFrame.Holder.QueuePosition, 1, 3, { TextTransparency = 1})
    task.wait(0.25)
    self.MainFrame.Holder.QueuePosition.Text = "You are <b>not</b> in the queue."
    spr.target(self.MainFrame.Holder.QueuePosition, 1, 3, { TextTransparency = 0})
end

--[[
    Starts ChefQueueController and creates controller functionality
    @returns void
]]
function ChefQueueController:KnitStart()
    KitchenService = Knit.GetService("KitchenService")
    UIController = Knit.GetController("UIController")

    self.Frame = UIController.UI:WaitForChild("ChefQueue")
    self.MainFrame = self.Frame.Frame
    self.QueueList = self.MainFrame.Holder.ScrollingFrame

    -- Register Enqueue Server Events
    KitchenService.Enqueue:Connect(function(Player: Player)
        self:EnqueuePlayer(Player)
    end)

    -- Register Update Server Events
    KitchenService.Update:Connect(function(ChefQueue: table)
        self:UpdateQueue(ChefQueue)
    end)

    -- Register Dequeue Server Events
    KitchenService.ChefQueue.Dequeue:Connect(function(Player: Player)
        if self.QueueList[Player.Name] then
            self:DequeuePlayer(Player)
            self:RegisterDequeue()
        end
    end)

    -- Register Join Queue Button
    self.MainFrame.JoinQueue.MouseButton1Down:Connect(function()
        KitchenService:JoinChefQueue():andThen(function(Joined: boolean, Position: number)
            if Joined and Position then
                self:RegisterEnqueue(Position)
            end
        end)
    end)

    -- Register Leave Queue Button
    self.MainFrame.LeaveQueue.MouseButton1Down:Connect(function()
        KitchenService:LeaveChefQueue():andThen(function(Left: boolean)
            if Left then
                self:RegisterDequeue()
            end
        end)
    end)
end

-- »»————————————　★　————————————-««
 -- Return Controller to Knit.
return ChefQueueController
