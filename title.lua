Title = {}

function Title:new()
	local o = {}
	setmetatable( o, self )
	self.__index = self

	o.fontsize = 32
	o.font = love.graphics.newFont( self.fontsize )
	print( "Created new title:", o )
	print( "    fontsize=", o.fontsize )
	print( "    font=", o.font )

	o.testfont = love.graphics.newFont( "fonts/CPMono_v07_Black.otf", 24 )
	print( "Test font: ", o.testfont )
	return o
end

function Title:enter()
	-- pass
end

function Title:leave()
	-- pass
end

function Title:update( app, dt )
	-- pass
end

function Title:draw( app )
	love.graphics.setFont( self.font )
	love.graphics.setColor( 150, 180, 255, 180 )

	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()

	love.graphics.printf( "Lua Gems", 0, height - self.fontsize, width, "right" )


	love.graphics.setFont( self.testfont )
	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.print( "Testing custom fonts!", 20, 20 )
end

function Title:keypressed( app, key )
	if key == "return" then
		app:goto( "game" )
	elseif key == "escape" then
		love.event.quit()
	end
end


