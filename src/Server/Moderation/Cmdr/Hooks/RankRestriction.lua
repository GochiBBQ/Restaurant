return function(registry)
    registry:RegisterHook("BeforeRun", function(context)
        if context.Executor:GetRankInGroup(5874921) < 16 then
            return "You are not authorized to use Cmdr."
        end
    end)
end