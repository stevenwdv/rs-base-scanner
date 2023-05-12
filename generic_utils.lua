---@param n number
---@return 1|0|-1
local function sign(n)
	return n > 0 and 1 or n < 0 and -1 or 0
end

return {
	sign = sign,
}
