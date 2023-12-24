-- Global
iaenhance = {}
local MODNAME = minetest.get_current_modname()

-- Tool enhancement (mese infusion) mod by archfan7411, licensed MIT.

-- Factor by which performance is to be increased for enhanced tools.
-- Default is 1.2, which translates to a 20% increase in effectiveness.
--local modifier = 1.2
local modifier = core.settings:get "iaenhance_modifier" or 1.2

-- Tint of enhanced tools.
local tint = "#FFFF00"
-- Opacity of said tint (0-255)
local opacity = 40

-- Saving the default tool registration function for later use.
--old_register_tool = minetest.register_tool

-- Overriding the tool registration to also define enhanced tools
function iaenhance.register_tool(name, e_name, def)

	-- Copying the given tool def to create the enhanced def
	local e_def = table.copy(def)

	-- The name is a separate argument which we need to copy as well.
	--local e_name = name

	-- TODO make radioactive
	
	-- If the tool has standardized tool capabilities
	if e_def.tool_capabilities and e_def.tool_capabilities.groupcaps then

		local e_groupcaps = e_def.tool_capabilities.groupcaps

		-- For each group the tool has defined capabilities for
        for i, group in pairs(e_groupcaps) do
			
			-- Ensure the group is a table
            if type(group) == "table" and group.times then
			
				-- For every group level defined in "times"
                for index, level in pairs(group.times) do
	
					-- Decrease the time to dig that level; speeding it up by modifier% (default 20%)
				    e_def.tool_capabilities.groupcaps[i].times[index] = level / modifier

                end
            end
		end

		-- Improve damage dealt by tool
		if e_def.tool_capabilities.damage_groups then
			for group, value in pairs(e_def.tool_capabilities.damage_groups) do
				e_def.tool_capabilities.damage_groups[group] = math.ceil(value * modifier)
			end
		end

		-- too many items
		e_def.groups.not_in_creative_inventory = 1

		-- We create our own inventory image by tinting the provided inventory image yellow
		if e_def.inventory_image then

			e_def.inventory_image = e_def.inventory_image .. "^[colorize:"..tint..":"..opacity
		end

		-- In case the tool has a separate wield image, we must tint it as well.
		if e_def.wield_image then

			e_def.wield_image = e_def.wield_image .. "^[colorize:"..tint..":"..opacity
		end

		-- We make the enhanced version's description by concatenating "Enhanced" to the start of the given description.
		if e_def.description then

			e_def.description = "Enhanced " .. e_def.description
		end

		-- This code concatenates "_enhanced" to the itemstring of the tool
		--e_name = e_name .. "_enhanced"

		-- Registering the enhanced tool.
		--old_register_tool(e_name, e_def)
		minetest.register_tool(e_name, e_def)
		print('iaenhanced registered tool: '..e_name)

		-- Registering a craft for the enhanced tool.
		minetest.register_craft({
			output = e_name,
			type = "shapeless",
			recipe = {name, "default:mese_crystal"},
		})

	end

	-- Registering the normal tool with the normal parameters.
	--old_register_tool(name, def)
end




local DEBUG_MAIN = false
function iaenhance.main()
	local tools = minetest.registered_tools
	for name, def in pairs(tools) do
		--minetest.unregister_item(name)
		local modname = string.match(name,  '([^:]+)')
		local itmname = string.match(name, ':([^:]+)')
		if modname ~= 'enhanced' then -- prevent recursive loops
			local convert_to = 'enhanced:'..modname..'_'..itmname
			local alias      = name..'_enhanced'
			if DEBUG_MAIN then
			print('iaenhanced modname: '..modname)
			print('iaenhanced itmname: '..itmname)
			print('iaenhanced convert to: '..convert_to)
			print('iaenhanced register alias: '..alias..' ==> '..convert_to)
			end
			iaenhance.register_tool(name, convert_to, def)
			minetest.register_alias(alias, convert_to)
		end
	end
end
--core.register_on_mods_loaded(iaenhance.main)
iaenhance.main()

print ("[MOD] IA Enhance loaded")
