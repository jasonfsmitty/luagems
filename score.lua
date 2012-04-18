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

function Score:stop()
	local PointsPerGem = 100

	if #self.matches == 0 then
		self.wave = 0
	else
		-- iterate through each set of matches
		local matchSet = {}
		local matchTotal = 0
		for _,v in pairs( self.matches ) do
			for _,g in pairs( v ) do
				print( "Testing match item:", g )
				if not matchSet[g] then
					matchTotal = matchTotal + 1
					matchSet[ g ] = true
				end
			end
		end

		--local amount = ( self.wave * #self.matches * matchTotal ) * PointsPerGem
		local amount = math.pow( #self.matches * matchTotal, self.wave ) * PointsPerGem
		self.total = self.total + amount
		print( string.format( "Score: total=%u amount=%u wave=%u matches=%u gems=%u", self.total, amount, self.wave, #self.matches, matchTotal ) )

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


