local function get_current_version()
	local result, _ = vim.fn.system("git rev-parse --short HEAD"):gsub("\n", "")
	return result
end

local function trim(str)
	return str:gsub("^%s+", ""):gsub("%s+$", "")
end

---@param file_path string
---@return string
local function shorten_file_path(file_path)
	local parts = {}

	file_path = file_path:gsub(vim.fn.expand("$HOME"), "~")
	for part in string.gmatch(file_path, "[^/]+") do
		table.insert(parts, part)
	end

	if #parts <= 1 then
		return file_path -- If there's only one part, return the original path
	end

	local filename = table.remove(parts) -- Remove and get the last part (filename)
	local shorten = vim.tbl_map(function(part)
		return string.sub(part, 1, 1)
	end, parts)

	if #shorten > 5 then
		return table.concat({ unpack(shorten, 1, 2) }, "/")
			.. "/…/"
			.. table.concat({ unpack(shorten, #shorten - 1, #shorten) }, "/")
			.. "/"
			.. filename
	end

	return table.concat(shorten, "/") .. "/" .. filename
end

---@param original any
---@return any
local function deep_copy(original)
	if type(original) ~= "table" then
		return original
	end

	local copy = {}
	for key, value in pairs(original) do
		copy[deep_copy(key)] = deep_copy(value)
	end

	return copy
end

---@param msg string
---@param level? integer
local function log(msg, level)
	vim.notify(msg, level or vim.log.levels.ERROR)
end

return {
	trim = trim,
	shorten_file_path = shorten_file_path,
	get_current_version = get_current_version,
	deep_copy = deep_copy,
	log = log,
}
