local addon = select(2,...);

local select = select
local pairs = pairs
local next = next
local type = type

--[[
/**
 * table utils
 * https://github.com/s0h2x/
 *  (c) 2022, s0h2x
 *
 * This file is provided as is (no warranties).
 */
]]

local function table_assign(src, pool)
   	src = src or {}
	pool = pool or {}
	for k,v in pairs(src) do
		if type(v) == 'table' then
			if pool[k] == nil then
				pool[k] = {}
			end
		else
            if pool[k] == nil then
			    pool[k] = src[k]
            end
		end
	end
end

local function table_copy(src, pool)
	pool = pool or {}
	for k,v in pairs(src) do
		pool[k] = v
	end
	return pool
end

addon.table = setmetatable({
	assign_over = table_assign,
	copy = table_copy,
},{__index = table})