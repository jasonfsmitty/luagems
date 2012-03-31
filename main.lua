------------------------------------------------------
-- gems: A simple bejeweled-style clone, used
--  as an exercise in learning lua
------------------------------------------------------

require "game2"
require "skin"

local _paused = false
local _game = nil
local _skin = nil

function love.load()
	-- load resources, etc

	-- setup
	love.graphics.setBackgroundColor( 0, 0, 0 )

	print( "Loading game and skin ..." )
	_game = Game:new()
	_skin = Skin:new()
end

function love.focus(f)
	if not _paused then
		_paused = not f
	end
end

function love.keypressed( key )
	local keys = {}
	keys[ "escape" ] = function () love.event.quit() end
	keys[ "left"   ] = function () _game:move( "left" ) end
	keys[ "right"  ] = function () _game:move( "right" ) end
	keys[ "up"     ] = function () _game:move( "up" ) end
	keys[ "down"   ] = function () _game:move( "down" ) end
	keys[ " "      ] = function () _game:cursortoggle() end

	if keys[ key ] then
		keys[key]()
	end
end

function love.mousepressed( x, y, button )
	if button == "l" then
		_paused = false
	end
end

function love.update(dt)
	if _paused then return end

	_game:update( dt )
	_skin:update( dt )
end

function love.draw()
	-- todo
	_skin:draw( _game )
end

