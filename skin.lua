
Skin = {}

function Skin:new( o )
	o = o or {}
	o.colors = {
		{ 255,   0,   0, 255 }, -- 1
		{ 0,   255,   0, 255 }, -- 2
		{ 0,     0, 255, 255 }, -- 3
		{ 255, 255,   0, 255 }, -- 4
		{ 255,   0, 255, 255 }, -- 5
		{ 0,   255, 255, 255 }, -- 6
		{ 255, 255, 255, 255 }, -- 7
	}

	setmetatable( o, self )
	self.__index = self
	return o
end

function Skin:update( dt )
	-- TODO
end

function Skin:draw( game )
	-- constants
	local c = {}
	c.game = game
	c.size = game.size()

	c.screensize  = math.min( love.graphics.getWidth(), love.graphics.getHeight() )
	c.margin      = 0.10 -- percentage
	c.shift       = c.screensize * c.margin
	c.fieldsize   = c.screensize - ( 2 * c.shift )
	c.blocksize   = c.fieldsize / c.size
	c.blockmargin = c.blocksize * 0.10

	self:draw_grid( c )
	self:draw_cubes( c )
	self:draw_cursor( c )
end

function Skin:draw_grid( c )
	left = c.shift
	right = c.shift + c.fieldsize
	top = left
	bottom = right

	rgb = 255 * 0.8
	alpha = 255 * 0.75

	love.graphics.setLineWidth( 2 )
	love.graphics.setColor( rgb, rgb, rgb, alpha )
	for x=0, c.size do
		for y=0, c.size do
			x1 = left + ( x * c.blocksize )
			y1 = top  + ( y * c.blocksize )
			love.graphics.line( x1, top, x1, bottom )
			love.graphics.line( left, y1, right, y1 )
		end
	end
end

function Skin:draw_cubes( c )
	mysize = c.blocksize - 2 * c.blockmargin
	for x=0,(c.size-1) do
		for y=0,(c.size-1) do
			love.graphics.setColor( self.colors[ (x+y) % #self.colors + 1 ] )
			love.graphics.rectangle(
					"fill",
					(x*c.blocksize)+c.shift + c.blockmargin,
					(y*c.blocksize)+c.shift + c.blockmargin,
					mysize,
					mysize )
		end
	end
end

function Skin:draw_cursor( c )
	length = pressed and 1.0 or 0.25
	alpha  = pressed and 1.0 or 0.50

	love.graphics.setLineWidth( 5.0 )
	love.graphics.setColor( 1, 1, 1, alpha )

	-- TODO
end

