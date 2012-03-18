------------------------------------------------------
-- gems: A simple bejeweled-style clone, used
--  as an exercise in learning lua
------------------------------------------------------

_paused = false

require "game"

function love.load()
	-- load resources, etc

	-- setup
	love.graphics.setBackgroundColor( 0, 0, 0 )
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

	-- todo
end

function love.draw()
	-- todo
	draw_field()
	love.graphics.print( "Hello World", 400, 300 )
end

