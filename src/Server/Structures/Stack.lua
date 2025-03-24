--[[

Author: alreadyfans  
For: Gochi

Simple LIFO (Last-In-First-Out) stack.  
Use for backtracking, undo systems, or menu layers.

]]

local Stack = {}
Stack.__index = Stack

function Stack.new()
	return setmetatable({
		_stack = {}
	}, Stack)
end

function Stack:push(value)
	table.insert(self._stack, value)
end

function Stack:pop()
	return table.remove(self._stack)
end

function Stack:peek()
	return self._stack[#self._stack]
end

function Stack:isEmpty()
	return #self._stack == 0
end

function Stack:size()
	return #self._stack
end

function Stack:clear()
	table.clear(self._stack)
end

return Stack
