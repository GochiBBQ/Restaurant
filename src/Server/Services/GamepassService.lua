--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

-- Create Knit Service
local GamepassService = Knit.CreateService {
    Name = "GamepassService",
	Client = {
		UpdateSettings = Knit.CreateSignal(),
	},
	SettingUpdated = Signal.new(),
}

local Gamepasses = {
    ["Headless"] = {
        ID = 1002697699,
    },
    ["Korblox"] = {
        ID = 1004797619,
    },
    ["Walkspeed"] = {
        ID = 1003057662,
    },
    ["DisableUniform"] = {
        ID = 1003177642,
    },
}

-- Variables
local OwnedGamepasses = {}

local RankService

-- Server Functions
function GamepassService:KnitStart()
    RankService = Knit.GetService("RankService")

    Players.PlayerAdded:Connect(function(Player)
        self:HandlePlayerAdded(Player)
    end)

    Players.PlayerRemoving:Connect(function(Player)
        OwnedGamepasses[Player.UserId] = nil
    end)

    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(Player, GamepassID, wasPurchased)
        if wasPurchased then
            self:HandleGamePassPurchase(Player, GamepassID)
        end
    end)
end

function GamepassService:HandlePlayerAdded(Player)
    OwnedGamepasses[Player.UserId] = {}

    -- Check owned gamepasses on player join
    for gamepass, data in pairs(Gamepasses) do
        local ID = data.ID
        if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, ID) or Player:GetRankInGroup(5874921) >= 16 then
            table.insert(OwnedGamepasses[Player.UserId], gamepass)
        end
    end

    -- Listen for character added to apply gamepasses
    Player.CharacterAdded:Connect(function(character)
        self:InitializeGamepasses(Player)
    end)

    -- Ensure initialization when player first joins
    if Player.Character then
        self:InitializeGamepasses(Player)
    end
end

function GamepassService:InitializeGamepasses(Player)
    for _, gamepass in ipairs(OwnedGamepasses[Player.UserId]) do
        if gamepass == "Walkspeed" then
            self:InitWalkspeed(Player, true)
        elseif gamepass == "Headless" then
            self:InitHeadless(Player, true)
        elseif gamepass == "Korblox" then
            self:InitKorblox(Player, true)
        elseif gamepass == "DisableUniform" then
            self:InitUniform(Player, true)
        end
    end
end

function GamepassService:GetGamepasses(Player)
    while not Player:GetAttribute("Loaded") do
        task.wait()
    end

    local Profile = Knit.Profiles[Player]
    if not Profile then
        return nil
    end

    local Gamepasses = Profile.Data.Settings['Gamepasses']

    for gamepass, toggle in pairs(Gamepasses) do
        if toggle then
            self:HandleGamePassUpdated(Player, gamepass, true)
        end
    end

    return Gamepasses
end

function GamepassService:UpdateGamepass(Player: Player, Gamepass: string, Type: boolean)
    local Profile = Knit.Profiles[Player]

    if Profile then
        local Settings = Profile.Data.Settings['Gamepasses']
        if self:CheckPass(Player, Gamepass) then
            if Settings[Gamepass] ~= nil then
                Profile.Data.Settings['Gamepasses'][Gamepass] = Type
                self.Client.UpdateSettings:Fire(Player, Gamepass, Type)
                self.SettingUpdated:Fire(Player, Gamepass, Type)
            else
                Profile.Data.Settings['Gamepasses'][Gamepass] = Type
                self.Client.UpdateSettings:Fire(Player, Gamepass, Type)
                self.SettingUpdated:Fire(Player, Gamepass, Type)
            end

            self:HandleGamePassUpdated(Player, Gamepass, Type)
        else
            Profile.Data.Settings['Gamepasses'][Gamepass] = false
            self.Client.UpdateSettings:Fire(Player, Gamepass, false)
            self.SettingUpdated:Fire(Player, Gamepass, false)
        end
    end
end

function GamepassService:HandleGamePassPurchase(Player, GamepassID)
    table.insert(OwnedGamepasses[Player.UserId], GamepassID)

    if GamepassID == Gamepasses.Headless.ID then
        self:UpdateGamepass(Player, "Headless", true)
        self:InitHeadless(Player, true)
    elseif GamepassID == Gamepasses.Korblox.ID then
        self:UpdateGamepass(Player, "Korblox", true)
        self:InitKorblox(Player, true)
    elseif GamepassID == Gamepasses.Walkspeed.ID then
        self:UpdateGamepass(Player, "Walkspeed", true)
        self:InitWalkspeed(Player, true)
    elseif GamepassID == Gamepasses.DisableUniform.ID then
        self:UpdateGamepass(Player, "DisableUniform", true)
        self:InitUniform(Player, true)
    end
end

function GamepassService:HandleGamePassUpdated(Player, Gamepass, Toggle)
    if Gamepass == "Walkspeed" then
        self:InitWalkspeed(Player, Toggle)
    elseif Gamepass == "Headless" then
        self:InitHeadless(Player, Toggle)
    elseif Gamepass == "Korblox" then
        self:InitKorblox(Player, Toggle)
    elseif Gamepass == "DisableUniform" then
        self:InitUniform(Player, Toggle)
    end
end

function GamepassService:InitUniform(Player, Action)
    if self:CheckPass(Player, "DisableUniform") and RankService:GetRank(Player) < 7 then
        local character = Player.Character or Player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChild("Humanoid")

        if Action then
            local HumanoidDescription = Players:GetHumanoidDescriptionFromUserId(Player.UserId)
            humanoid:ApplyDescription(HumanoidDescription)
        end
    end
end

function GamepassService:InitWalkspeed(Player, Action)
    if self:CheckPass(Player, "Walkspeed") then
        local character = Player.Character or Player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChild("Humanoid")

        if Action then
            Player:SetAttribute("Walkspeed", true)
            humanoid.WalkSpeed = 32
        else
            humanoid.WalkSpeed = 16
            Player:SetAttribute("Walkspeed", false)
        end
    end
end

function GamepassService:InitHeadless(Player, Action)
    if self:CheckPass(Player, "Headless") then
        local Character = Player.Character or Player.CharacterAdded:Wait()
        local Head = Character:FindFirstChild("Head")
        local Face = Head:FindFirstChild("face")

        if Action then
            Head.Transparency = 1
            if Face then
                Face.Face = "Bottom"
            end
        else
            Head.Transparency = 0
            if Face then
                Face.Face = "Front"
            end
        end
    end
end

function GamepassService:InitKorblox(Player, Action)
    if self:CheckPass(Player, "Korblox") then
        local character = Player.Character or Player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChild("Humanoid")
        local humanoidDesc = humanoid:GetAppliedDescription()

        if Action then
            humanoidDesc.RightLeg = 139607718
            humanoid:ApplyDescription(humanoidDesc)
        else
            humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(Player.UserId))
        end
    end
end

function GamepassService:CheckPass(Player, Pass)
    repeat
        task.wait()
    until Player:GetAttribute("Loaded")

    return table.find(OwnedGamepasses[Player.UserId], Pass)
end

-- Client Functions
function GamepassService.Client:Check(Player, Pass)
    return self.Server:CheckPass(Player, Pass)
end

function GamepassService.Client:Update(Player: Player, Gamepass: string, Type: boolean)
    self.Server:UpdateGamepass(Player, Gamepass, Type)
end

function GamepassService.Client:Get(Player)
    return self.Server:GetGamepasses(Player)
end

-- Return Service to Knit
return GamepassService
