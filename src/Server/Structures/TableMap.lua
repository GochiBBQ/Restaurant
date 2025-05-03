--[[

Author: alreadyfans
For: Gochi

A lightweight key-value store wrapper with utility methods.
Primarily used for mapping things like Player/UserId to data.

]]

local TableMap = {}
TableMap.__index = TableMap

function TableMap.new()
	return setmetatable({
		_store = {}
	}, TableMap)
end

function TableMap:set(key, value)
	self._store[key] = value
end

function TableMap:get(key)
	return self._store[key]
end

function TableMap:remove(key)
	self._store[key] = nil
end

function TableMap:contains(key)
	return self._store[key] ~= nil
end

function TableMap:keys()
	local keys = {}
	for k in pairs(self._store) do
		table.insert(keys, k)
	end
	return keys
end

function TableMap:values()
	local values = {}
	for _, v in pairs(self._store) do
		table.insert(values, v)
	end
	return values
end

function TableMap:entries()
	return pairs(self._store)
end

function TableMap:clear()
	for k in pairs(self._store) do
		self._store[k] = nil
	end
end

export type TableMap<T> = {
	_store: { [any]: T },
	set: (self: TableMap<T>, key: any, value: T) -> nil,
	get: (self: TableMap<T>, key: any) -> T | nil,
	remove: (self: TableMap<T>, key: any) -> nil,
	contains: (self: TableMap<T>, key: any) -> boolean,
	keys: (self: TableMap<T>) -> { any },
	values: (self: TableMap<T>) -> { T },
	entries: (self: TableMap<T>) -> (any, T),
	clear: (self: TableMap<T>) -> nil
}

return TableMap
