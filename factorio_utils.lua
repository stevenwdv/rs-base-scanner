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

return {
	get_type = get_type,
	get_prototype = get_prototype,
	rotate_quarters = rotate_quarters,
}
