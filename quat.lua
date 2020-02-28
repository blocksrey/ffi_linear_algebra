local ffi = require("ffi")

local cos  = math.cos
local sin  = math.sin
local acos = math.acos
local rand = math.random
local ln   = math.log

--constants
local tau  = 2*math.pi

ffi.cdef([[
	typedef struct {
		float w, x, y, z;
	} quat;
]])

local function getctype(a)
	local atype = type(a)
	if atype == "cdata" then
		return a.type
	else
		return atype
	end
end

local quat = {}
local meta = {}
ffi.metatype("quat", meta)

local new = ffi.typeof("quat")

quat.type = "quat"
quat.new = new

meta.__index = quat

function quat.dump(q)
	return q.w, q.x, q.y, q.z
end

function quat.inverse(q)
	return new(q.w, -q.x, -q.y, -q.z)
end

function quat.__mul(a, b)
	return new(
		a.w*b.w - a.x*b.x - a.y*b.y - a.z*b.z,
		a.w*b.x + a.x*b.w + a.y*b.z - a.z*b.y,
		a.w*b.y - a.x*b.z + a.y*b.w + a.z*b.x,
		a.w*b.z + a.x*b.y - a.y*b.x + a.z*b.w
	)
end

function quat.__pow(q, n)
	local w, x, y, z = q.w, q.x, q.y, q.z
	local t = n*acos(w)
	local s = sin(t)/(x*x + y*y + z*z)^(1/2)
	return new(cos(t), s*x, s*y, s*z)
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
	local s = sin(t)/(x*x + y*y + z*z)^(1/2)

	local bw = cos(t)
	local bx = s*x
	local by = s*y
	local bz = s*z

	return new(
		aw*bw - ax*bx - ay*by - az*bz,
		aw*bx + ax*bw - ay*bz + az*by,
		aw*by + ax*bz + ay*bw - az*bx,
		aw*bz - ax*by + ay*bx + az*bw
	)
end

function quat.fromaxisangle(v)
	local x, y, z = v:dump()
	local l = (x*x + y*y + z*z)^(1/2)
	local x, y, z = x/l, y/l, z/l
	local s = sin(1/2*l)
	return new(cos(1/2*l), s*x, s*y, s*z)
end

function quat.fromeulerx(t)
	return new(cos(1/2*t), sin(1/2*t), 0, 0)
end

function quat.fromeulery(t)
	return new(cos(1/2*t), 0, sin(1/2*t), 0)
end

function quat.fromeulerz(t)
	return new(cos(1/2*t), 0, 0, sin(1/2*t))
end

function quat.frommat3(m)
	local xx, yx, zx, xy, yy, zy, xz, yz, zz = m:dump()
	if xx + yy + zz > 0 then
		local s = 2*(1 + xx + yy + zz)^(1/2)
		return new(1/4*s, (yz - zy)/s, (zx - xz)/s, (xy - yx)/s)
	elseif xx > yy and xx > zz then
		local s = 2*(1 + xx - yy - zz)^(1/2)
		return new((yz - zy)/s, 1/4*s, (yx + xy)/s, (zx + xz)/s)
	elseif yy > zz then
		local s = 2*(1 - xx + yy - zz)^(1/2)
		return new((zx - xz)/s, (yx + xy)/s, 1/4*s, (zy + yz)/s)
	else
		local s = 2*(1 - xx - yy + zz)^(1/2)
		return new((xy - yx)/s, (zx + xz)/s, (zy + yz)/s, 1/4*s)
	end
end

function quat.random()
	local l0 = ln(1 - rand())
	local l1 = ln(1 - rand())
	local a0 = tau*rand()
	local a1 = tau*rand()
	local m0 = (l0/(l0 + l1))^0.5
	local m1 = (l1/(l0 + l1))^0.5
	return new(
		m0*cos(a0),
		m0*sin(a0),
		m1*cos(a1),
		m1*sin(a1)
	)
end

function quat.look(a, b)
	--a and b should be vec3s
	local ax, ay, az = a:dump()
	local bx, by, bz = b:dump()
	local w = ax*bx + ay*by + az*bz
	local x = ay*bz - az*by
	local y = az*bx - ax*bz
	local z = ax*by - ay*bz
	local m = (w*w + x*x + y*y + z*z)^0.5
	local q = (2*m*(m + w))^0.5
	if q < 1e-6 then--FAIL
		return new(1, 0, 0, 0)
	else
		return new(
			(w + m)/q,
			x/q,
			y/q,
			z/q
		)
	end
end

quat.identity = new(1, 0, 0, 0)

return quat