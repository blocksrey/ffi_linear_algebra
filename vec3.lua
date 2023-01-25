local fficlass = require('linearalgebra/fficlass')

local vec3 = fficlass.new('typedef struct {float x, y, z;} vec3;')

local new = vec3.new
local sqrt = math.sqrt

local null = new(0, 0, 0)

vec3.null = null

function vec3:square() return self.x*self.x + self.y*self.y + self.z*self.z end
function vec3:norm() return sqrt(self.x*self.x + self.y*self.y + self.z*self.z) end--magnitude of vector
function vec3:dump() return self.x, self.y, self.z end
function vec3:__unm() return new(-self.x, -self.y, -self.z) end
function vec3:__tostring() return 'vec3('..self.x..', '..self.y..', '..self.z..')' end

function vec3.dot(a, b) return a.x*b.x + a.y*b.y + a.z*b.z end
function vec3.cross(a, b) return new(a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x) end
function vec3.__div(a, b) return new(a.x/b, a.y/b, a.z/b) end
function vec3.__add(a, b) return new(a.x + b.x, a.y + b.y, a.z + b.z) end
function vec3.__sub(a, b) return new(a.x - b.x, a.y - b.y, a.z - b.z) end

--unitize assuming norm > 0
function vec3:pUnit()
	local l = sqrt(self.x*self.x + self.y*self.y + self.z*self.z)
	return new(self.x/l, self.y/l, self.z/l)
end

--unitize no assumptions
function vec3:unit()
	local l = sqrt(self.x*self.x + self.y*self.y + self.z*self.z)
	if l > 0 then return new(self.x/l, self.y/l, self.z/l) end
	return null
end

function vec3.quat(v, q)
	local i, j, k = v:dump()
	local x, y, z, w = q:dumpH()
	return new(
		i*(1 - y*y - z*z) + j*(x*y - w*z) + k*(x*z + w*y), 
		i*(x*y + w*z) + j*(1 - x*x - z*z) + k*(y*z - w*x), 
		i*(x*z - w*y) + j*(y*z + w*x) + k*(1 - x*x - y*y)
	)
end

function vec3.quatI(v, q)
	local i, j, k = v:dump()
	local x, y, z, w = q:dumpH()
	return new(
		i*(1 - y*y - z*z) + j*(x*y + w*z) + k*(x*z - w*y), 
		i*(x*y - w*z) + j*(1 - x*x - z*z) + k*(y*z + w*x), 
		i*(x*z + w*y) + j*(y*z - w*x) + k*(1 - x*x - y*y)
	)
end

function vec3.__mul(a, b)
	if type(a) == 'number' then
		return new(a*b.x, a*b.y, a*b.z)
	elseif type(b) == 'cdata' then
		return new(a.x*b.x, a.y*b.y, a.z*b.z)
	else
		return new(
			a.xx*b.x + a.yx*b.y + a.zx*b.z, 
			a.xy*b.x + a.yy*b.y + a.zy*b.z, 
			a.xz*b.x + a.yz*b.y + a.zz*b.z
		)
	end
end

return vec3