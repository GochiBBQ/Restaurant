-- PagesUtil | colbert2677 | January 9th, 2023

--[=[
	Simple utility for working with Roblox pages instances.

	@class PagesUtil
]=]
local PagesUtil = {}

--[=[
	:::caution Yielding function
	This function will yield due to its AdvanceToNextPageAsync call in a
	while loop.
	:::

	Generate an equivalent representation of the Pages instance as a table. This
	will get rid of the overhead of the Pages instance and API, presenting the
	content as a table.

	```lua
	local friends = Promise.resolve(PagesUtil.Table(Players:GetFriendsAsync(6809102)))
	print(friends[#friends][1]) -- First element of the last page
	```

	@yields
]=]
function PagesUtil.Table(pages: Pages): {{any}}
	local items = {}

	while true do
		table.insert(items, pages:GetCurrentPage())

		if pages.IsFinished then
			break
		end

		pages:AdvanceToNextPageAsync()
	end

	return items
end

--[=[
	:::caution Yielding function
	This function will yield due to its AdvanceToNextPageAsync call in a
	while loop.
	:::

	Generate a one-dimensional array containing all elements of all pages of a
	given Pages instance.

	```lua
	local friends = Promise.resolve(PagesUtil.Elements(Players:GetFriendsAsync(6809102)))
	print(friends[#friends]) -- Last overall element
	```

	@yields
]=]
function PagesUtil.Elements(pages: Pages): {any}
	local items = {}

	while true do
		for _, item in ipairs(pages:GetCurrentPage()) do
			table.insert(items, item)
		end

		if pages.IsFinished then
			break
		end

		pages:AdvanceToNextPageAsync()
	end

	return items
end

--[=[
	Return a coroutine for a stateful iterator, allowing looping through page
	content much like a table. Iterate converts the Pages instance into a
	table via [Table](/api/PagesUtil#Table) under the hood and advances pages
	automatically.

	The two variables returned are the element and the page number in that
	order. All other rules of iteration apply.

	This is an abstraction for hand-iterating the results of
	[Table](/api/PagesUtil#Table) where you would normally write a loop per
	dimension.

	:::caution Use with a for loop
	Iterate is intended to be placed as the iterator of a `for` loop. Although it
	is possible to use Iterate outside of a loop, it is generally not recommended
	chiefly on account of readability and consistency.
	:::

	:::tip Niche use case
	Should only be used if knowing the page number is important. Most cases for
	iterating pages should be done by first breaking down the pages with
	[Elements](/api/PagesUtil#Elements) and then iterating through it with ipairs
	or generalised iteration.
	:::

	```lua
	-- Usage:
	for element, pageNo in PagesUtil.Iterate(foobarPages) do
		something(element, pageNo)
	end

	-- Equivalent without Iterate:
	for pageNo, content in ipairs(PagesUtil.Table(foobarPages)) do
		for _, element in ipairs(content) do
			something(element, pageNo)
		end
	end
	```

	@return coroutine
]=]
function PagesUtil.Iterate(pages: Pages)
	local contents = PagesUtil.Table(pages)
	local pageNum = 1

	return coroutine.wrap(function()
		while pageNum <= #contents do
			for _, item in ipairs(contents[pageNum]) do
				coroutine.yield(item, pageNum)
			end

			pageNum += 1
		end
	end)
end

return PagesUtil
