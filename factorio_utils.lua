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

return {
	get_type = get_type,
	get_prototype = get_prototype,
	rotate_quarters = rotate_quarters,
	get_chunk = get_chunk,
	get_chunk_id = get_chunk_id,
}
