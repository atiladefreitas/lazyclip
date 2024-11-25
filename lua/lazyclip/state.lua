local Config = require("lazyclip.config")

local State = {
	clipboard = {},
	timestamps = {},
	copy_counts = {},
	current_page = 1,
}

function State.init()
	-- Create the TextYankPost autocmd
	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			State.add_item(vim.fn.getreg('"'))
		end,
	})
end

function State.add_item(item)
	if not item or item == "" then
		return
	end

	-- Check if item already exists
	local existing_index = nil
	for i, existing_item in ipairs(State.clipboard) do
		if existing_item == item then
			existing_index = i
			break
		end
	end

	if existing_index then
		-- Update existing item
		State.copy_counts[item] = (State.copy_counts[item] or 1) + 1
		-- Move to top
		table.remove(State.clipboard, existing_index)
		table.remove(State.timestamps, existing_index)
		table.insert(State.clipboard, 1, item)
		table.insert(State.timestamps, 1, os.time())
	else
		-- Add new item
		table.insert(State.clipboard, 1, item)
		table.insert(State.timestamps, 1, os.time())
		State.copy_counts[item] = 1
	end

	-- Maintain max history
	if #State.clipboard > Config.max_history then
		local removed_item = table.remove(State.clipboard)
		table.remove(State.timestamps)
		State.copy_counts[removed_item] = nil
	end
end

function State.get_copy_count(item)
	return State.copy_counts[item] or 1
end

function State.get_time_diff(timestamp)
	local now = os.time()
	local diff = now - timestamp

	if diff < 60 then
		return string.format("%ds", diff)
	elseif diff < 3600 then
		return string.format("%dm", math.floor(diff / 60))
	elseif diff < 86400 then
		return string.format("%dh", math.floor(diff / 3600))
	else
		return string.format("%dd", math.floor(diff / 86400))
	end
end

function State.get_page_bounds()
	local start_index = (State.current_page - 1) * Config.items_per_page + 1
	local end_index = math.min(start_index + Config.items_per_page - 1, #State.clipboard)
	return start_index, end_index
end

function State.get_total_pages()
	return math.ceil(#State.clipboard / Config.items_per_page)
end

function State.navigate_page(direction)
	local new_page = State.current_page + direction
	if new_page >= 1 and new_page <= State.get_total_pages() then
		State.current_page = new_page
		return true
	end
	return false
end

function State.get_item_at_index(index)
	local start_idx = (State.current_page - 1) * Config.items_per_page + 1
	local actual_idx = start_idx + index - 1
	return State.clipboard[actual_idx], State.timestamps[actual_idx]
end

-- Setup TextYankPost autocmd
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		State.add_item(vim.fn.getreg('"'))
	end,
})

return State
