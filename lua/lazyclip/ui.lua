local State = require("lazyclip.state")
local Config = require("lazyclip.config")
local api = vim.api
local notify = vim.notify
local keymap = vim.keymap
local log_levels = vim.log.levels

local UI = {}

local function detect_filetype(content)
	local extension_patterns = {
		[".lua"] = "lua",
		[".py"] = "python",
		[".js"] = "javascript",
		[".ts"] = "typescript",
		[".jsx"] = "javascriptreact",
		[".tsx"] = "typescriptreact",
		[".cpp"] = "cpp",
		[".hpp"] = "cpp",
		[".h"] = "c",
		[".c"] = "c",
		[".rs"] = "rust",
		[".go"] = "go",
		[".rb"] = "ruby",
		[".php"] = "php",
		[".html"] = "html",
		[".css"] = "css",
		[".scss"] = "scss",
		[".json"] = "json",
		[".md"] = "markdown",
		[".xml"] = "xml",
		[".yaml"] = "yaml",
		[".yml"] = "yaml",
		[".sh"] = "sh",
		[".vim"] = "vim",
		[".sql"] = "sql",
	}

	local language_indicators = {
		["<?php"] = "php",
		["<!DOCTYPE"] = "html",
		["<html"] = "html",
		["{"] = "json",
		["local"] = "lua",
		["import"] = "python",
		["package"] = "java",
		["fn"] = "rust",
		["async"] = "javascript",
		["function"] = "javascript",
		["def "] = "python",
		["class "] = "python",
	}

	for ext, ft in pairs(extension_patterns) do
		if content:match("%." .. ext:sub(2) .. "[%s\n]") then
			return ft
		end
	end

	for line in content:gmatch("[^\n]+") do
		for indicator, ft in pairs(language_indicators) do
			if line:match(indicator) then
				return ft
			end
		end
	end

	return "text"
end

local function setup_highlights()
	local highlights = {
		LazyClipNormal = { link = "Normal" },
		LazyClipBorder = { link = "FloatBorder" },
		LazyClipSelected = { link = "CursorLine" },
		LazyClipIndex = { link = "Number" },
		LazyClipContent = { link = "String" },
		LazyClipPageInfo = { link = "Comment" },
		LazyClipTimestamp = { link = "Comment" },
		LazyClipCopyCount = { link = "Constant" },
	}

	for group, opts in pairs(highlights) do
		api.nvim_set_hl(0, group, opts)
	end
end

local function create_window_options()
	local win_width = Config.window.width
	local win_height = Config.window.height

	local editor_width = vim.o.columns
	local editor_height = vim.o.lines

	local row = math.floor((editor_height - win_height) / 2) - 1
	local col = math.floor((editor_width - win_width) / 2)

	return {
		relative = "editor",
		width = win_width,
		height = win_height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
		title = " Clipboard ",
		title_pos = "center",
	}
end

local function create_preview_window_options(main_win_pos)
	local preview_height = math.floor(vim.o.lines * 0.2)
	return {
		relative = "editor",
		width = Config.window.width,
		height = preview_height,
		col = main_win_pos.col,
		row = main_win_pos.row + Config.window.height + 1,
		style = "minimal",
		border = "rounded",
		title = " Preview ",
		title_pos = "center",
	}
end

local function sanitize_display_text(text)
	if not text then
		return ""
	end

	local sanitized = text:gsub("\n", " "):gsub("%s+", " ")

	if #sanitized > 30 then
		sanitized = sanitized:sub(1, 40) .. " ..."
	end

	return sanitized:trim()
end

local function create_display_line(index, content, timestamp)
	local WINDOW_WIDTH = Config.window.width
	local RIGHT_MARGIN = 2

	local time_diff = ""
	if content and timestamp then
		time_diff = State.get_time_diff(timestamp)
	end

	local left_side = string.format("[%d] - %s", index, sanitize_display_text(content))

	local padding_length = WINDOW_WIDTH - #left_side - #time_diff - RIGHT_MARGIN
	local padding = string.rep(" ", math.max(0, padding_length))

	if content then
		return string.format("[%d] - %s%s%s", index, sanitize_display_text(content), padding, time_diff)
	else
		return string.format("[%d] -", index)
	end
end

if not string.trim then
	string.trim = function(s)
		return s:match("^%s*(.-)%s*$")
	end
end

local ns_id = api.nvim_create_namespace("lazyclip")

local function setup_preview_buffer(bufnr, content)
	local filetype = detect_filetype(content)

	api.nvim_buf_set_option(bufnr, "modifiable", true)
	api.nvim_buf_set_option(bufnr, "buftype", "nofile")
	api.nvim_buf_set_option(bufnr, "filetype", filetype)

	local lines = {}
	for line in content:gmatch("[^\n]+") do
		while #line > Config.window.width - 2 do
			table.insert(lines, line:sub(1, Config.window.width - 2))
			line = line:sub(Config.window.width - 1)
		end
		table.insert(lines, line)
	end

	local max_lines = api.nvim_win_get_height(0) - 2
	if #lines > max_lines then
		lines = vim.list_slice(lines, 1, max_lines - 1)
		table.insert(lines, "...")
	end

	api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	api.nvim_buf_set_option(bufnr, "modifiable", false)
end

local function setup_buffer_syntax(bufnr)
	api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

	local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
	for i, line in ipairs(lines) do
		local start_idx = line:find("%[%d%]")
		if start_idx then
			api.nvim_buf_add_highlight(bufnr, ns_id, "LazyClipIndex", i - 1, start_idx - 1, start_idx + 2)

			local content_start = line:find("%-")
			if content_start then
				local timestamp_start = line:find("%d+[smhd]%s*$")

				if content_start then
					api.nvim_buf_add_highlight(
						bufnr,
						ns_id,
						"LazyClipContent",
						i - 1,
						content_start + 1,
						content_start + 51
					)
				end

				if timestamp_start then
					api.nvim_buf_add_highlight(bufnr, ns_id, "LazyClipTimestamp", i - 1, timestamp_start - 1, -1)
				end
			end
		end

		if line:find("^Page") then
			api.nvim_buf_add_highlight(bufnr, ns_id, "LazyClipPageInfo", i - 1, 0, -1)
		end
	end
end

local function render_content(bufnr)
	local lines = {}

	for i = 1, Config.items_per_page do
		local item, timestamp = State.get_item_at_index(i)
		if item then
			lines[i] = create_display_line(i, item, timestamp)
		else
			lines[i] = string.format("[%d] -", i)
		end
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format("Page %d/%d", State.current_page, State.get_total_pages())

	api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	setup_buffer_syntax(bufnr)
end

local function create_preview_window(main_win_pos)
	local bufnr = api.nvim_create_buf(false, true)
	local opts = create_preview_window_options(main_win_pos)
	local winnr = api.nvim_open_win(bufnr, false, opts)

	api.nvim_win_set_option(winnr, "winhl", "Normal:LazyClipNormal,FloatBorder:LazyClipBorder")

	return winnr, bufnr
end

local function setup_buffer_keymaps(bufnr, winnr, preview_bufnr)
	local update_preview = function()
		local cursor = api.nvim_win_get_cursor(winnr)
		local line = cursor[1]
		local item = State.get_item_at_index(line)
		if item then
			setup_preview_buffer(preview_bufnr, item)
		end
	end

	local keymaps = {
		{
			"n",
			Config.keymaps.close_window,
			function()
				UI.close_windows(winnr)
			end,
		},
		{
			"n",
			Config.keymaps.prev_page,
			function()
				UI.navigate_page(winnr, bufnr, -1)
			end,
		},
		{
			"n",
			Config.keymaps.next_page,
			function()
				UI.navigate_page(winnr, bufnr, 1)
			end,
		},
		{
			"n",
			Config.keymaps.paste_selected,
			function()
				UI.paste_selected(winnr)
			end,
		},
		{
			"n",
			Config.keymaps.copy_selected,
			function()
				UI.copy_selected_to_clipboard(winnr)
			end,
		},
		{
			"n",
			Config.keymaps.move_down,
			function()
				api.nvim_command("normal! j")
				update_preview()
			end,
		},
		{
			"n",
			Config.keymaps.move_up,
			function()
				api.nvim_command("normal! k")
				update_preview()
			end,
		},
	}

	keymap.set("n", "d", function()
		local cursor = api.nvim_win_get_cursor(winnr)
		local line = cursor[1]
		if State.delete_item(line) then
			render_content(bufnr)
			-- Update preview if items remain
			local item = State.get_item_at_index(line)
			if item then
				setup_preview_buffer(preview_bufnr, item)
			else
				setup_preview_buffer(preview_bufnr, "")
			end
		end
	end, {
		buffer = bufnr,
		noremap = true,
		silent = true,
	})

	for i = 1, Config.items_per_page do
		table.insert(keymaps, {
			"n",
			tostring(i),
			function()
				UI.paste_and_close(winnr, i)
			end,
		})
	end

	for _, map in ipairs(keymaps) do
		keymap.set(map[1], map[2], map[3], {
			buffer = bufnr,
			noremap = true,
			silent = true,
		})
	end

	vim.schedule(update_preview)
end

function UI.close_windows(main_winnr)
	if UI.preview_winnr and api.nvim_win_is_valid(UI.preview_winnr) then
		api.nvim_win_close(UI.preview_winnr, true)
	end
	api.nvim_win_close(main_winnr, true)
end

function UI.open_window()
	if #State.clipboard == 0 then
		notify("Clipboard is empty!", log_levels.INFO)
		return
	end

	setup_highlights()

	local main_bufnr = api.nvim_create_buf(false, true)
	local pos = Config.get_window_position()
	local main_winnr = api.nvim_open_win(main_bufnr, true, create_window_options())

	local preview_winnr, preview_bufnr = create_preview_window(pos)

	api.nvim_win_set_option(main_winnr, "winhl", "Normal:LazyClipNormal,FloatBorder:LazyClipBorder")

	api.nvim_buf_set_option(main_bufnr, "relativenumber", false)
	api.nvim_buf_set_option(main_bufnr, "number", false)

	render_content(main_bufnr)
	setup_buffer_keymaps(main_bufnr, main_winnr, preview_bufnr)

	api.nvim_win_set_option(main_winnr, "cursorline", true)

	UI.preview_winnr = preview_winnr
	UI.preview_bufnr = preview_bufnr
end

function UI.navigate_page(_, bufnr, direction)
	if State.navigate_page(direction) then
		render_content(bufnr)
	end
end

function UI.paste_and_close(winnr, index)
	local item = State.get_item_at_index(index)
	if item then
		UI.close_windows(winnr)
		api.nvim_paste(item, false, -1)
	else
		notify("Invalid index!", log_levels.WARN)
	end
end

function UI.paste_selected(winnr)
	local cursor = api.nvim_win_get_cursor(winnr)
	local line = cursor[1]
	local item = State.get_item_at_index(line)

	if item then
		UI.close_windows(winnr)
		api.nvim_paste(item, false, -1)
	else
		notify("Invalid selection!", log_levels.WARN)
	end
end

function UI.copy_selected_to_clipboard(winnr)
    local cursor = api.nvim_win_get_cursor(winnr)
    local line = cursor[1]
    local item = State.get_item_at_index(line)

    if item then
        UI.close_windows(winnr)
        vim.fn.setreg('+', item)
        notify("Item copied to clipboard!", log_levels.INFO)
    else
        notify("Invalid selection!", log_levels.WARN)
    end
end

return UI
