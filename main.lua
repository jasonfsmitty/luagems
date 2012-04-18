------------------------------------------------------
-- gems: A simple bejeweled-style clone, used
--  as an exercise in learning lua
------------------------------------------------------

require "app"
require "background"

-- -----------------------------------------------------

local workers = {}

-- -----------------------------------------------------

function love.load()
	-- load resources, etc
	math.randomseed( os.time() )

	-- setup
	love.graphics.setBackgroundColor( 0, 0, 0 )

	workers['app'] = App:new()
	workers['background'] = getBackground()
end

function love.focus(f)
	for _,worker in pairs( workers ) do
		if worker.focus then
			worker:focus( f )
		end
	end
end

function love.keypressed( key )
	for _,worker in pairs( workers ) do
		if worker.keypressed then
			worker:keypressed( key )
		end
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
		-- _app.paused = false
	end
end

function love.update( dt )
	for _,worker in pairs( workers ) do
		if worker.update then
			worker:update( dt )
		end
	end
end

function love.draw()
	-- order matters, so we must call manually
	workers['background']:draw()
	workers['app']:draw()
end

