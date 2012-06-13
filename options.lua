Options = {}

function Options:new()
	local o = {}
	setmetatable( o, self )
	self.__index = self

	self.current = 1
	self.items = {}
	
	self.items[ #self.items + 1 ] = {
		keypressed = function (app) end,
		draw = function(app, ypos, width)
				love.graphics.printf( "TODO", 0, ypos, width, "center" )
			end,
	}

	self.items[ #self.items + 1 ] = {

		toggle = function( app )
				if app.config[ 'easy' ] then
					app.config[ 'easy' ] = false
				else
					app.config[ 'easy' ] = true
				end
			print( "toggled easy config: ", app.config['easy'] )
		end,

		keypressed = function (self, app, key)
				local keys = {}
				keys['return'] = self.toggle
				keys['right'] = self.toggle
				keys['left'] = self.toggle

				print( "got key press: ", key, keys[key] )
				if keys[key] then
					keys[key]( app )
				end
			end,

		draw = function(app, ypos, width)
				local s = string.format( "Easy Mode: %s", ( app.config['easy'] and "on" or "off" ) )
				love.graphics.printf( s, 0, ypos, width, "center" )
			end,
	}

	return o
end

function Options:enter()
	-- pass
end

function Options:leave()
	-- pass
end

function Options:update( app, dt )
	-- pass
end

function Options:draw( app )
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()

	love.graphics.setFont( app.font )
	love.graphics.setColor( 200, 200, 255, 180 )

	local ypos = 2 * app.fontsize
	love.graphics.printf( "Options", 0, ypos, width, "center" )

	for i=1,#self.items do
		if i == self.current then
			love.graphics.setColor( 255, 255, 255, 250 )
		else
			love.graphics.setColor( 125, 125, 125, 250 )
		end
		self.items[ i ].draw( app, ypos + i * app.fontsize, width )
	end
end

function Options:keypressed( app, key )
	if key == "down" then
		if self.current < #self.items then
			self.current = self.current + 1
		end
	elseif key == "up" then
		if self.current > 1 then
			self.current = self.current - 1
		end
	elseif key == "escape" then
		app:goto( "title" )
	else
		local item = self.items[ self.current ]
		if item and item.keypressed then
			print( "passing on key press ..." )
			item:keypressed( app, key )
		end
	end
end
