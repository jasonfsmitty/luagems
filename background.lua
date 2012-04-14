require "game"

BlankBackground = {
	enter  = nil,
	leave  = nil,
	update = function ( bg, dt ) end,
	draw   = function ( bg ) end,
}

function onScreen( x, y, w, h, margin )
	return ( x >= -margin ) and ( x <= w + margin )
		and ( y >= -margin ) and ( y <= h + margin )
end

RandomFalling = {
	newblock = function (bg, init)
			local b = {}
			b.size = math.random( 30, 80 )
			b.id = math.random( 1, 7 )
			b.x = math.random( 0 - b.size, bg.width + b.size )
			b.vx = 0
			if init then
				b.y = math.random( -b.size, bg.width + b.size )
			else
				b.y = -b.size
			end
			b.vy = math.random( 25, 250 )
			b.spin = math.random( 0.1, 2*math.pi)
			b.vspin = math.random( -math.pi, math.pi )
			return b
		end,

	enter = function (bg)
			print( "Starting RandomFalling" )
			bg.blocks = {}
			bg.width = love.graphics.getWidth()
			bg.height = love.graphics.getHeight()
			for i=1,250 do
				bg.blocks[ i ] = bg:newblock( true )
			end
		end,

	leave = function (bg)
			bg.blocks = nil
		end,

	update = function (bg, dt)
			local width = love.graphics.getWidth()
			local height = love.graphics.getHeight()

			for i,k in ipairs( bg.blocks ) do
				local block = bg.blocks[i]
				block.x = block.x + block.vx * dt
				block.y = block.y + block.vy * dt
				block.spin = block.spin + block.vspin * dt

				if not onScreen( block.x, block.y, width, height, block.size ) then
					bg.blocks[i] = bg:newblock()
				end
			end
		end,

	draw = function (bg)
			for i,k in ipairs( bg.blocks ) do
				local block = bg.blocks[ i ]
				local s = block.size / 2
				love.graphics.push()
					love.graphics.setColor( 0, 128, 135, 100 )
					love.graphics.translate( s + block.x, s + block.y )
					love.graphics.rotate( block.spin )
					love.graphics.translate( -(s + block.x), -(s + block.y) )
					love.graphics.rectangle( "fill", block.x, block.y, block.size, block.size )
					--love.graphics.rectangle( "fill", 0, 0, block.size, block.size )
				love.graphics.pop()
			end
		end,
}

function randomColor()
	return {
		math.random( 50, 255 ),
		math.random( 50, 255 ),
		math.random( 50, 255 ),
		255 }
end

function randomSpeed()
	return math.random() * 5 + 0.5
end

local Grid = {
	enter =
		function (bg)
			bg.width = love.graphics.getWidth()
			bg.height = love.graphics.getHeight()

			bg.margin = 0.10 -- precentage
			bg.gridsize = 60
			bg.blockmargin = (bg.margin * bg.gridsize)
			bg.blocksize = bg.gridsize - 2 * bg.blockmargin

			bg.cols = math.ceil( bg.width / bg.gridsize ) + 1
			bg.rows = math.ceil( bg.height / bg.gridsize ) + 1

			bg.gridwidth = bg.cols * bg.gridsize
			bg.gridheight = bg.rows * bg.gridsize

			bg.vx = 25
			bg.vy = 20

			bg.blocks = {}
			local shift = math.random( -bg.blocksize/2, bg.blocksize )
			for x=1,bg.cols do
				for y=1,bg.rows do
					local b = {}
					b.x = ((x-1) * bg.gridsize + bg.blockmargin) + shift
					b.y = ((y-1) * bg.gridsize + bg.blockmargin) + shift
					b.alpha = 0
					b.speed = randomSpeed()
					b.state = "in"
					b.color = randomColor()
					bg.blocks[ #bg.blocks + 1 ] = b
				end
			end
			print( "Created Grid   : ", bg )
			print( "   Grid.blocks : ", bg.blocks )
		end,

	update =
		function (bg, dt)
			local dx = bg.vx * dt
			local dy = bg.vy * dt
			for i,k in ipairs( bg.blocks ) do
				local b = bg.blocks[ i ]
				b.x = b.x + dx
				if b.x > bg.width then
					b.x = b.x - bg.gridwidth
				end
				b.y = b.y + dy
				if b.y > bg.height then
					b.y = b.y - bg.gridheight
				end
				if b.state == "in" then
					b.alpha = b.alpha + (dt * b.speed)
					if b.alpha >= 1.0 then
						b.state = "out"
						b.alpha = 1
					end
				elseif b.state == "out" then
					b.alpha = b.alpha - (dt * b.speed)
					if b.alpha <= 0 then
						b.state = "in"
						b.alpha = 0
						b.color = randomColor()
						b.speed = randomSpeed()
					end
				end
			end
		end,

	draw =
		function (bg)
			for i,k in ipairs( bg.blocks ) do
				local b = bg.blocks[ i ]
				b.color[4] = 255 * b.alpha
				love.graphics.setColor( b.color )
				love.graphics.rectangle( "fill", b.x, b.y, bg.blocksize, bg.blocksize )
			end
		end,
}


local _next = 1

local _backgrounds = {
	Grid,
	RandomFalling,
	--BlankBackground,
}

function getBackground( idx )
	return Grid
	-- return _backgrounds[ math.random( 1, #_backgrounds ) ]
end

