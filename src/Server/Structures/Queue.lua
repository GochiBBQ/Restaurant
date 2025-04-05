--[[

Author: alreadyfans  
For: Gochi

Simple FIFO (First-In-First-Out) queue implementation.  
Great for order management, waitlists, or task scheduling.

]]

local Queue = {}
Queue.__index = Queue

function Queue.new()
	return setmetatable({
		_queue = {},
		front = 1,
		back = 0
	}, Queue)
end

function Queue:push(value)
	self.back += 1
	self._queue[self.back] = value
end

function Queue:pop()
	if self:isEmpty() then return nil end
	local value = self._queue[self.front]
	self._queue[self.front] = nil
	self.front += 1
	return value
end

function Queue:peek()
	return self._queue[self.front]
end

function Queue:isEmpty()
	return self.front > self.back
end

function Queue:size()
	return self.back - self.front + 1
end

function Queue:clear()
	for i = self.front, self.back do
		self._queue[i] = nil
	end
	self.front = 1
	self.back = 0
end

return Queue
