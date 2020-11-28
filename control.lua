function onEntityAdded(entity)
	if entity.unit_number ~= nil and entity.name == "destruction-sensor" then
		global.sensors[entity.unit_number] = entity
	end
end

function onEntityRemoved(entity)
	if entity.unit_number ~= nil then
		global.sensors[entity.unit_number] = nil
	end
end

function abs(val)
	if val < 0 then
		val = val * -1
	end
	return val
end

script.on_init(function()
	if not global.sensors then
		global.sensors = {}
	end

	if not global.runNextFrame then
		global.runNextFrame = {}
	end
end)

script.on_event(defines.events.on_entity_died, function(event)
	if event.entity.name == "destruction-sensor" then
		onEntityRemoved(event.entity)
	end
	if event.cause and event.force and event.entity.force ~= event.force then
		--[[
		for all destruction sensors:
		  calculate if died entity is in range of sensors
		  set sensor output to 1
		  call function in next frame, before this function might run again:
			set sensor output to 0
		]]--
		for _,sensor in pairs(global.sensors) do
			if sensor.force == event.entity.force then
				local dX = abs(sensor.position.x - event.entity.position.x)
				local dY = abs(sensor.position.y - event.entity.position.y)
				
				if (dX <= 24 and dY <= 24) then
					-- Set output to 1
					sensor.get_control_behavior().parameters = {parameters = {{
						index = 1,
						signal = {type = "virtual", name = "signal-D"},
						count = 1
					}}}
					-- Set output to 0 in next frame
					table.insert(global.runNextFrame, {func = function(param)
						param.get_control_behavior().parameters = {parameters = {}}
					end, params = sensor})
				end
			end
		end
	end
end)

script.on_event(defines.events.on_pre_player_mined_item, function(event)
	onEntityRemoved(event.entity)
end)

script.on_event(defines.events.on_robot_pre_mined, function(event)
	onEntityRemoved(event.entity)
end)

script.on_event(defines.events.on_built_entity, function(event)
	onEntityAdded(event.created_entity)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
	onEntityAdded(event.created_entity)
end)

script.on_event(defines.events.on_tick, function(event)
	for _,funcParams in ipairs(global.runNextFrame) do
		funcParams.func(funcParams.params)
	end
	global.runNextFrame = {}
end)

script.on_event(defines.events.on_selected_entity_changed, function(event)
	if global.highlightRect then
		-- clear existing rectangle
		rendering.destroy(global.highlightRect)
		global.highlightRect = nil
	end

	local player = game.get_player(event.player_index)
	local entity = player.selected
	if player and entity and entity.name == "destruction-sensor" then
		
		global.highlightRect = rendering.draw_rectangle({
			color = {g = 0.15, a = 0.25},
			filled = true,
			left_top = entity, left_top_offset = {-24, 24},
			right_bottom = entity, right_bottom_offset = {24, -24},
			surface = player.surface,
			players = { player },
			draw_on_ground = true
		})
	end
end)

--[[script.on_event(defines.events.on_cursor_stack_changed, function(event)
	local new_stack = game.get_player(event.player_index).cursor_stack
	if new_stack.name = "destruction_sensor" then
		if global.highlightRect then
			-- clear existing rectangle
			rendering.destroy(global.highlightRect)
			global.highlightRect = nil
		end
		
		local top_left = -- cursor position + {-24, 24}
		local bottom_right = -- cursor position + {24, -24}
		
		global.highlightRect = rendering.draw_rectangle({
			color = {g = 0.15, a = 0.25},
			filled = true,
			left_top = top_left
			right_bottom =  bottom_right
			surface = player.surface,
			players = { player },
			draw_on_ground = true
		})
	end
end)
]]--