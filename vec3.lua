local fficlass = require("fficlass")

local prop, meta = fficlass.new("typedef struct {float x, y, z;} vec3;")

local ctype = fficlass.ctype
local new   = prop.new

local null = new(0, 0, 0)

prop.null = null

function prop.dot(a, b)
	return a.x*b.x + a.y*b.y + a.z*b.z
end

function prop.cross(a, b)
	return new(
		a.y*b.z - a.z*b.y,
		a.z*b.x - a.x*b.z,
		a.x*b.y - a.y*b.x
	)
end

function prop.magnitude(a)
	return (a.x*a.x + a.y*a.y + a.z*a.z)^(1/2)
end

function prop.unit(a)
	local l = (a.x*a.x + a.y*a.y + a.z*a.z)^(1/2)
	if l > 0 then
		return new(a.x/l, a.y/l, a.z/l)
	else
		return null
	end
end

function prop.dump(a)
	return a.x, a.y, a.z
end

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

function meta.__mul(a, b)
	local atype = ctype(a)
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

return prop