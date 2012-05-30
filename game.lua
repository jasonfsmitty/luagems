require "math"
require "score"

beholder = require "beholder"

Point = {}
Block = {}
Game = {}

local NumBlockTypes = 5 -- 7
local ClearSize = 3
local BoardSize = 8
local SwapRate  = 10.0
local FallRate  = 12.0
local ClearRate = 5.0
local RotateRate = 4.0

local ignore = function () --[[ nothing ]] end

local key = function (x,y) return x .. "_" .. y end

local update_delta = function (value, rate)
	if value > 0 then
		value = value - rate
		if value < 0 then value = 0 end
	elseif value < 0 then
		value = value + rate
		if value > 0 then value = 0 end
	end
	return value
end

-- --------------------------------------------------------------------

-- cursor = { pressed, x, y }
function Point:new( copy )
	local o
	if copy then
		o = { x = copy.x, y = copy.y }
	else
		o = { x = math.floor( BoardSize/2 ), y = math.floor( BoardSize/2 ) }
	end
	setmetatable( o, self )
	self.__index = self
	return o
end

function Point:left()
	if self.x > 1 then
		self.x = self.x - 1
		return true
	end
	return false
end

function Point:right()
	if self.x < BoardSize then
		self.x = self.x + 1
		return true
	end
	return false
end

function Point:up()
	if self.y > 1 then
		self.y = self.y - 1
		return true
	end
	return false
end

function Point:down()
	if self.y < BoardSize then
		self.y = self.y + 1
		return true
	end
	return false
end

-- --------------------------------------------------------------------
BlockStates = {
	dead  = { update = ignore },
	idle  = { update = ignore },

	swap  = {
		update =
			function (block, dt)
				if block:update_swap( dt ) then
					return true
				end
				block:goto( "idle" )
				return false
			end
	},

	clear = {
		update =
			function (block, dt)
				if block:update_clear( dt ) then
					return true
				end
				block:goto( "dead" )
				return false
			end
	},

	fall  = {
		update =
			function (block, dt)
				if block:update_fall( dt ) then
					return true
				end
				block:goto( "idle" )
				return false
			end
	},

	dead = { update = ignore },
}

function Block:new( copy )
	local o = {
		id = math.random( 1, NumBlockTypes ),
		dx = 0,
		dy = 0,
		clear = 0,
		state = BlockStates[ "idle" ],
		statename = "idle",
		key = ""
	}
	if copy then
		-- only copy the type
		o.id = copy.id
	end

	setmetatable( o, self )
	self.__index = self
	return o
end

function Block:dump()
	local s=""
	for i,v in pairs( self ) do
		if i ~= 'state' then
			s = s .. " " .. i .. "=" .. v
		end
	end
	return s
end

function Block:is_alive()
	return self and (self.id ~= 0)
end

function Block:update( dt )
	return self.state.update( self, dt )
end

function Block:goto( state )
	if self.state == BlockStates[ state ] then
		return
	end

	self.state = BlockStates[ state ]
	self.statename = state

	if state == "idle" then
		self.clear = 0
		self.dx = 0
		self.dy = 0
	elseif state == "swap" then
		self.clear = 0
	elseif state == "clear" then
		self.dx = 0
		self.dy = 0
		self.clear = 1.0
	elseif state == "fall" then
		self.dx = 0
		self.clear = 0
	elseif state == "dead" then
		self.id = 0
		self.dx = 0
		self.dy = 0
		self.clear = 0
	end
end

function Block:swap( left, right )
	self.dx = ( left.x - right.x )
	self.dy = ( right.y - left.y )
	self:goto( "swap" )
	print( string.format( "Block.swap( dx=%i, dy=%i )", self.dx, self.dy ) )
end

function Block:drop( dy )
	self.dy = dy
	self:goto( "fall" )
end

function Block:update_swap( dt )
	self.dx = update_delta( self.dx, dt * SwapRate )
	self.dy = update_delta( self.dy, dt * SwapRate )
	return (self.dx ~= 0) or (self.dy ~= 0)
end

function Block:update_clear( dt )
	self.clear = update_delta( self.clear, dt * ClearRate )
	return self.clear ~= 0
end

function Block:update_fall( dt )
	self.dy = update_delta( self.dy, dt * FallRate )
	return self.dy ~= 0
end

-- --------------------------------------------------------------------
GameStates = {
	idle = {
		enter  = function (game) game.score:idle() end,
		move   = function (game,dir) game:do_move( dir ) end,
		rotate =
			function (game,dir)
				if game:do_rotate( dir ) then
					game:goto( "rotate" )
				end
			end,
		fill =
			function (game)
				if game:fill_cleared() then
					game:goto( "fall" )
				end
			end,
		press =
			function (game)
				if game:is_cursor_valid() then
					game:goto( "set" )
				end
			end,
		clear  = ignore,
		toggle = 
			function (game)
				if game:is_cursor_valid() then
					game:goto( "set" )
				end
			end,
		update = ignore,
	},

	rotate = {
		enter   = ignore,
		move    = ignore,
		rotate  = ignore,
		fill    = ignore,
		press   = ignore,
		clear   = ignore,
		toggle  = ignore,
		update  =
			function (game, dt)
				if not game:update_rotate( dt ) then
					if game:mark_falling() then
						game:goto( "fall" )
					else
						game:goto( "idle" )
					end
				end
			end
	},

	set = {
		move =
			function (game, dir)
				if game:do_swap( dir ) then
					game:goto( "swap" )
				end
			end,
		rotate = ignore,
		fill   = ignore,
		press  = ignore,
		clear  = function (game) game:goto( "idle" ) end,
		toggle = function (game) game:goto( "idle" ) end,
		update = ignore,
	},

	swap = {
		move   = function (game, dir) game:do_move( dir ) end,
		rotate = ignore,
		fill   = ignore,
		press  = ignore,
		clear  = ignore,
		toggle = ignore,
		update =
			function (game, dt)
				if not game:update_all( dt ) then
					if game:check_matches() then
						beholder.trigger( "CLEAR" )
						game:goto( "clear" )
					else
						game:do_revert()
						game:goto( "revert" )
					end
				end
			end
	},

	revert = {
		move   = function (game, dir) game:do_move( dir ) end,
		rotate = ignore,
		fill   = ignore,
		press  = ignore,
		clear  = ignore,
		toggle = ignore,
		update =
			function (game, dt)
				if not game:update_all( dt ) then
					game:goto( "idle" )
				end
			end
	},

	clear = {
		move   = function (game, dir) game:do_move( dir ) end,
		rotate = ignore,
		fill   = ignore,
		press  = ignore,
		clear  = ignore,
		toggle = ignore,
		update =
			function (game, dt)
				if not game:update_all( dt ) then
					game:mark_falling()
					--game:fill_cleared()
					game:goto( "fall" )
				end
			end
	},

	fall = {
		move   = function (game, dir) game:do_move( dir ) end,
		rotate = ignore,
		fill   = function (game) game:fill_cleared() end,
		press  = ignore,
		clear  = ignore,
		toggle = ignore,
		update =
			function (game, dt)
				if not game:update_all( dt ) then
					if game:check_matches() then
						beholder.trigger( "CLEAR" )
						game:goto( "clear" )
					else
						game:goto( "idle" )
					end
				end
			end
	},
}

function Game:new( o )
	local o = o or {}
	setmetatable( o, self )
	self.__index = self

	o.cursor = Point:new()
	o.previous = Point:new()
	o.previous.x = o.previous.x + 1

	o.gems = {}
	for x = 1, BoardSize do
		for y = 1, BoardSize do
			o:set( {x=x, y=y}, Block:new() )
		end
	end

	o.state = GameStates["idle"]
	o.statetime = 0
	o.statename = ""

	o.rotation = 0
	o.score = Score:new()

	print( "Initializing board ..." )
	o:goto( "swap" )
	while o.statename ~= "idle" do
		o:fill_cleared()
		o:update( 1000.0 )
	end
	o.score:reset()

	o.dumpId = beholder.observe( "DUMP", function () o:dump() end )
	o.leaveId = beholder.observe( "LEAVE_GAME", function () o:leave() end )

	print( "Finished initializing board, returning o=", o )
	return o
end

function Game:leave()
	beholder.stopObserving( self.dumpId )
	beholder.stopObserving( self.leaveId )
end

function Game:dump()
	print( "DUMP Game:", self )
	for i,v in pairs(self) do
		print( "    " .. i .. "\t= ", v )
	end

	for i,v in pairs( self.gems ) do
		print( "    gems[" .. i .. "] = " .. v:dump() )
	end
end

function Game:get( p )
	return self.gems[ key( p.x, p.y ) ]
end

function Game:set( p, value )
	local k = key( p.x, p.y )
	if value then
		value.key = k
	end
	self.gems[ k ] = value
end

function Game:size()
	return BoardSize
end

function Game:move( dir )
	self.state.move( self, dir )
end

function Game:rotate( dir )
	self.state.rotate( self, dir )
end

function Game:fill()
	if self.state.fill then
		self.state.fill( self )
	end
end

function Game:cursorpress()
	self.state.press( self )
end

function Game:cursorclear()
	self.state.clear( self )
end

function Game:cursortoggle()
	self.state.toggle( self )
end

function Game:movecursor( x, y )
	if self.state.moveto then
		self.state.moveto( self, x, y )
	end
end

function Game:mousepressed( x, y, button )
	if button == "left" then
		self:movecursor( x, y )
		self:cursorpress()
	end
end

function Game:update( dt )
	self.statetime = self.statetime + dt
	self.state.update( self, dt )
end

function Game:goto( state )
	local newstate = GameStates[ state ]
	if not newstate then
		print( "ERROR: cannot transition to invalid state '" .. state .. "'" )
	elseif self.state ~= newstate then
		print( string.format( "GAME.state = %s", state ) )
		self.state = newstate
		self.statetime = 0
		self.statename = state

		if self.state.enter then
			self.state.enter( self )
		end
	end
end

function Game:is_cursor_pressed()
	return self.state == GameStates[ "set" ]
end

function Game:is_cursor_valid()
	local gem = self:get( self.cursor )
	return gem and ( gem.id > 0 )
end

function Game:update_all( dt )
	result = false
	for _,gem in pairs( self.gems ) do
		if gem:update( dt ) then
			result = true
		end
	end
	return result
end

function Game:do_move( dir )
	if self.cursor[ dir ] then
		self.cursor[ dir ]( self.cursor )
	end
end

function Game:do_rotate( dir )
	if dir == "right" or dir == "left" then
		local flipped = ( dir == "left" )

		local copy = self.gems
		local x, y, cx, cy
		self.gems = {}

		for x=1,BoardSize do
			for y=1,BoardSize do
				cx = flipped and ( BoardSize - y + 1 ) or y
				cy = flipped and x or ( BoardSize - x + 1 )
				self:set( {x=x, y=y}, copy[ key( cx, cy ) ] )
			end
		end
		copy = nil
		self.rotation = flipped and -1.0 or 1.0

		-- flip the cursor as well
		x = self.cursor.x
		y = self.cursor.y
		self.cursor.x = flipped and y or (BoardSize - y + 1)
		self.cursor.y = flipped and (BoardSize - x + 1) or x
	else
		print( "ERROR: Invalid game rotate direction '" .. dir .. "'" )
		return false
	end
	return true
end

function Game:update_rotate( dt )
	self.rotation = update_delta( self.rotation, dt * RotateRate )
	return self.rotation ~= 0
end

function Game:do_swap( dir )
	local tmp = Point:new( self.cursor )
	local func = tmp[dir]
	if func and func( tmp ) then
		self.previous = tmp
		return self:do_revert()
	end
	return false
end

function Game:do_revert()
	local gem1 = self:get( self.cursor )
	local gem2 = self:get( self.previous )

	if not gem1 or not gem2 then return false end
	if (gem1.id == 0) or (gem2.id == 0) then return false end

	gem1:swap( self.cursor, self.previous )
	gem2:swap( self.previous, self.cursor )
	
	self:set( self.cursor, gem2 )
	self:set( self.previous, gem1 )

	self.cursor, self.previous = self.previous, self.cursor

	return true
end

function Game:scan_for_matches( flipped )
	local found = false

	local make_point = function ( col, row )
		return { x = flipped and row or col, y = flipped and col or row }
	end

	for row = 1,BoardSize do
		local id = -1
		local count = 0

		local scorer = Scorer:new( self.score )

		for col = 1, BoardSize do
			local gem = self:get( make_point( col, row ) )

			if not gem then
				id = -1
				count = 0
				scorer:flush()
			elseif gem.id == 0 then
				id = -1
				count = 0
				scorer:flush()
			elseif gem.id ~= id then
				id = gem.id
				count = 1
			else
				count = count + 1
				if count == ClearSize then
					found = true
					for col2 = (col - count + 1), col do
						local tmp = self:get( make_point( col2, row ) )
						scorer:add( tmp )
						tmp:goto( "clear" )
					end
				elseif count > ClearSize then
					scorer:add( gem )
					gem:goto( "clear" )
				else
					-- not enough for clear yet
				end
			end
		end

		scorer:flush()
	end

	return found
end

function Game:check_matches()
	self.score:start()
	local horiz = self:scan_for_matches( false )
	local vert  = self:scan_for_matches( true )
	self.score:stop( self:count_empty() )
	return horiz or vert
end

function Game:count_empty()
	local missing = 0
	for x=1,BoardSize do
		for y=1,BoardSize do
			local gem = self:get( {x=x,y=y} )
			if not gem or gem.id == 0 then
				missing = missing + 1
			end
		end
	end
	return missing
end

function Game:mark_falling()
	local found = false

	for x = 1,BoardSize do
		local shift = 0
		for y = BoardSize,1,-1 do
			local gem = self:get( { x=x, y=y } )

			if not ( gem and gem:is_alive() ) then
				shift = shift + 1
			elseif shift > 0 then
				self:set( {x=x,y=y}, nil )
				self:set( {x=x, y=(y + shift)}, gem )
				gem:drop( shift )
				found = true
			end
		end
	end

	return found
end

function Game:fill_cleared()
	local found = false
	for x = 1,BoardSize do
		local start = -1
		for y = BoardSize,1,-1 do
			local p = { x=x, y=y }
			local gem = self:get( p )

			if not ( gem and gem:is_alive() ) then
				if start < 0 then
					start = BoardSize - p.y
				end

				gem = Block:new()
				gem:drop( BoardSize - start )
				self:set( p, gem )

				found = true
			end
		end
	end

	return found
end

