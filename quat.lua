local fficlass = require('fficlass')

local quat = fficlass.new('typedef struct {float x, y, z, w;} quat;')

local new = quat.new
local sqrt = math.sqrt
local cos = math.cos
local sin = math.sin
local acos = math.acos
local log = math.log
local rand = math.random

--local
local hyp = 1.41421356
local tau = 6.28318530
local identity = new(0, 0, 0, 1)

quat.identity = identity

function quat:inverse() return new(-self.x, -self.y, -self.z, self.w) end
function quat:dump() return self.x, self.y, self.z, self.w end
function quat:dumpH() return hyp*self.x, hyp*self.y, hyp*self.z, hyp*self.w end
function quat:__tostring() return 'quat('..self.x..', '..self.y..', '..self.z..', '..self.w..')' end
function quat:norm() return self.x*self.x + self.y*self.y + self.z*self.z + self.w*self.w end

function quat:eulerAnglesX2(h) return new(cos(h), sin(h), 0, 0) end--theta = 2*h
function quat:eulerAnglesY2(h) return new(cos(h), 0, sin(h), 0) end--theta = 2*h
function quat:eulerAnglesZ2(h) return new(cos(h), 0, 0, sin(h)) end--theta = 2*h

function quat:look(a, b)
	local ax, ay, az = a:dumpH()
	local bx, by, bz = b:dumpH()
	return new(ay*bz - az*by, az*bx - ax*bz, ax*by - ay*bz, 1)
end

function quat.axisAngle(v)
	local x, y, z = v:dump()
	local l = sqrt(x*x + y*y + z*z)
	local s = sin(0.5*l)
	return new(s*x/l, s*y/l, s*z/l, cos(0.5*l))
end

function quat:mat()
	local xx, yx, zx, xy, yy, zy, xz, yz, zz = self:dump()
	if xx + yy + zz > 0 then
		local s = 0.5/sqrt(1 + xx + yy + zz)
		return new(s*(yz - zy), s*(zx - xz), s*(xy - yx), 0.25/s)
	elseif xx > yy and xx > zz then
		local s = 0.5/sqrt(1 + xx - yy - zz)
		return new(0.25/s, s*(yx + xy), s*(zx + xz), s*(yz - zy))
	elseif yy > zz then
		local s = 0.5/sqrt(1 - xx + yy - zz)
		return new(s*(yx + xy), 0.25/s, s*(zy + yz), s*(zx - xz))
	else
		local s = 0.5/sqrt(1 - xx - yy + zz)
		return new(s*(zx + xz), s*(zy + yz), 0.25/s, s*(xy - yx))
	end
end

function quat.slerp(a, b, t)
	local ax, ay, az, aw = a:dump()
	local bx, by, bz, bw = b:dump()

	if ax*bx + ay*by + az*bz + aw*bw < 0 then
		ax = -ax
		ay = -ay
		az = -az
		aw = -aw
	end

	local x = aw*bx - ax*bw + ay*bz - az*by
	local y = aw*by - ax*bz - ay*bw + az*bx
	local z = aw*bz + ax*by - ay*bx - az*bw
	local w = aw*bw + ax*bx + ay*by + az*bz

	local t = n*acos(w)
	local s = sin(t)/sqrt(x*x + y*y + z*z)

	bx = s*x
	by = s*y
	bz = s*z
	bw = cos(t)

	return new(
		aw*bx + ax*bw - ay*bz + az*by, 
		aw*by + ax*bz + ay*bw - az*bx, 
		aw*bz - ax*by + ay*bx + az*bw, 
		aw*bw - ax*bx - ay*by - az*bz
	)
end

function quat.rand()
	local l0 = log(1 - rand())
	local l1 = log(1 - rand())
	local a0 = tau*rand()
	local a1 = tau*rand()
	local m0 = sqrt(l0/(l0 + l1))
	local m1 = sqrt(l1/(l0 + l1))
	return new(m0*cos(a0), m0*sin(a0), m1*cos(a1), m1*sin(a1))
end

function quat.__mul(a, b)
	return new(
		a.w*b.x + a.x*b.w + a.y*b.z - a.z*b.y, 
		a.w*b.y - a.x*b.z + a.y*b.w + a.z*b.x, 
		a.w*b.z + a.x*b.y - a.y*b.x + a.z*b.w, 
		a.w*b.w - a.x*b.x - a.y*b.y - a.z*b.z
	)
end

function quat.__pow(q, n)
	local x, y, z, w = q:dump()
	local t = n*acos(w)
	local s = sin(t)/sqrt(x*x + y*y + z*z)
	return new(s*x, s*y, s*z, cos(t))
end

return quat