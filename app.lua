
require "game"
require "skin"
require "title"
require "options"

beholder = require "beholder"

-- -----------------------------------------------------

App = {}

-- -----------------------------------------------------
-- common helpers

function handle_focus( app, f )
	if not app.paused then
		app.paused = not f
	end
end

-- -----------------------------------------------------
AppStates =
{
	-- -----------------------------------------------------
	title = {
		enter =
			function (app)
				print( "app=", app, " title=", app.title )
				app.title:enter( app )
			end,
		leave      = function (app)      app.title:leave( app ) end,
		focus      = handle_focus,
		update     = function (app, dt)  app.title:update( app, dt ) end,
		draw       = function (app)      app.title:draw( app ) end,
		keypressed = function (app, key) app.title:keypressed( app, key ) end,
	},

	-- -----------------------------------------------------
	options = {
		enter =
			function (app)
				app.options:enter( app )
			end,
		leave      = function (app)      app.options:leave( app ) end,
		focus      = handle_focus,
		update     = function (app, dt)  app.options:update( app, dt ) end,
		draw       = function (app)      app.options:draw( app ) end,
		keypressed = function (app, key) app.options:keypressed( app, key ) end,
	},

	-- -----------------------------------------------------
	game = {
		enter =
			function (app)
				app.game = Game:new( app.config )
				app.skin = Skin:new()
				app.skin:set_constants( app.game )
				beholder.trigger( "ENTER_GAME" )
			end,

		leave = function (app) beholder.trigger( "LEAVE_GAME" ) end,

		focus = handle_focus,

		keypressed =
			function (app, key)
				local keys = {}
				keys[ "escape" ] = function () app:goto( "title" ) end
				keys[ "left"   ] = function () app.game:move( "left" ) end
				keys[ "right"  ] = function () app.game:move( "right" ) end
				keys[ "up"     ] = function () app.game:move( "up" ) end
				keys[ "down"   ] = function () app.game:move( "down" ) end
				keys[ " "      ] = function () app.game:cursortoggle() end

				keys[ "w" ] = keys[ "up" ]
				keys[ "a" ] = keys[ "left" ]
				keys[ "s" ] = keys[ "down" ]
				keys[ "d" ] = keys[ "right" ]

				keys[ "q" ] = function () app.game:rotate( "left" ) end
				keys[ "e" ] = function () app.game:rotate( "right" ) end

				keys[ "f" ] = function () app.game:fill() end

				if keys[ key ] then
					keys[key]()
				end
			end,

		mousepressed =
			function (app, x, y, button )
				local ix, iy = app.skin:translate_mouse( x, y )
				app.game:mousepressed( ix, iy, button )
			end,

		mousereleased =
			function (app, x, y, button )
				local ix, iy = app.skin:translate_mouse( x, y )
				app.game:mousereleased( ix, iy, button )
			end,

		update =
			function (app, dt)
				if not app.paused then
					app.game:update( dt )
					app.skin:update( dt )
				end
			end,

		draw =
			function (app)
				app.skin:draw( app.game )
			end,
	},
}

-- -----------------------------------------------------

function App:new()
	local o = {}
	setmetatable( o, self )
	self.__index = self

	o.fontsize = 32
	o.font = love.graphics.newFont( "fonts/UbuntuMono-B.ttf", o.fontsize )
	print( "Created new title:", o )
	print( "    fontsize=", o.fontsize )
	print( "    font=", o.font )

	o.title = Title:new()
	print( "app=", o, " title=", o.title )

	o.options = Options:new()
	print( "app=", o, " options=", o.options )

	o:goto( "title" )

	o.config = {}
	o.config['easy'] = false

	o.dumpId = beholder.observe( "DUMP", function () o:dump() end )
	return o
end

function App:dump()
	local dmp = function (x) print( "    " .. x .. ":", self[x] ) end

	print( "Dumping App state:", self )
	for i,v in pairs( self ) do
		print( "    " .. i .. "\t= ", v )
	end
end

function App:goto( state )
	local newstate = AppStates[ state ]
	if not newstate then
		print( "ERROR: invalid app state '" .. state .. "'" )
	elseif self.state ~= newstate then
		print( "APP.state = " .. state )

		if self.state and self.state.leave then
			self.state.leave( self )
		end

		self.state = newstate
		self.statetime = 0
		self.statename = state

		if self.state.enter then
			self.state.enter( self )
		end
	end
end

function App:focus(f)
	if self.state and self.state.focus then
		self.state.focus( self, f )
	end
end

function App:keypressed( key )
	if self.state and self.state.keypressed then
		self.state.keypressed( self, key )
	end
end

function App:mousepressed( x, y, button )
	if self.state and self.state.mousepressed then
		self.state.mousepressed( self, x, y, button )
	end
end

function App:mousereleased( x, y, button )
	if self.state and self.state.mousereleased then
		self.state.mousereleased( self, x, y, button )
	end
end

function App:update( dt )
	self.statetime = self.statetime + dt
	self.state.update( self, dt )
end

function App:draw()
	self.state.draw( self )
end

