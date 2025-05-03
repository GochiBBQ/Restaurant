--[[

Author: alreadyfans  
For: Gochi

Simple implementation of a HashSet for fast membership testing.  
Useful for tag-like data (e.g. active players, blocked items, etc).

]]

local HashSet = {}
HashSet.__index = HashSet

function HashSet.new()
	return setmetatable({
		_items = {}
	}, HashSet)
end

function HashSet:add(value)
	self._items[value] = true
end

function HashSet:remove(value)
	self._items[value] = nil
end

function HashSet:contains(value)
	return self._items[value] == true
end

function HashSet:values()
	local list = {}
	for value in pairs(self._items) do
		table.insert(list, value)
	end
	return list
end

function HashSet:clear()
	for key in pairs(self._items) do
		self._items[key] = nil
	end
end

function HashSet:size()
	local count = 0
	for _ in pairs(self._items) do
		count += 1
	end
	return count
end

export type HashSet<T> = {
	_items: { [any]: boolean },
	add: (self: HashSet<T>, value: T) -> nil,
	remove: (self: HashSet<T>, value: T) -> nil,
	contains: (self: HashSet<T>, value: T) -> boolean,
	values: (self: HashSet<T>) -> { T },
	clear: (self: HashSet<T>) -> nil,
	size: (self: HashSet<T>) -> number,
}

return HashSet