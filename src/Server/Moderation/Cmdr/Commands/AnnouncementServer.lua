local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(context, announcement)
    local NotificationService = Knit.GetService("NotificationService")
    
    NotificationService:CreateAnnouncement(announcement :: string)
end