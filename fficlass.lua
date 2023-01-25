local ffi = require('ffi')

local fficlass = {}

local function getcdeftype(cdefstr)
	for i = #cdefstr, 1, -1 do
		if cdefstr:sub(i, i) == ' ' then
			return cdefstr:sub(i + 1, #cdefstr - 1)
		end
	end
end

function fficlass.new(cdefstr)
	local cdeftype = getcdeftype(cdefstr)

	local class = {}

	ffi.cdef(cdefstr)
	ffi.metatype(cdeftype, class)

	class.__index = class
	class.new = ffi.typeof(cdeftype)
	class.type = cdeftype

	return class
end

--[[
function fficlass:CType()
	--local type = type(self)
	--return type == 'cdata' and self.type or type
end
]]

return fficlass