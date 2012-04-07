
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
	c.rotation    = c.game.rotation and c.game.rotation or 0

	love.graphics.push()

	if c.rotation ~= 0 then
		local s = c.shift + c.blockmargin + c.fieldsize / 2
		love.graphics.translate( s, s )
		love.graphics.rotate( -c.rotation * math.pi / 2 )
		love.graphics.translate( -s, -s )
	end

	self:draw_grid( c )
	self:draw_cubes( c )
	self:draw_cursor( c )

	love.graphics.pop()
end

function Skin:draw_cubes( c )
	love.graphics.push()

	local mysize = c.blocksize - 2 * c.blockmargin
	local shift  = c.shift + c.blockmargin

	for x=1,(c.size) do
		for y=1,(c.size) do
			local gem = c.game:get( {x=x, y=y} )

			if gem and gem.id > 0 then
				local color = self.colors[ gem.id ]
				color[4] = (gem.clear == 0) and 255 or (255 * gem.clear)
				love.graphics.setColor( color )
				love.graphics.rectangle(
						"fill",
						((x-1)*c.blocksize) + shift + gem.dx * c.blocksize,
						((y-1)*c.blocksize) + shift - gem.dy * c.blocksize,
						mysize,
						mysize )
			end
		end
	end

	love.graphics.pop()
end

function Skin:draw_grid( c )
	local left = c.shift
	local right = c.shift + c.fieldsize
	local top = left
	local bottom = right

	local rgb = 255 * 0.7
	local alpha = 255 * 0.55

	love.graphics.setColor( rgb, rgb, rgb, alpha )
	love.graphics.rectangle( 'fill', left, top, c.fieldsize, c.fieldsize )

	rgb = 255 * 0.8
	alpha = 255 * 0.75
	love.graphics.setColor( rgb, rgb, rgb, alpha )
	love.graphics.setLineWidth( 2 )
	for x=0, c.size do
		for y=0, c.size do
			x1 = left + ( x * c.blocksize )
			y1 = top  + ( y * c.blocksize )
			love.graphics.line( x1, top, x1, bottom )
			love.graphics.line( left, y1, right, y1 )
		end
	end
end

function Skin:draw_cursor( c )
	local left   = c.shift + ( c.game.cursor.x - 1 ) * c.blocksize
	local top    = c.shift + ( c.game.cursor.y - 1 ) * c.blocksize
	local right  = left + c.blocksize
	local bottom = top + c.blocksize

	local pressed = c.game:is_cursor_pressed()

	love.graphics.setLineWidth( 6.0 )
	love.graphics.setColor( 255, 255, 255, pressed and 255 or 255 )

	--print( "Drawing cursor: left=" .. left .. " right=" .. right .. " top=" .. top .. " bot=" .. bottom )

	if pressed then
		love.graphics.line(
			left, top,
			left, bottom,
			right, bottom,
			right, top,
			left, top
		)
	else
		local length = 0.25 * c.blocksize
		love.graphics.line( left, top + length, left, top, left + length, top )
		love.graphics.line( right - length, top, right, top, right, top + length )
		love.graphics.line( right, bottom - length, right, bottom, right - length, bottom )
		love.graphics.line( left + length, bottom, left, bottom, left, bottom - length )
	end
end

