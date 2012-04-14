require "background"

Title = {}

function Title:new()
	o = {}
	setmetatable( o, self )
	self.__index = self
	return o
end

function Title:enter( app )
	if not self.font then
		self.fontsize = 32
		self.font = love.graphics.newFont( self.fontsize )
	end

	self.background = getBackground()
	if self.background then
		self.background:enter()
	else
		print( "No background created!!" )
	end
end

function Title:leave( app )
	if self.background and self.background.leave then
		self.background:leave()
	end

	self.background = nil
end

function Title:update( app, dt )
	if self.background and self.background.update then
		self.background:update( dt )
	end
end

function Title:draw( app )
	if self.background and self.background.draw then
		self.background:draw()
	else
		-- print( "No background" )
	end

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
	elseif self.background and self.background.keypressed then
		self.background:keypressed( key )
	end
end


