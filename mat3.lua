local fficlass = require('fficlass')

local mat3 = fficlass.new('typedef struct {float xx, yx, zx, xy, yy, zy, xz, yz, zz;} mat3;')

local new = mat3.new
local ctype = fficlass.CType
local cos = math.cos
local sin = math.sin
local log = math.log
local rand = math.random
local sqrt = math.sqrt

local hyp = 1.41421356
local tau = 6.28318530
local identity = new(1, 0, 0, 0, 1, 0, 0, 0, 1)

mat3.identity = identity

function mat3.inverse(a)
	local id = 1/(a.zx*(a.xy*a.yz - a.xz*a.yy) + a.zy*(a.xz*a.yx - a.xx*a.yz) + a.zz*(a.xx*a.yy - a.xy*a.yx))
	return new(id*(a.yy*a.zz - a.yz*a.zy), id*(a.yz*a.zx - a.yx*a.zz), id*(a.yx*a.zy - a.yy*a.zx), id*(a.xz*a.zy - a.xy*a.zz), id*(a.xx*a.zz - a.xz*a.zx), id*(a.xy*a.zx - a.xx*a.zy), id*(a.xy*a.yz - a.xz*a.yy), id*(a.xz*a.yx - a.xx*a.yz), id*(a.xx*a.yy - a.xy*a.yx))
end

function mat3:transpose() return new(self.xx, self.xy, self.xz, self.yx, self.yy, self.yz, self.zx, self.zy, self.zz) end
function mat3:det() return self.zx*(self.xy*self.yz - self.xz*self.yy) + self.zy*(self.xz*self.yx - self.xx*self.yz) + self.zz*(self.xx*self.yy - self.xy*self.yx) end
function mat3:trace() return self.xx + self.yy + self.zz end

function mat3.eulerAnglesYXZ(x, y, z)
	local cy, sy = cos(y), sin(y)
	local cx, sx = cos(x), sin(x)
	local cz, sz = cos(z), sin(z)
	return new(cy*cz + sx*sy*sz, cz*sx*sy - cy*sz, cx*sy, cx*sz, cx*cz, -sx, cy*sx*sz - cz*sy, cy*cz*sx + sy*sz, cx*cy)
end

function mat3.quat(q)
	local x, y, z, w = q:dumpH()
	return new(w*w + x*x - 1, x*y - z*w, x*z + y*w, x*y + z*w, w*w + y*y - 1, y*z - x*w, x*z - y*w, y*z + x*w, w*w + z*z - 1)
end

function mat3.look(a, b)
	--a and b should be vec3s
	local ax, ay, az = a:dump()
	local bx, by, bz = b:dump()
	local x = ay*bz - az*by
	local y = az*bx - ax*bz
	local z = ax*by - ay*bz
	local d = ax*bx + ay*by + az*bz
	local m = sqrt(d*d + x*x + y*y + z*z)
	local w = d + m
	local q = 1/(m*w)
	if q < 1e+12 then return new(q*(w*w + x*x) - 1, q*(x*y - z*w), q*(x*z + y*w), q*(x*y + z*w), q*(w*w + y*y) - 1, q*(y*z - x*w), q*(x*z - y*w), q*(y*z + x*w), q*(w*w + z*z) - 1) end
	return identity--FAIL
end

function mat3.axisAngle(v)
	local x, y, z = v:unit():dump()
	local m = v:magnitude()
	local c = cos(m)
	local s = sin(m)
	local t = 1 - c
	return new(t*x*x + c, t*x*y - z*s, t*x*z + y*s, t*x*y + z*s, t*y*y + c, t*y*z - x*s, t*x*z - y*s, t*y*z + x*s, t*z*z + c)
end

function mat3.rand()
	local l0 = log(1 - rand())
	local l1 = log(1 - rand())
	local a0 = tau*rand()
	local a1 = tau*rand()
	local m0 = hyp*sqrt(l0/(l0 + l1))
	local m1 = hyp*sqrt(l1/(l0 + l1))
	local x = m0*cos(a0)
	local y = m0*sin(a0)
	local z = m1*cos(a1)
	local w = m1*sin(a1)
	return new(w*w + x*x - 1, x*y - z*w, x*z + y*w, x*y + z*w, w*w + y*y - 1, y*z - x*w, x*z - y*w, y*z + x*w, w*w + z*z - 1)
end

function mat3.dump(a) return a.xx, a.yx, a.zx, a.xy, a.yy, a.zy, a.xz, a.yz, a.zz end
function mat3.__add(a, b) return new(a.xx + b.xx, a.yx + b.yx, a.zx + b.zx, a.xy + b.xy, a.yy + b.yy, a.zy + b.zy, a.xz + b.xz, a.yz + b.yz, a.zz + b.zz) end
function mat3.__sub(a, b) return new(a.xx - b.xx, a.yx - b.yx, a.zx - b.zx, a.xy - b.xy, a.yy - b.yy, a.zy - b.zy, a.xz - b.xz, a.yz - b.yz, a.zz - b.zz) end

function mat3.__mul(a, b)
	local atype = type(a)
	local btype = ctype(b)
	if atype == 'number' then
		return new(
			a*b.xx, a*b.yx, a*b.zx, 
			a*b.xy, a*b.yy, a*b.zy, 
			a*b.xz, a*b.yz, a*b.zz
		)
	else--mat3
		if btype == 'number' then
			return new(
				a.xx*b, a.yx*b, a.zx*b, 
				a.xy*b, a.yy*b, a.zy*b, 
				a.xz*b, a.yz*b, a.zz*b
			)
		elseif btype == 'vec3' then
			return b.new(
				a.xx*b.x + a.yx*b.y + a.zx*b.z, 
				a.xy*b.x + a.yy*b.y + a.zy*b.z, 
				a.xz*b.x + a.yz*b.y + a.zz*b.z
			)
		else--mat3
			return new(
				a.xx*b.xx + a.yx*b.xy + a.zx*b.xz, 
				a.xx*b.yx + a.yx*b.yy + a.zx*b.yz, 
				a.xx*b.zx + a.yx*b.zy + a.zx*b.zz, 
				a.xy*b.xx + a.yy*b.xy + a.zy*b.xz, 
				a.xy*b.yx + a.yy*b.yy + a.zy*b.yz, 
				a.xy*b.zx + a.yy*b.zy + a.zy*b.zz, 
				a.xz*b.xx + a.yz*b.xy + a.zz*b.xz, 
				a.xz*b.yx + a.yz*b.yy + a.zz*b.yz, 
				a.xz*b.zx + a.yz*b.zy + a.zz*b.zz
			)
		end
	end
end

function mat3.__div(a, b)
	b = 1/b--not really b anymore
	return new(a.xx*b, a.yx*b, a.zx*b, a.xy*b, a.yy*b, a.zy*b, a.xz*b, a.yz*b, a.zz*b)
end

function mat3:__unm() return new(-a.xx, -a.yx, -a.zx, -a.xy, -a.yy, -a.zy, -a.xz, -a.yz, -a.zz) end
function mat3:__tostring() return 'mat3('..self.xx..', '..self.yx..', '..self.zx..', '..self.xy..', '..self.yy..', '..self.zy..', '..self.xz..', '..self.yz..', '..self.zz..')' end

return mat3