Title = {}

function Title:new()
	local o = {}
	setmetatable( o, self )
	self.__index = self

	o.current = 1
	o.menu = {}
	o.menu[1] = { title="New Game", action = function(app) app:goto( "game" ) end }
	o.menu[2] = { title="Options",  action = function(app) app:goto( "options" ) end }
	o.menu[3] = { title="Exit",     action = function(app) love.event.quit() end }
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
	love.graphics.setFont( app.font )
	love.graphics.setColor( 200, 200, 255, 180 )

	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	love.graphics.printf( "Lua Gems", 0, height - app.fontsize, width, "right" )

	local line = 0
	for i=1,#self.menu do
		if i == self.current then
			love.graphics.setColor( 255, 255, 255, 250 )
		else
			love.graphics.setColor( 125, 125, 125, 250 )
		end
		love.graphics.printf( self.menu[i].title, 0, height / 2 + (line * app.fontsize), width, "center" )
		line = line + 1
	end
end

function Title:keypressed( app, key )
	if key == "down" then
		if self.current < #self.menu then
			self.current = self.current + 1
		end
	elseif key == "up" then
		if self.current > 1 then
			self.current = self.current - 1
		end
	elseif key == "return" then
		local item = self.menu[ self.current ]
		if item and item.action then
			item.action( app )
		end
	elseif key == "escape" then
		love.event.quit()
	end
end


