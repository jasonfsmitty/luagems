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

	_game = Game:new()
	_skin = Skin:new()
end

function love.focus(f)
	if not _paused then
		_paused = not f
	end
end

function love.keypressed( key )
	if key == "escape" then
		love.event.quit()
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
	love.graphics.print( "Hello World", 400, 300 )
end

