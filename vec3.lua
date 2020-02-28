local ffi = require("ffi")

ffi.cdef([[
	typedef struct {
		float x, y, z;
	} vec3;
]])

local function getctype(a)
	local atype = type(a)
	if atype == "cdata" then
		return a.type
	else
		return atype
	end
end

local vec3 = {}
local meta = {}
ffi.metatype("vec3", meta)

local new = ffi.typeof("vec3")
--[[local function new(x, y, z)
	return ffi.new("vec3", x, y, z)
end]]

vec3.type = "vec3"
vec3.new = new

--FUNCTIONS
function vec3.dot(a, b)
	return a.x*b.x + a.y*b.y + a.z*b.z
end

function vec3.cross(a, b)
	return new(
		a.y*b.z - a.z*b.y,
		a.z*b.x - a.x*b.z,
		a.x*b.y - a.y*b.x
	)
end

function vec3.magnitude(a)
	return (a.x*a.x + a.y*a.y + a.z*a.z)^0.5
end

function vec3.unit(a)
	local l = (a.x*a.x + a.y*a.y + a.z*a.z)^0.5
	if l == 0 then
		return vec3.null
	else
		return new(a.x/l, a.y/l, a.z/l)
	end
end

function vec3.dump(a)
	return a.x, a.y, a.z
end

meta.__index = vec3

function meta.__tostring(a)
	return "vec3("..a.x..", "..a.y..", "..a.z..")"
end

function meta.__unm(a)
	return new(
		-a.x,
		-a.y,
		-a.z
	)
end

function meta.__add(a, b)
	return new(
		a.x + b.x,
		a.y + b.y,
		a.z + b.z
	)
end

function meta.__sub(a, b)
	return new(
		a.x - b.x,
		a.y - b.y,
		a.z - b.z
	)
end

--made to interact with 3x3 matrices
function meta.__mul(a, b)
	local atype = getctype(a)
	local btype = getctype(b)
	if atype == "number" then
		return new(a*b.x, a*b.y, a*b.z)
	elseif atype == "mat3" then
		return new(
			a.xx*b.x + a.yx*b.y + a.zx*b.z,
			a.xy*b.x + a.yy*b.y + a.zy*b.z,
			a.xz*b.x + a.yz*b.y + a.zz*b.z
		)
	else
		return new(a.x*b, a.y*b, a.z*b)
	end
end

function meta.__div(a, b)
	return new(a.x/b, a.y/b, a.z/b)
end

vec3.null = new(0, 0, 0)

return vec3

--[[
mat3*vec3
number*vec3
vec3*number
]]