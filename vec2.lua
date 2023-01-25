local fficlass = require('linearalgebra/fficlass')

local vec2 = fficlass.new('typedef struct {float x, y;} vec2;')

local new = vec2.new
local sqrt = math.sqrt
local cos = math.cos
local sin = math.sin

local null = new(0, 0)

vec2.null = null

function vec2.dot(a, b) return a.x*b.x + a.y*b.y end
function vec2.cmul(a, b) return new(a.x*b.x - a.y*b.y, a.y*b.x + a.x*b.y) end--complex multiply
function vec2.cang(t) return new(cos(t), sin(t)) end--complex angle

function vec2.__add(a, b) return new(a.x + b.x, a.y + b.y) end
function vec2.__sub(a, b) return new(a.x - b.x, a.y - b.y) end
function vec2.__div(a, b) return new(a.x/b, a.y/b) end

function vec2.__mul(a, b)
	if type(a) == 'number' then return new(a*b.x, a*b.y) end
	return new(a.xx*b.x + a.yx*b.y, a.xy*b.x + a.yy*b.y)
end

function vec2:square() return self.x*self.x + self.y*self.y end
function vec2:norm() return sqrt(self.x*self.x + self.y*self.y) end
function vec2:perp() return new(self.x, -self.y) end
function vec2:dump() return self.x, self.y end
function vec2:__unm() return new(-self.x, -self.y) end
function vec2:__tostring() return 'vec2('..self.x..', '..self.y..')' end

function vec2:pUnit()
	local l = sqrt(self.x*self.x + self.y*self.y)
	return new(self.x/l, self.y/l)
end

function vec2:unit()
	local l = sqrt(self.x*self.x + self.y*self.y)
	if l > 0 then return new(self.x/l, self.y/l) end
	return null
end

return vec2