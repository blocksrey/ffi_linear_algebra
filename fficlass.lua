local ffi = require("ffi")

local sub = string.sub

local fficlass = {}

local function cdeftype(cdef)
	local len = #cdef
	for ind = len, 1, -1 do
		if sub(cdef, ind, ind) == " " then
			return sub(cdef, ind + 1, len - 1)
		end
	end
end

function fficlass.new(cdef)
	local prop = {}
	local meta = {}
	
	local typ = cdeftype(cdef)

	ffi.cdef(cdef)
	ffi.metatype(typ, meta)

	prop.new  = ffi.typeof(typ)
	prop.type = typ

	meta.__index = prop

	return prop, meta
end

function fficlass.ctype(a)
	local atype = type(a)
	return atype == "cdata" and a.type or atype
end

return fficlass