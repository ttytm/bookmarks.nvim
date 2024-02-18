local repo = require("bookmarks.repo")
local sign = require("bookmarks.sign")
local domain = require("bookmarks.bookmark")

---@class Bookmarks.MarkParam
---@field name string
---@field list_name? string

---@param param Bookmarks.MarkParam
local function mark(param)
	local bookmark = domain.new_bookmark(param.name)
	local bookmark_lists = repo.get_domains()

	local target_bookmark_list
	if param.list_name then
		target_bookmark_list = repo.must_find_bookmark_list_by_name(param.list_name)
	else
		target_bookmark_list = repo.find_or_set_active_bookmark_list(bookmark_lists)
	end

	local updated_bookmark_list = domain.toggle_bookmarks(target_bookmark_list, bookmark)

	repo.save_bookmark_list(updated_bookmark_list, bookmark_lists)

	sign.refresh_signs()
end

---@class Bookmarks.NewListParam
---@field name string

---@param param Bookmarks.NewListParam
---@return Bookmarks.BookmarkList
local function add_list(param)
	local bookmark_lists = repo.get_domains()
	local new_lists = vim.tbl_map(function(value)
		---@cast value Bookmarks.BookmarkList
		value.is_active = false
		return value
	end, bookmark_lists)

	---@type Bookmarks.BookmarkList
	local new_list = {
		name = param.name,
		id = repo.generate_datetime_id(),
		bookmarks = {},
		is_active = true,
	}

	table.insert(new_lists, new_list)
	repo.write_domains(new_lists)

	sign.refresh_signs()
	return new_list
end

---@param name string
local function set_active_list(name)
	local bookmark_lists = repo.get_domains()

	local updated = vim.tbl_map(function(value)
		---@cast value Bookmarks.BookmarkList
		if value.name == name then
			value.is_active = true
		else
			value.is_active = false
		end
		return value
	end, bookmark_lists)
	repo.write_domains(updated)

	sign.refresh_signs()
end

---@param bookmark Bookmarks.Bookmark
local function goto_bookmark(bookmark)
	vim.api.nvim_exec2("e" .. " " .. bookmark.location.path, {})
	vim.api.nvim_win_set_cursor(0, { bookmark.location.line, bookmark.location.col })
end

local function goto_last_visited_bookmark()
	local bookmark_list = repo.find_or_set_active_bookmark_list()
	table.sort(bookmark_list.bookmarks, function(a, b)
		if a.visitedAt == nil or b.visitedAt == nil then
			return false
		end
		return a.visitedAt > b.visitedAt
	end)

	local last_bookmark = bookmark_list.bookmarks[1]
	if last_bookmark then
		goto_bookmark(last_bookmark)
	end
end

-- TODO: trigger by `BufferEnter` Event
local function add_recent()
	local bookmark = domain.new_bookmark()
	local recent_files_bookmark_list = repo.get_recent_files_bookmark_list()
	table.insert(recent_files_bookmark_list.bookmarks, bookmark)
	repo.save_bookmark_list(recent_files_bookmark_list)
end

local function goto_next_in_current_buffer()
  vim.notify("todo")
  -- get bookmarks of current buf of current active list
  -- get current cursor position
  -- goto the nearest next bookmark
  -- if no next bookmark, then go to the first bookmark
end

local function goto_prev_in_current_buffer()
  vim.notify("todo")
  -- get bookmarks of current buf of current active list
  -- get current cursor position
  -- goto the nearest prev bookmark
  -- if no prev bookmark, then go to the last bookmark
end

return {
	mark = mark,
	add_list = add_list,
	set_active_list = set_active_list,
	goto_bookmark = goto_bookmark,
	goto_last_visited_bookmark = goto_last_visited_bookmark,
  goto_next_in_current_buffer = goto_next_in_current_buffer,
  goto_prev_in_current_buffer = goto_prev_in_current_buffer,
	add_recent = add_recent,
}
