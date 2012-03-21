require "math"

Cursor = {}
Block = {}
Game = {}

local boardsize = 7

local key = function ( x, y )
	return x .. "_" .. y
end

-- --------------------------------------------------------------------

-- cursor = { pressed, x, y }
function Cursor:new()
	o = { pressed = false, x = boardsize/2, y = boardsize/2 }
	setmetatable( o, self )
	self.__index = self
	return o
end

-- --------------------------------------------------------------------

function Block:new()
	o = o or {}
	o.id = self.id or math.random( 1, boardsize )
	setmetatable( o, self )
	self.__index = self
	return o
end

-- --------------------------------------------------------------------
function Game:get( x, y )
	return self.gems[ key(x,y) ]
end

function Game:set( x, y, value )
	self.gems[ key(x, y) ] = value
end

function Game:size()
	return boardsize
end

function Game:move( dir )
	-- left, right, up, or down
	-- TODO
end

function Game:cursorpress()
	-- TODO
end

function Game:cursorclear()
	-- TODO
end

function Game:cursortoggle()
	-- TODO
end

function Game:update(dt)
	-- TODO
end

function Game:draw()
	-- TODO
end

function Game:new( o )
	o = o or {}
	setmetatable( o, self )
	self.__index = self

	o.cursor = Cursor:new()
	o.gems = {}
	for x = 1, boardsize do
		for y = 1, boardsize do
			o:set( x, y, Block:new() )
		end
	end

	return o
end

