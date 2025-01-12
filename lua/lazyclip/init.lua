local M = {}

function M.setup(opts)
	-- Get the default config
	local config = require("lazyclip.config")

	if opts then
		-- Deep merge the user config with default config
		config = vim.tbl_deep_extend("force", config, opts)

		-- Update the config module with the merged configuration
		for k, v in pairs(config) do
			require("lazyclip.config")[k] = v
		end
	end

	-- Initialize the state
	require("lazyclip.state").init()

	-- Set default keybinding if not overridden
	if not (opts and opts.disable_default_keymap) then
		vim.keymap.set(
			"n",
			"<leader>Cw",
			":lua require('lazyclip.ui').open_window()<CR>",
			{ noremap = true, silent = true, desc = "Open Clipboard Manager" }
		)
	end
end

-- Add the show_clipboard function for backward compatibility
function M.show_clipboard()
	require("lazyclip.ui").open_window()
end

return M
