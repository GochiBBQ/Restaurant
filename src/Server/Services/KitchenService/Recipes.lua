--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Variables
local KitchenService

Knit.OnStart():andThen(function()
	KitchenService = Knit.GetService("KitchenService")
end)

return {
	-- Appetizers
	["Kimbap"] = function(Player: Player, Stove: Instance)
		-- Description: An assorted medley of vegetables wrapped in a soft bed of white rice and a piece of seasoned laver with a dash of oil.
		-- Number of steps: 7
		-- Steps:
		-- 1. Plate
		-- 2. Seaweed (Fridge)
		-- 3. Carrots (Fridge)
		-- 4. Spinach (Fridge)
		-- 6. Fish Cake
		-- 7. Roller Board
		-- 8. Oil (Oil Thingy)

		Player:SetAttribute("BackpackEnabled", false)
		KitchenService:_getPlate(Player)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Seaweed")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Carrots")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Spinach")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Fish Cake")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_rollItem(Player, 'Kimbap')
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Oil")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_submitItem(Player, "Kimbap"):andThen(function()
					Player:SetAttribute("BackpackEnabled", true)
				end)
			end)
	end,
	["Tteokbokki"] = function(Player: Player, Stove: Instance)
		-- Description: Street food made from chewy rice cakes and fish cakes, stir-fried in a spicy and savory sauce, typically made with gochujang.
		-- Number of steps: 6
		-- Steps:
		-- 1. Plate
		-- 2. Rice Cakes (Fridge)
		-- 3. Red Pepper Paste
		-- 4. Fish Cakes (Fridge)
		-- 5. Ketchup
		-- 6. Frying Pan
		Player:SetAttribute("BackpackEnabled", false)
		KitchenService:_getPlate(Player)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Rice Cake")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Red Pepper Paste")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Fish Cake")
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Ketchup")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_fryItem(Player, "Tteokbokki")				
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_submitItem(Player, "Tteokbokki"):andThen(function()
					Player:SetAttribute("BackpackEnabled", true)
				end)
			end)
		end)
	end,
	["Classic Korean Hotdog"] = function(Player: Player, Stove: Instance)
		-- Description: Crispy, deep-fried batter filled with sausage, mozzarella, or both. Lightly sweetened and served with ketchup and mustard.
		-- Number of steps: 10
		-- Steps:
		-- 1. Plate
		-- 2. Skewer
		-- 3. Sausage (Fridge)
		-- 4. Chopping Board
		-- 5. Mozzarella (Fridge)
		-- 6. Chopping Board
		-- 7. Batter (Fridge)
		-- 8. Fryer
		-- 9. Sugar
		-- 10. Ketchup
		-- 11. Mustard
		Player:SetAttribute("BackpackEnabled", false)
		KitchenService:_getPlate(Player)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Skewer")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Sausage")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_rollItem(Player, "Classic Korean Hotdog")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Mozzarella")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_rollItem(Player, "Classic Korean Hotdog")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Batter")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_deepFryItem(Player, "Hotdog")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Sugar")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Ketchup")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Mustard")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_submitItem(Player, "Classic Korean Hotdog"):andThen(function()
					Player:SetAttribute("BackpackEnabled", true)
				end)
			end)
	end,
	["Potato Korean Hotdog"] = function(Player: Player, Stove: Instance)
		-- Description: A crispy, deep-fried hotdog coated in diced potatoes, filled with sausage, mozzarella. Served with a spritz of ketchup and mustard for a crunchy, flavorful treat.
		-- Number of steps: 13
		-- Steps:
		-- 1. Plate
		-- 2. Skewer
		-- 3. Sausage (Fridge)
		-- 4. Chopping Board
		-- 5. Mozzarella (Fridge)
		-- 6. Chopping Board
		-- 7. Batter
		-- 8. Potato (Fridge)
		-- 9. Chopping Board
		-- 10. Bread Crumbs
		-- 11. Fryer
		-- 12. Ketchup
		-- 13. Mustard
		Player:SetAttribute("BackpackEnabled", false)
		KitchenService:_getPlate(Player)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Skewer")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Sausage")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_rollItem(Player, "Potato Korean Hotdog")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Mozzarella")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_rollItem(Player, "Potato Korean Hotdog")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Batter")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Potato")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_rollItem(Player, "Potato Korean Hotdog")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Bread Crumbs")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_deepFryItem(Player, "Potato Korean Hotdog")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Ketchup")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Mustard")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_submitItem(Player, "Potato Korean Hotdog"):andThen(function()
					Player:SetAttribute("BackpackEnabled", true)
				end)
			end)
	end,
	["Kimchi Fried Rice"] = function(Player: Player, Stove: Instance)
		-- Description: Stir-fried rice with spicy, tangy kimchi, mixed with vegetables, and fried egg for a flavorful, hearty dish.
		-- Number of steps: 9
		-- Steps:
		-- 1. Deep Bowl
		-- 2. Rice Cooker
		-- 3. Kimchi (Fridge)
		-- 4. Carrots (Fridge)
		-- 5. Chopping Board
		-- 6. Onions (Fridge)
		-- 7. Chopping Board
		-- 8. Oil (Oil Thingy)
		-- 9. Frying Pan
		Player:SetAttribute("BackpackEnabled", false)
		KitchenService:_getBowl(Player)
			:andThen(function()
				task.wait(1)
				return KitchenService:_cookRice(Player, "Kimchi Fried Rice")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Kimchi")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Carrots")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_rollItem(Player, "Kimchi Fried Rice")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Onions")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_rollItem(Player, "Kimchi Fried Rice")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Oil")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_fryItem(Player, "Kimchi Fried Rice")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_submitItem(Player, "Kimchi Fried Rice"):andThen(function()
					Player:SetAttribute("BackpackEnabled", true)
				end)
			end)

	end,
	["Kimchijeon"] = function(Player: Player, Stove: Instance)
		-- Description: A savory, crispy pancake made with fermented kimchi and batter, pan-fried to golden perfection. Packed with bold flavors and a satisfying crunch.
		-- Number of steps: 9
		-- Steps:
		-- 1. Plate
		-- 2. Flour
		-- 3. Pancake Mix
		-- 4. Frying Batter
		-- 5. Kimchi
		-- 6. Onions
		-- 7. Chopping Board
		-- 8. Mixer
		-- 9. Frying Pan
		Player:SetAttribute("BackpackEnabled", false)
		KitchenService:_getPlate(Player)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Flour")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Pancake Mix")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Batter")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Kimchi")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Onions")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_rollItem(Player, "Kimchijeon")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_fryItem(Player, "Kimchijeon")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_submitItem(Player, "Kimchijeon"):andThen(function()
					Player:SetAttribute("BackpackEnabled", true)
				end)
			end)
	end,
	["Japchae"] = function(Player: Player, Stove: Instance)
		-- Description: Stir-fried glass noodles with a mix of vegetables, thinly sliced beef, and a savory-sweet soy sauce. A flavorful and balanced dish with tender noodles and vibrant veggies.
		-- Number of steps: 11
		-- Steps:
		-- 1. Deep Bowl
		-- 2. Glass Noodles
		-- 3. Pot (Boil)
		-- 4. Oil
		-- 5. Carrots
		-- 6. Chopping Board
		-- 7. Onions
		-- 8. Chopping Board
		-- 9. Seasoned Spinach
		-- 10. Frying Pan
		-- 11. Sesame Seeds
		Player:SetAttribute("BackpackEnabled", false)
		KitchenService:_getBowl(Player)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Glass Noodles")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_boilItem(Player, "Japchae")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Oil")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Carrots")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_rollItem(Player, "Japchae")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Onions")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_rollItem(Player, "Japchae")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Spinach")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_rollItem(Player, "Japchae")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_fryItem(Player, "Japchae")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Sesame Seeds")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_submitItem(Player, "Japchae"):andThen(function()
					Player:SetAttribute("BackpackEnabled", true)
				end)
			end)

	end,
	["Mandu"] = function(Player: Player, Stove: Instance)
		-- Description: Korean-style dumplings filled with a savory mix of meat, vegetables, and spices. Pan-fried for a crispy, tender bite. Served with a tangy dipping sauce.
		-- Number of steps: 7
		-- Steps:
		-- 1. Plate
		-- 2. Dumplings
		-- 3. Oil
		-- 4. Frying Pan
		-- 5. Green Onions
		-- 6. Chopping Board
		-- 7. Parsley

		Player:SetAttribute("BackpackEnabled", false)
		KitchenService:_getPlate(Player)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Dumplings")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Oil")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_fryItem(Player, "Mandu")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Green Onions")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_rollItem(Player, "Mandu")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Parsley")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_submitItem(Player, "Mandu"):andThen(function()
					Player:SetAttribute("BackpackEnabled", true)
				end)
			end)
	end,

	-- Entrees
	["Korean Fried Chicken"] = function(Player: Player, Stove: Instance)
		-- Description: A popular dish among teenagers, this rendition of fried chicken brings the heat into the meat. With assortments of wings and drumsticks, each piece is carefully seasoned and fried to be crispy.
		-- Number of steps: 11
		-- Steps:
		-- 1. Plate
		-- 2. Chicken (Drumsticks)
		-- 3. Chicken (Wings)
		-- 4. Paprika
		-- 5. Salt
		-- 6. Garlic
		-- 7. Red Pepper Paste
		-- 8. Ketchup
		-- 9. Sugar
		-- 10. Bread Crumbs
		-- 11. Fryer

		Player:SetAttribute("BackpackEnabled", false)
		KitchenService:_getPlate(Player)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Chicken (Drumsticks)")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Chicken (Wings)")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Paprika")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Salt")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Garlic")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Red Pepper Paste")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Ketchup")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Sugar")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Bread Crumbs")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_deepFryItem(Player, "Korean Fried Chicken")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_submitItem(Player, "Korean Fried Chicken"):andThen(function()
					Player:SetAttribute("BackpackEnabled", true)
				end)
			end)
	end,
	["Bibimbap"] = function(Player: Player, Stove: Instance)
		-- Description: One of the most iconic dishes of South Korea, a mix of rice and a huge variety of vegetables with hints of beef, topped off with a fragile egg yolk.
		-- Number of steps: 12
		-- Steps:
		-- 1. Deep Bowl
		-- 3. Rice Cooker
		-- 4. Spinach
		-- 5. Carrots
		-- 6. Chopping Board
		-- 7. Bean Sprouts
		-- 8. Dried Anchovies
		-- 9. Oil
		-- 10. Frying Pan
		-- 11. Sesame Seeds
		-- 12. Egg
		Player:SetAttribute("BackpackEnabled", false)
		KitchenService:_getBowl(Player)
			:andThen(function()
				task.wait(1)
				return KitchenService:_cookRice(Player, "Bibimbap")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Spinach")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Carrots")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_rollItem(Player, "Bibimbap")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Bean Sprouts")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Dried Anchovies")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Oil")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_fryItem(Player, "Bibimbap")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Sesame Seeds")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Egg")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_submitItem(Player, "Bibimbap"):andThen(function()
					Player:SetAttribute("BackpackEnabled", true)
				end)
			end)
	end,
	["Classic Ramyeon"] = function(Player: Player, Stove: Instance)
		-- Description: A comforting bowl of spicy Korean noodle soup with chewy noodles, a rich broth, and various toppings like vegetables, egg, and meat.
		-- Number of steps: 8
		-- Steps:
		-- 1. Pot
		-- 2. Water
		-- 3. Ramyeon Noodles
		-- 4. Soup Base
		-- 5. Vegetables
		-- 6. Egg
		-- 7. Green Onions
		-- 8. Chili Flakes
		Player:SetAttribute("BackpackEnabled", false)
		KitchenService:_boilItem(Player, "Classic Ramyeon")
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Ramyeon Noodles")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Soup Base")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Assorted Vegetables")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Egg")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getFridgeIngredient(Player, "Green Onions")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_getStorageItem(Player, "Chili Flakes")
			end)
			:andThen(function()
				task.wait(1)
				return KitchenService:_submitItem(Player, "Classic Ramyeon"):andThen(function()
					Player:SetAttribute("BackpackEnabled", true)
				end)
			end)
	end,
}
