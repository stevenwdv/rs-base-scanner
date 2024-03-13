---Get type of (ghost) entity
---@param entity LuaEntity
---@return string @type for this entity or the entity contained in the ghost
local function get_type(entity)
    return entity.type == "entity-ghost" and entity.ghost_type or entity.type
end

---Get prototype of (ghost) entity
---@param entity LuaEntity
---@return LuaEntityPrototype|LuaTilePrototype @Prototype for this entity or the entity contained in the ghost
local function get_prototype(entity)
    return entity.type == "entity-ghost" and entity.ghost_prototype or entity.prototype
end

---Rotate offset vector clockwise
---@param offset Vector
---@param orientation RealOrientation Only quarters
---@return Vector
---@nodiscard
local function rotate_quarters(offset, orientation)
	local x, y = offset[1], offset[2]
	local orientation_int = orientation % 1 * 4 + 1
	return {
		({ x, -y, -x, y })[orientation_int],
		({ y, x, -y, -x })[orientation_int],
	}
end

---@param pos MapPosition
---@return int chunk_x, int chunk_y
local function get_chunk(pos)
	return math.floor(pos.x / 32), math.floor(pos.y / 32)
end

---@alias ChunkID integer

---@param chunk_x int
---@param chunk_y int
---@return ChunkID
local function get_chunk_id(chunk_x, chunk_y)
	return chunk_x * 0x10000 + chunk_y -- Shift 16 bits
end

---@param player_index uint
---@param prop string Name of data property
---@param set any Value to set, or default value
---@param create boolean? Create if nonexisting
---@param overwrite boolean? Always set value, if
---@return any # Value, or previous value if overwrite
local function player_data_get_set_impl(player_index, prop, set, create, overwrite)
	local data_players = global.player_data
	if not data_players then
		if not create then return set end
		data_players = {}
		global.player_data = data_players
	end

	local data_player = data_players[player_index]
	if not data_player then
		if not create then return set end
		data_player = {}
		data_players[player_index] = data_player
	end

	local data_prop = data_player[prop]
	if overwrite then
		if data_prop or create then
			data_player[prop] = set
		end
	else
		if not data_prop then
			if not create then return set end
			data_prop = set
			data_player[prop] = data_prop
		end
	end
	return data_prop
end

local player_data = {
	---@param player_index uint
	---@param prop string Name of data property
	---@param default any
	---@param create boolean? Create if nonexisting (default false)
	---@return any # Value
	get = function(player_index, prop, default, create)
		return player_data_get_set_impl(player_index, prop, default, create)
	end,

	---@param player_index uint
	---@param prop string Name of data property
	---@param value any
	---@return any # Previous value
	set = function(player_index, prop, value)
		return player_data_get_set_impl(player_index, prop, value, true, true)
	end,

	---@param player_index uint
	---@param prop string Name of data property
	---@return any # Old Value
	remove = function(player_index, prop)
		return player_data_get_set_impl(player_index, prop, nil, false, true)
	end,

	---@param player_index uint
	purge = function(player_index)
		local data_players = global.player_data
		if data_players then
			data_players[player_index] = nil
		end
	end,
}

return {
	get_type = get_type,
	get_prototype = get_prototype,
	rotate_quarters = rotate_quarters,
	get_chunk = get_chunk,
	get_chunk_id = get_chunk_id,
	player_data = player_data,
}
