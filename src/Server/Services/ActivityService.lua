--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit)
local hyra: ModuleScript = require(126591263956758)

-- Create Knit Service
local ActivityService = Knit.CreateService {
    Name = "ActivityService",
    Client = {},
}

-- Server Functions
function ActivityService:KnitStart()
    hyra.init("55630135c408babba829002e4ce9038390178983f9e5ec3432d459c7d4797e348fa7324b2aacbb4e9c85b8ae3334bff7b380e98a9587ce3de7555ed437b6aac34c23e6d021bcc854b9b3c7e9024aedb8359acf2d9f22c7d4272ae039108dca8e9be17cba1572b8d10c89d6fbdf254aaf2ebe21b403768683faf5cfefa64dbf3b")
end

 -- Return Service to Knit.
return ActivityService
