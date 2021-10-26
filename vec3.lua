local fficlass = require("fficlass")

local vec3, meta = fficlass.new("typedef struct {float x, y, z;} vec3;")

local new = vec3.new
local sqrt = math.sqrt

local null = new(0, 0, 0)

vec3.null = null

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

--magnitude of vector
function vec3.norm(a)
	return sqrt(a.x*a.x + a.y*a.y + a.z*a.z)
end

--unitize assuming norm > 0
function vec3.posUnit(a)
	local l = sqrt(a.x*a.x + a.y*a.y + a.z*a.z)
	return new(a.x/l, a.y/l, a.z/l)
end

--unitize no assumptions
function vec3.unit(a)
	local l = sqrt(a.x*a.x + a.y*a.y + a.z*a.z)
	if l > 0 then
		return new(a.x/l, a.y/l, a.z/l)
	end
	return null
end

function vec3.dump(a)
	return a.x, a.y, a.z
end

function vec3.quat(q)
	local i, j, k = self:dump()
	local w, x, y, z = q:dumpH()

	return new(
		i*(1 - y*y - z*z) + j*(x*y - w*z) + k*(x*z + w*y),
		i*(x*y + w*z) + j*(1 - x*x - z*z) + k*(y*z - w*x),
		i*(x*z - w*y) + j*(y*z + w*x) + k*(1 - x*x - y*y)
	)
end

function vec3.invQuat(q)
	local i, j, k = self:dump()
	local w, x, y, z = q:dumpH()

	return new(
		i*(1 - y*y - z*z) + j*(x*y + w*z) + k*(x*z - w*y),
		i*(x*y - w*z) + j*(1 - x*x - z*z) + k*(y*z + w*x),
		i*(x*z + w*y) + j*(y*z - w*x) + k*(1 - x*x - y*y)
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

function meta.__mul(a, b)
	local atype = type(a)
	if atype == "number" then
		return new(a*b.x, a*b.y, a*b.z)
	else
		return new(
			a.xx*b.x + a.yx*b.y + a.zx*b.z,
			a.xy*b.x + a.yy*b.y + a.zy*b.z,
			a.xz*b.x + a.yz*b.y + a.zz*b.z
		)
	end
end

function meta.__div(a, b)
	return new(a.x/b, a.y/b, a.z/b)
end

function meta.__unm(a)
	return new(-a.x, -a.y, -a.z)
end

function meta.__tostring(a)
	return "vec3("..a.x..", "..a.y..", "..a.z..")"
end

return vec3