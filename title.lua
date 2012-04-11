
Title = {}

function Title:new()
	o = {}
	setmetatable( o, self )
	self.__index = self

	return o
end

function Title:enter( app )
	if not self.font then
		self.fontsize = love.graphics.getHeight() / 5
		self.font = love.graphics.newFont( self.fontsize )
	end
end

function Title:update( app, dt )
	-- pass
end

function Title:draw( app )
	love.graphics.setFont( self.font )
	love.graphics.setColor( 150, 180, 255, 180 )

	local width = love.graphics.getWidth()
	love.graphics.printf( "Lua Gems", 0, self.fontsize, width, "center" )
	-- love.graphics.print( "Lua Gems", 25, self.fontsize * 2 )
end

function Title:keypressed( app, key )
	if key == "return" then
		app:goto( "game" )
	elseif key == "escape" then
		love.event.quit()
	end
end
