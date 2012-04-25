beholder = require "beholder"
Skin = {}

local IsBoardCentered = false

function Skin:new( o )
	local o = o or {}
	o.colors = {
		{ 0,   255, 255, 255 }, -- 1
		{ 255, 255,   0, 255 }, -- 2
		{ 255,   0, 255, 255 }, -- 3
		{ 0,   255,   0, 255 }, -- 4
		{ 255,   0,   0, 255 }, -- 5
		{ 255, 255, 255, 255 }, -- 6
		{ 0,     0, 255, 255 }, -- 7 blue
	}

	o.fontsize = 20
	o.font = love.graphics.newFont( "fonts/CPMono_v07_Black.otf", o.fontsize )
	--o.font = love.graphics.newFont( "fonts/UbuntuMono-B.ttf", o.fontsize )

	o.scores = {}
	o.scoreId = beholder.observe( "SCORE", function (amount) o:addScore(amount) end )

	setmetatable( o, self )
	self.__index = self
	return o
end

function Skin:addScore( amount )
	print( "Skin received scoring event, score=", amount )
	table.insert( self.scores, { value=amount, time=1 } )
end

function Skin:update( dt )
	local decayRate = 0.5
	local todelete = 0
	for i,score in ipairs( self.scores ) do
		score.time = score.time - ( dt * decayRate )
		if score.time <= 0 then
			todelete = todelete + 1
		end
	end
	for i=1,todelete do
		table.remove( self.scores, 1 )
	end
end

function Skin:draw( game )
	-- constants
	local c = {}
	c.game = game
	c.size = game.size()

	c.width       = love.graphics.getWidth()
	c.height      = love.graphics.getHeight()
	c.margin      = c.height * 0.10
	c.fieldsize   = c.height - 2 * c.margin
	c.blocksize   = c.fieldsize / c.size
	c.blockmargin = c.blocksize * 0.10
	c.rotation    = c.game.rotation or 0

	if IsBoardCentered then
		c.left    = ( c.width - c.fieldsize ) / 2
	else
		c.left    = c.margin
	end

	c.top         = c.margin
	c.bottom      = c.margin + c.fieldsize
	c.right       = c.left + c.fieldsize

	love.graphics.push()
		if c.rotation ~= 0 then
			local x = c.left + c.fieldsize/2
			local y = c.top + c.fieldsize/2
			love.graphics.translate( x, y )
			love.graphics.rotate( -c.rotation * math.pi / 2 )
			love.graphics.translate( -x, -y )
		end

		self:draw_grid( c )
		self:draw_cubes( c )
		self:draw_cursor( c )
	love.graphics.pop()

	self:draw_hud( c )
end

function format_score( value, level )
	if value <= 0 then
		return ( level and "" or "0" )
	end

	local s = format_score( math.floor( value/1000 ), level and (level+1) or 1 )
	if s == "" then
		return string.format( "%d", value % 1000 )
	end
	return s .. "," .. string.format( "%03d", value % 1000 )
end

function Skin:draw_hud( c )
	love.graphics.setFont( self.font )
	love.graphics.setColor( 240, 240, 240, 255 )

	local left = c.right
	local width = c.width - c.right
	local top = 50
	local height = self.fontsize

	love.graphics.printf( "SCORE", left, top, width, "center" )

	local score = format_score( c.game.score:value() )

	love.graphics.printf( score, left, top + height, width, "right" )

	local line = 0
	for i=#self.scores,1,-1 do
		love.graphics.setColor( 255, 255, 255, 255 * self.scores[i].time )

		love.graphics.printf(
				format_score( self.scores[i].value ),
				left,
				top + 2 * height + height * ( self.scores[i].time),
				width, "right" )

		line = line + 1 
	end
end

function Skin:draw_cubes( c )
	love.graphics.push()

	local mysize = c.blocksize - 2 * c.blockmargin

	for x=1,(c.size) do
		for y=1,(c.size) do
			local gem = c.game:get( {x=x, y=y} )

			if gem and gem.id > 0 then
				local color = self.colors[ gem.id ]
				color[4] = (gem.clear == 0) and 255 or (255 * gem.clear)
				love.graphics.setColor( color )

				love.graphics.rectangle(
						"fill",
						(x - 1 + gem.dx) * c.blocksize + c.left + c.blockmargin,
						(y - 1 - gem.dy) * c.blocksize + c.top  + c.blockmargin,
						mysize,
						mysize )
			end
		end
	end

	love.graphics.pop()
end

function Skin:draw_grid( c )
	local rgb = 255 * 0.7
	local alpha = 255 * 0.55

	love.graphics.setColor( 25, 25, 25, 200 )
	love.graphics.rectangle( 'fill', c.left, c.top, c.fieldsize, c.fieldsize )
	love.graphics.setColor( rgb, rgb, rgb, alpha )
	love.graphics.rectangle( 'fill', c.left, c.top, c.fieldsize, c.fieldsize )

	rgb = 255 * 0.8
	alpha = 255 * 0.75
	love.graphics.setColor( rgb, rgb, rgb, alpha )
	love.graphics.setLineWidth( 2 )

	for x=0, c.size do
		for y=0, c.size do
			x1 = c.left + ( x * c.blocksize )
			y1 = c.top  + ( y * c.blocksize )
			love.graphics.line( x1, c.top, x1, c.bottom )
			love.graphics.line( c.left, y1, c.right, y1 )
		end
	end
end

function Skin:draw_cursor( c )
	local left   = c.left + ( c.game.cursor.x - 1 ) * c.blocksize
	local top    = c.top  + ( c.game.cursor.y - 1 ) * c.blocksize
	local right  = left + c.blocksize
	local bottom = top + c.blocksize

	local pressed = c.game:is_cursor_pressed()

	love.graphics.setLineWidth( 6.0 )
	love.graphics.setColor( 255, 255, 255, pressed and 255 or 255 )

	if pressed then
		love.graphics.line(
			left,  top,
			left,  bottom,
			right, bottom,
			right, top,
			left,  top )
	else
		local length = 0.25 * c.blocksize
		love.graphics.line( left, top + length, left, top, left + length, top )
		love.graphics.line( right - length, top, right, top, right, top + length )
		love.graphics.line( right, bottom - length, right, bottom, right - length, bottom )
		love.graphics.line( left + length, bottom, left, bottom, left, bottom - length )
	end
end

