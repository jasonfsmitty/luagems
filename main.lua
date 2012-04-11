------------------------------------------------------
-- gems: A simple bejeweled-style clone, used
--  as an exercise in learning lua
------------------------------------------------------

require "game"
require "skin"
require "title"

App = {}

local _app = nil

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
		enter =
			function (app)
				app.title = Title:new()
			end,

		focus  = handle_focus,
		update = function (app, dt) app:goto( "title" ) end,
		draw   = nil,
	},

	-- -----------------------------------------------------
	title = {
		enter      = function (app)      app.title:enter( app ) end,
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
			end,

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
				app.skin.draw( app.skin, app.game )
			end,
	},
}

-- -----------------------------------------------------

function App:new()
	o = {}
	setmetatable( o, self )
	self.__index = self

	return o
end

function App:goto( state )
	newstate = AppStates[ state ]
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

-- -----------------------------------------------------

function love.load()
	-- load resources, etc

	-- setup
	love.graphics.setBackgroundColor( 0, 0, 0 )

	_app = App:new()
	_app:goto( "init" )
end

function love.focus(f)
	if _app.state.focus then
		_app.state.focus( _app, f )
	end
end

function love.keypressed( key )
	if _app.state.keypressed then
		_app.state.keypressed( _app, key )
	end
end

function love.update( dt )
	_app.statetime = _app.statetime + dt

	if _app.state.update then
		_app.state.update( _app, dt )
	end
end

function love.draw()
	if _app.state.draw then
		_app.state.draw( _app )
	end
end

function love.joystickpressed( joy, but )
	local name = love.joystick.getName( 1 )
	print( "Press: name='" .. name .. " joy=" .. joy .. " button=" .. but )
end

function love.joystickreleased( joy, but )
	print( "Release: joy=" .. joy .. " button=" .. but )
end

function love.mousepressed( x, y, button )
	if button == "l" then
		_app.paused = false
	end
end

