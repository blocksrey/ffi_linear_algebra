local ffi = require("ffi")

local rand = math.random
local cos = math.cos
local sin = math.sin
local tau = 2*math.pi
local ln = math.log

ffi.cdef([[
	typedef struct {
		float
			xx, yx, zx,
			xy, yy, zy,
			xz, yz, zz;
	} mat3;
]])

local function getctype(a)
	local atype = type(a)
	if atype == "cdata" then
		return a.type
	else
		return atype
	end
end

local mat3 = {}
local meta = {}
ffi.metatype("mat3", meta)

local new = ffi.typeof("mat3")
--[[local function new(xx, yx, zx, xy, yy, zy, xz, yz, zz)
	return ffi.new("mat3", xx, yx, zx, xy, yy, zy, xz, yz, zz)
end]]

mat3.type = "mat3"
mat3.new = new

meta.__index = mat3

function mat3.transpose(a)
	return new(
		a.xx, a.xy, a.xz,
		a.yx, a.yy, a.yz,
		a.zx, a.zy, a.zz
	)
end

function mat3.inverse(a)
	local det =
		a.zx*(a.xy*a.yz - a.xz*a.yy) +
		a.zy*(a.xz*a.yx - a.xx*a.yz) +
		a.zz*(a.xx*a.yy - a.xy*a.yx)
	return new(
		(a.yy*a.zz - a.yz*a.zy)/det,
		(a.yz*a.zx - a.yx*a.zz)/det,
		(a.yx*a.zy - a.yy*a.zx)/det,
		(a.xz*a.zy - a.xy*a.zz)/det,
		(a.xx*a.zz - a.xz*a.zx)/det,
		(a.xy*a.zx - a.xx*a.zy)/det,
		(a.xy*a.yz - a.xz*a.yy)/det,
		(a.xz*a.yx - a.xx*a.yz)/det,
		(a.xx*a.yy - a.xy*a.yx)/det
	)
end

function mat3.trace(a)
	return a.xx + a.yy + a.zz
end

function mat3.det(a)
	return
		a.zx*(a.xy*a.yz - a.xz*a.yy) +
		a.zy*(a.xz*a.yx - a.xx*a.yz) +
		a.zz*(a.xx*a.yy - a.xy*a.yx)
end

function mat3.dump(a)
	return
		a.xx, a.yx, a.zx,
		a.xy, a.yy, a.zy,
		a.xz, a.yz, a.zz
end

function mat3.fromeuleryxz(y, x, z)
	local cy, sy = cos(y), sin(y)
	local cx, sx = cos(x), sin(x)
	local cz, sz = cos(z), sin(z)
	return new(
		cy*cz + sx*sy*sz, cz*sx*sy - cy*sz, cx*sy,
		cx*sz,            cx*cz,            -sx,
		cy*sx*sz - cz*sy, cy*cz*sx + sy*sz, cx*cy
	)
end

function mat3.fromquat(q)
	local w, x, y, z = q:dump()
	local d = w*w + x*x + y*y + z*z
	return new(
		2*(w*w + x*x)/d - 1, 2*(x*y - z*w)/d,     2*(x*z + y*w)/d,
		2*(x*y + z*w)/d,     2*(w*w + y*y)/d - 1, 2*(y*z - x*w)/d,
		2*(x*z - y*w)/d,     2*(y*z + x*w)/d,     2*(w*w + z*z)/d - 1
	)
end

function mat3.random()
	local l0 = ln(1 - rand())
	local l1 = ln(1 - rand())
	local a0 = tau*rand()
	local a1 = tau*rand()
	local m0 = (l0/(l0 + l1))^0.5
	local m1 = (l1/(l0 + l1))^0.5
	local w = m0*cos(a0)
	local x = m0*sin(a0)
	local y = m1*cos(a1)
	local z = m1*sin(a1)
	return new(
		2*(w*w + x*x) - 1, 2*(x*y - z*w),     2*(x*z + y*w),
		2*(x*y + z*w),     2*(w*w + y*y) - 1, 2*(y*z - x*w),
		2*(x*z - y*w),     2*(y*z + x*w),     2*(w*w + z*z) - 1
	)
end

function mat3.look(a, b)
	--a and b should be vec3s
	local ax, ay, az = a:dump()
	local bx, by, bz = b:dump()
	local x = ay*bz - az*by
	local y = az*bx - ax*bz
	local z = ax*by - ay*bz
	local d = ax*bx + ay*by + az*bz
	local m = (d*d + x*x + y*y + z*z)^0.5
	local w = d + m
	local q = m*w
	if q < 1e-12 then--FAIL
		return new(
			1, 0, 0,
			0, 1, 0,
			0, 0, 1
		)
	else
		return new(
			(w*w + x*x)/q - 1, (x*y - z*w)/q,     (x*z + y*w)/q,
			(x*y + z*w)/q,     (w*w + y*y)/q - 1, (y*z - x*w)/q,
			(x*z - y*w)/q,     (y*z + x*w)/q,     (w*w + z*z)/q - 1
		)
	end
end

function mat3.fromaxisangle(aa)
	local x, y, z = aa:unit():dump()
	local m = aa:magnitude()
	local s = sin(m)
	local c = cos(m)
	local t = 1 - c
	return new(
		t*x*x + c  , t*x*y - z*s, t*x*z + y*s,
		t*x*y + z*s, t*y*y + c  , t*y*z - x*s,
		t*x*z - y*s, t*y*z + x*s, t*z*z + c  
	)
end

function meta.__tostring(a)
	return "mat3("..
		a.xx..", "..a.yx..", "..a.zx..", "..
		a.xy..", "..a.yy..", "..a.zy..", "..
		a.xz..", "..a.yz..", "..a.zz..")"
end

function meta.__unm(a)
	return new(
		-a.xx, -a.yx, -a.zx,
		-a.xy, -a.yy, -a.zy,
		-a.xz, -a.yz, -a.zz
	)
end

function meta.__add(a, b)
	return new(
		a.xx + b.xx, a.yx + b.yx, a.zx + b.zx,
		a.xy + b.xy, a.yy + b.yy, a.zy + b.zy,
		a.xz + b.xz, a.yz + b.yz, a.zz + b.zz
	)
end

function meta.__sub(a, b)
	return new(
		a.xx - b.xx, a.yx - b.yx, a.zx - b.zx,
		a.xy - b.xy, a.yy - b.yy, a.zy - b.zy,
		a.xz - b.xz, a.yz - b.yz, a.zz - b.zz
	)
end

function meta.__mul(a, b)
	local atype = getctype(a)
	local btype = getctype(b)
	if atype == "number" then
		return new(
			a*b.xx, a*b.yx, a*b.zx,
			a*b.xy, a*b.yy, a*b.zy,
			a*b.xz, a*b.yz, a*b.zz
		)
	else--mat3
		if btype == "number" then
			return new(
				a.xx*b, a.yx*b, a.zx*b,
				a.xy*b, a.yy*b, a.zy*b,
				a.xz*b, a.yz*b, a.zz*b
			)
		elseif btype == "vec3" then
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

function meta.__div(a, b)
	return new(
		a.xx/b, a.yx/b, a.zx/b,
		a.xy/b, a.yy/b, a.zy/b,
		a.xz/b, a.yz/b, a.zz/b
	)
end

mat3.identity = new(1, 0, 0, 0, 1, 0, 0, 0, 1)

return mat3

--[[
transpose(mat3)
inverse(mat3)
trace(mat3)
det(mat3)

mat3 + mat3

mat3*mat3
mat3*vec3
mat3*number
number*mat3

mat3/number

]]