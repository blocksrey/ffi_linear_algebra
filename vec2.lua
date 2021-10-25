local fficlass = require("fficlass")

local vec2, meta = fficlass.new("typedef struct {float x, y;} vec2;")

local new = vec2.new
local sqrt = math.sqrt

local null = new(0, 0)

vec2.null = null

function vec2.dot(a, b)
	return a.x*b.x + a.y*b.y
end

function vec2.perp(a)
	return new(x, -y)
end

function vec2.magnitude(a)
	return sqrt(a.x*a.x + a.y*a.y)
end

function vec2.positiveUnit(a)
	local l = sqrt(a.x*a.x + a.y*a.y)
	return new(a.x/l, a.y/l)
end

function vec2.unit(a)
	local l = sqrt(a.x*a.x + a.y*a.y)
	if l > 0 then
		return new(a.x/l, a.y/l)
	end
	return null
end

function vec2.dump(a)
	return a.x, a.y
end

function meta.__add(a, b)
	return new(
		a.x + b.x,
		a.y + b.y
	)
end

function meta.__sub(a, b)
	return new(
		a.x - b.x,
		a.y - b.y
	)
end

function meta.__mul(a, b)
	local atype = type(a)
	if atype == "number" then
		return new(a*b.x, a*b.y)
	else
		return new(
			a.xx*b.x + a.yx*b.y,
			a.xy*b.x + a.yy*b.y
		)
	end
end

function meta.__div(a, b)
	return new(a.x/b, a.y/b)
end

function meta.__unm(a)
	return new(-a.x, -a.y)
end

function meta.__tostring(a)
	return "vec2("..a.x..", "..a.y..")"
end

return vec2