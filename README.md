# Restaurant
It's important to note the following when coding for Gochi, this is to ensure everyone's code is efficent and similar to each other.

-- CLIENT CODE --
1. Knit.Modules is referenced to the Client Modules. These include spr, UIEffects, Confetti, etc.
2. DO NOT USE THE PACKAGES.SIGNALS, Knit:CreateSignal() is the PROPER way.
3. Do not use TweenService, use spr. However, spr does not support Camera Tweens, so use TweenService instead for camera manipulation. TEMPLATE: (spr.target(Instance, Spring Frequency, Speed)

-- SERVER CODE --
1. Use TROVE to disconnect any unused remote events from the server. If you're unsure how, ask Morgan. trove:Add() doesn't automatically disconnect it, so if you're stuck on this, ask!
2. DO NOT USE THE PACKAGES.SIGNALS, Knit:CreateSignal() is the PROPER way.
3. It is preferred to use RemoteFunctions instead of RemoteEvents if you are sending from the client grabbing from the server then returning back to the client. However, RemoteEvents are better than RemoteFunctions when you are sending from the server to the client.
4. Please for the love of god, use RateManager, it is used to rate limit for a reason.
5. Make sure that memory usage is ALWAYS down. I don't want to hear complaints about lag on release. Remember to look in game tho, Roblox Studio uses ur PC not Roblox Servers
6. Please make your template at least similar to everyone elses with the spacers n stuff, it cleans code a lot moreeeee