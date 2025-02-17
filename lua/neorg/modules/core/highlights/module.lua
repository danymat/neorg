--[[
	Neorg module for managing highlight groups.
--]]

require('neorg.modules.base')

local module = neorg.modules.create("core.highlights")

--[[
    Nested trees concatenate
    So:
   	   tag = { begin = "+Comment" }
	matches the highlight group:
		NeorgTagBegin
	and converts into the command:
		highlight! link NeorgTagBegin Comment
--]]
module.config.public = {
	highlights = {}
}

module.public = {

	-- @Summary	Defines all the highlight groups for Neorg
	-- @Description Reads the highlights configuration table and applies all defined highlights
	trigger_highlights = function()
		local descend

		-- @Summary Descends down a tree of highlights and applies them
		-- @Description Recursively descends down the highlight configuration and applies every highlight accordingly
		-- @Param  highlights (table) - the table of highlights to descend down
		-- @Param  prefix (string) - should be only used by the function itself, acts as a "savestate" so the function can keep track of what path it has descended down
		descend = function(highlights, prefix)

			-- Loop through every highlight defined in the provided table
			for hl_name, highlight in pairs(highlights) do
				-- If the type of highlight we have encountered is a table
				-- then recursively descend down it as well
				if type(highlight) == "table" then
					descend(highlight, hl_name)
				else -- Our highlight is a string
					-- Trim any potential leading and trailing whitespace
					highlight = vim.trim(highlight)

					-- Check whether we are trying to link to an existing hl group
					-- by checking for the existence of the + sign at the front
					local is_link = highlight:sub(1, 1) == "+"

					-- If we are dealing with a link then link the highlights together (excluding the + symbol)
					if is_link then
						vim.cmd("highlight! link Neorg" .. prefix .. hl_name .. " " .. highlight:sub(2))
					else -- Otherwise simply apply the highlight options the user provided
						vim.cmd("highlight! Neorg" .. prefix .. hl_name .. " " .. highlight)
					end
				end
			end
		end

		-- Begin the descent down the public highlights configuration table
		descend(module.config.public.highlights, "")
	end,

	-- @Summary Adds a set of highlights from a table
	-- @Description Takes in a table of highlights and applies them to the current buffer
	-- @Param  highlights (table) - a table of highlights
	add_highlights = function(highlights)
		module.config.public.highlights = vim.tbl_deep_extend("force", module.config.public.highlights, highlights or {})
		module.public.trigger_highlights()
	end,

	-- @Summary Clears all the highlights defined by Neorg
	-- @Description Assigns all Neorg* highlights to `clear`
	clear_highlights = function()
		local descend

		-- @Summary Descends down a tree of highlights and clears them
		-- @Description Recursively descends down the highlight configuration and clears every highlight accordingly
		-- @Param  highlights (table) - the table of highlights to descend down
		-- @Param  prefix (string) - should be only used by the function itself, acts as a "savestate" so the function can keep track of what path it has descended down
		descend = function(highlights, prefix)

			-- Loop through every defined highlight
			for hl_name, highlight in pairs(highlights) do
				-- If it is a table then recursively traverse down it!
				if type(highlight) == "table" then
					descend(highlight, hl_name)
				else -- Otherwise we're dealing with a string
					-- Hence we should clear the highlight
					vim.cmd("highlight! clear Neorg" .. prefix .. hl_name)
				end
			end
		end

		-- Begin the descent
		descend(module.config.public.highlights, "")
	end
}

module.neorg_post_load = function()
	module.public.trigger_highlights()
end

return module
