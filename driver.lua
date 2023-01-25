local mat3 = require('mat3')
local quat = require('quat')
local vec2 = require('vec2')
local vec3 = require('vec3')

local va = vec3.new(1, 2, 3)
local vb = vec3.new(4, 5, 1)

print(va + vb)

print(va:dot(vb))

print(quat.mat(mat3.rand()))