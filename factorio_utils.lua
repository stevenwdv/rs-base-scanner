---Get prototype of (ghost) entity
---@param entity LuaEntity
---@return LuaEntityPrototype|LuaTilePrototype @Prototype for this entity or the entity contained in the ghost
local function get_prototype(entity)
    return entity.type == "entity-ghost" and entity.ghost_prototype or entity.prototype
end

return {
	get_prototype = get_prototype,
}
