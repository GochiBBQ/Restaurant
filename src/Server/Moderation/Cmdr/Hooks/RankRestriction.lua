return function(registry)
    registry:RegisterHook("BeforeRun", function(context)
        if context.Executor:GetRankInGroup(5874921) < 16 then
            return "These functions can only be executed by developers."
        end
    end)
end