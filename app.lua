
require "game"
require "skin"
require "title"

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
	init = {
		enter  = nil,
		focus  = handle_focus,
		update = function (app, dt) app:goto( "title" ) end,
		draw   = nil,
	},

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
	game = {
		enter =
			function (app)
				app.game = Game:new()
				app.skin = Skin:new()
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

	o.title = Title:new()
	print( "app=", o, " title=", o.title )
	o:goto( "init" )
	return o
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

function App:update( dt )
	self.state.update( self, dt )
end

function App:draw()
	self.state.draw( self )
end

