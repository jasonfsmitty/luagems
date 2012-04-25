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
end

function Title:keypressed( app, key )
	if key == "return" then
		app:goto( "game" )
	elseif key == "escape" then
		love.event.quit()
	end
end


