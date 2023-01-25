local mat3 = require('linearalgebra/mat3')
local quat = require('linearalgebra/quat')
local vec2 = require('linearalgebra/vec2')
local vec3 = require('linearalgebra/vec3')

local va = vec3.new(1, 2, 3)
local vb = vec3.new(4, 5, 1)

print(va + vb)

print(va:dot(vb))

print(quat.mat(mat3.rand()))