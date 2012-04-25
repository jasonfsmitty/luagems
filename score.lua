beholder = require "beholder"

Score = {}

function Score:new()
	local o = {}
	o.total = 0
	o.wave = 0
	o.matches = {}

	setmetatable( o, self )
	self.__index = self
	return o
end

function Score:value()
	return self.total
end

function Score:reset()
	self.total = 0
	self.wave = 0
	self.matches = {}
end

function Score:start()
	self.wave = self.wave + 1
	self.matches = {}
end

--[[
	Calculating scores ...

	Examples:
	  clear[3]x1  -   250
	  clear[4]x1  -  2500
	  clear[5]x1  - 25000

	  clear[3]x2  -  5000
	  clear[4]x2  - 50000

]]

function Score:stop( missing )
	local PointsPerGem = 100

	if #self.matches == 0 then
		self.wave = 0
	else
		-- iterate through each set of matches
		local matchSet = {}
		local totalCleared = 0
		local v, g

		for _,v in pairs( self.matches ) do
			for _,g in pairs( v ) do
				print( "Testing match item:", g )
				if not matchSet[g] then
					totalCleared = totalCleared + 1
					matchSet[ g ] = true
				end
			end
		end

		if totalCleared < 3 then
			totalCleared = 3
		end
	
		--local amount = ( self.wave * #self.matches * totalCleared ) * PointsPerGem
		--local amount = math.pow( #self.matches * totalCleared, self.wave ) * PointsPerGem
		--local amount = math.pow( self.wave + 1, totalCleared ) * 250
		--local amount = ( 250 * self.wave ) * totalCleared * totalCleared * ( self.wave * 10 )
		local amount = 1250 * self.wave * ( missing + 1 ) * totalCleared * totalCleared
		self.total = self.total + amount
		print( string.format( "Score: total=%u amount=%u wave=%u matches=%u gems=%u", self.total, amount, self.wave, #self.matches, totalCleared ) )

		beholder.trigger( "SCORE", amount )
		self.matches = {}
	end
end

function Score:add( matches )
	self.matches[ #self.matches + 1 ] = matches
end

function Score:idle()
	self.matches = {}
	self.wave = 0
end

-- --------------------------------------------
Scorer = {}

function Scorer:new( score )
	o = { score=score }
	o.matches = {}
	setmetatable( o, self )
	self.__index = self
	return o
end

function Scorer:add( gem )
	if gem and (gem.id > 0) then
		self.matches[ #self.matches + 1 ] = gem
	end
end

function Scorer:flush()
	if #self.matches > 0 then
		self.score:add( self.matches )
		self.matches = {}
	end
end


