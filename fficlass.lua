local ffi = require("ffi")

local type = type

local fficlass = {}

local function getcdeftype(cdefstr)
	for i = #cdefstr, 1, -1 do
		if cdefstr:sub(i, i) == " " then
			return cdefstr:sub(i + 1, #cdefstr - 1)
		end
	end
end

function fficlass.new(cdefstr)
	local class = {}
	local meta = {}

	local cdeftype = getcdeftype(cdefstr)

	ffi.cdef(cdefstr)
	ffi.metatype(cdeftype, meta)

	class.new = ffi.typeof(cdeftype)
	class.type = cdeftype

	meta.__index = class

	return class, meta
end

function fficlass.CType(a)
	local atype = type(a)
	return atype == "cdata" and a.type or atype
end

return fficlass