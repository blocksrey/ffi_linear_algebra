local fficlass = require("fficlass")

local quat, meta = fficlass.new("typedef struct {float w, x, y, z;} quat;")

local new = quat.new
local sqrt = math.sqrt
local cos = math.cos
local sin = math.sin
local acos = math.acos
local log = math.log
local rand = math.random

local hyp = 1.41421356237
local tau = 6.28318530718
local identity = new(1, 0, 0, 0)

quat.identity = identity

function quat.inv(q)
	return new(q.w, -q.x, -q.y, -q.z)
end

function quat.slerp(a, b, t)
	local aw, ax, ay, az = a:dump()
	local bw, bx, by, bz = b:dump()

	if aw*bw + ax*bx + ay*by + az*bz < 0 then
		aw = -aw
		ax = -ax
		ay = -ay
		az = -az
	end

	local w = aw*bw + ax*bx + ay*by + az*bz
	local x = aw*bx - ax*bw + ay*bz - az*by
	local y = aw*by - ax*bz - ay*bw + az*bx
	local z = aw*bz + ax*by - ay*bx - az*bw

	local t = n*acos(w)
	local s = sin(t)/sqrt(x*x + y*y + z*z)

	bw = cos(t)
	bx = s*x
	by = s*y
	bz = s*z

	return new(
		aw*bw - ax*bx - ay*by - az*bz,
		aw*bx + ax*bw - ay*bz + az*by,
		aw*by + ax*bz + ay*bw - az*bx,
		aw*bz - ax*by + ay*bx + az*bw
	)
end

function quat.eulerAnglesX2(t)--real theta = 2*t
	return new(cos(t), sin(t), 0, 0)
end

function quat.eulerAnglesY2(t)--real theta = 2*t
	return new(cos(t), 0, sin(t), 0)
end

function quat.eulerAnglesZ2(t)--real theta = 2*t
	return new(cos(t), 0, 0, sin(t))
end

function quat.mat(m)
	local xx, yx, zx, xy, yy, zy, xz, yz, zz = m:dump()
	if xx + yy + zz > 0 then
		local s = 0.5/sqrt(1 + xx + yy + zz)
		return new(0.25/s, s*(yz - zy), s*(zx - xz), s*(xy - yx))
	elseif xx > yy and xx > zz then
		local s = 0.5/sqrt(1 + xx - yy - zz)
		return new(s*(yz - zy), 0.25/s, s*(yx + xy), s*(zx + xz))
	elseif yy > zz then
		local s = 0.5/sqrt(1 - xx + yy - zz)
		return new(s*(zx - xz), s*(yx + xy), 0.25/s, s*(zy + yz))
	else
		local s = 0.5/sqrt(1 - xx - yy + zz)
		return new(s*(xy - yx), s*(zx + xz), s*(zy + yz), 0.25/s)
	end
end

--[[
function quat.look(a, b)
	--a and b should be vec3s
	local ax, ay, az = a:dump()
	local bx, by, bz = b:dump()
	local w = ax*bx + ay*by + az*bz
	local x = ay*bz - az*by
	local y = az*bx - ax*bz
	local z = ax*by - ay*bz
	local m = sqrt(w*w + x*x + y*y + z*z)
	local q = 1/sqrt(2*m*(m + w))
	if q < 1e+6 then
		return new(
			q*(w + m),
			q*x,
			q*y,
			q*z
		)
	end
	return identity--FAIL
end
]]

function quat.look(a, b)
	local ax, ay, az = a:dump()
	local bx, by, bz = b:dump()
	return new(
		DIA,
		DIA*(ay*bz - az*by),
		DIA*(az*bx - ax*bz),
		DIA*(ax*by - ay*bz)
	)
end

function quat.axisAngle(v)
	local x, y, z = v:dump()
	local l = sqrt(x*x + y*y + z*z)
	local s = sin(0.5*l)
	return new(cos(0.5*l), s*x/l, s*y/l, s*z/l)
end

function quat.rand()
	local l0 = log(1 - rand())
	local l1 = log(1 - rand())
	local a0 = tau*rand()
	local a1 = tau*rand()
	local m0 = sqrt(l0/(l0 + l1))
	local m1 = sqrt(l1/(l0 + l1))
	return new(
		m0*cos(a0),
		m0*sin(a0),
		m1*cos(a1),
		m1*sin(a1)
	)
end

function quat.dump(q)
	return q.w, q.x, q.y, q.z
end

function quat.dumpH(q)
	return hyp*q.w, hyp*q.x, hyp*q.y, hyp*q.z
end

function meta.__mul(a, b)
	return new(
		a.w*b.w - a.x*b.x - a.y*b.y - a.z*b.z,
		a.w*b.x + a.x*b.w + a.y*b.z - a.z*b.y,
		a.w*b.y - a.x*b.z + a.y*b.w + a.z*b.x,
		a.w*b.z + a.x*b.y - a.y*b.x + a.z*b.w
	)
end

function meta.__pow(q, n)
	local w, x, y, z = q:dump()
	local t = n*acos(w)
	local s = sin(t)/sqrt(x*x + y*y + z*z)
	return new(cos(t), s*x, s*y, s*z)
end

function meta.__tostring(a)
	return "quat("..a.w..", "..a.x..", "..a.y..", "..a.z..")"
end

return quat
