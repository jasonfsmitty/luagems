-------------------------------------------------
-- game stuff for luagems
-------------------------------------------------

_size = 7
_colors = {
	{ 255,   0,   0, 255 }, -- 1
	{ 0,   255,   0, 255 }, -- 2
	{ 0,     0, 255, 255 }, -- 3
	{ 255, 255,   0, 255 }, -- 4
	{ 255,   0, 255, 255 }, -- 5
	{ 0,   255, 255, 255 }, -- 6
	{ 255, 255, 255, 255 }, -- 7
}

function draw_field()
	-- constants
	screensize  = math.min( love.graphics.getWidth(), love.graphics.getHeight() )
	margin      = 0.10 -- percentage
	shift       = screensize * margin
	fieldsize   = screensize - ( 2 * shift )
	blocksize   = fieldsize / _size
	blockmargin = blocksize * 0.10

	draw_grid()
	draw_cubes()
	draw_cursor()
end

function draw_grid()
	left = shift
	right = shift + fieldsize
	top = left
	bottom = right

	rgb = 255 * 0.8
	alpha = 255 * 0.75

	love.graphics.setLineWidth( 2 )
	love.graphics.setColor( rgb, rgb, rgb, alpha )
	for x=0, _size do
		for y=0, _size do
			x1 = left + ( x * blocksize )
			y1 = top  + ( y * blocksize )
			love.graphics.line( x1, top, x1, bottom )
			love.graphics.line( left, y1, right, y1 )
		end
	end
end

function draw_cubes()
	mysize = blocksize - 2 * blockmargin
	for x=0,(_size-1) do
		for y=0,(_size-1) do
			love.graphics.setColor( _colors[ (x+y) % #_colors + 1 ] )
			love.graphics.rectangle(
					"fill",
					(x*blocksize)+shift + blockmargin,
					(y*blocksize)+shift + blockmargin,
					mysize,
					mysize )
		end
	end
end

function draw_cursor()
	length = pressed and 1.0 or 0.25
	alpha  = pressed and 1.0 or 0.50

	love.graphics.setLineWidth( 5.0 )
	love.graphics.setColor( 1, 1, 1, alpha )

	-- TODO
end

