local fficlass = require("fficlass")

local prop, meta = fficlass.new("typedef struct {float x, y;} vec2;")

local new = prop.new

local null = new(0, 0)

prop.null = null

function prop.dot(a, b)
	return a.x*b.x + a.y*b.y
end

function prop.magnitude(a)
	return (a.x*a.x + a.y*a.y)^(1/2)
end

function prop.unit(a)
	local l = (a.x*a.x + a.y*a.y)^(1/2)
	if l > 0 then
		return new(a.x/l, a.y/l)
	else
		return null
	end
end

function prop.dump(a)
	return a.x, a.y
end

function meta.__tostring(a)
	return "vec2("..a.x..", "..a.y..")"
end

function meta.__unm(a)
	return new(
		-a.x,
		-a.y
	)
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

return prop