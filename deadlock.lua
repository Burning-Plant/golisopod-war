obs = obslua
image_path = "~/Projects/obs_deadlock/golisopods/"

scene_uuid = nil
output_group_uuid = nil

simulate = false

golisopod_instances = {}

golisopod_sources = {}

function script_description()
	return "for my oomf, Lynx <3"
end

function script_properties()

	local props = obs.obs_properties_create()
	obs.obs_properties_add_path(
		props,
		"image_path",
		"Pod folder",
		obs.OBS_PATH_DIRECTORY,
		"Path to a folder",
		nil
	)

	obs.obs_properties_add_button(
		props,
		"add_image",
		"Add image to current scene",
		add_golisopod
	)


	obs.obs_properties_add_button(
		props,
		"reset scene",
		"Set destination scene to current",
		function()
			--obs.script_log(obs.LOG_INFO,"clicked dis button btw")
			local scene_source = obs.obs_frontend_get_current_scene()
			if scene_source == nil then
				return false
			end

			scene_uuid = obs.obs_source_get_uuid(scene_source)
			obs.script_log(obs.LOG_DEBUG,"set scene uuid to ".. scene_uuid)
			local name = obs.obs_source_get_name(scene_source)
			obs.obs_source_release(scene_source)	

			return name
		end
	)

	obs.obs_properties_add_list(
		props,
		"destination_group",
		"Destination Group",
		obs.OBS_COMBO_TYPE_LIST,
		obs.OBS_COMBO_FORMAT_STRING
	)
	obs.obs_properties_add_button(
		props,
		"repopulate_group",
		"Repopulate Destination List",
		function(props,self)
			local list = obs.obs_properties_get(props,"destination_group")
			if list == nil then
				obs.script_log(obs.LOG_ERROR,"No list found?")
				return false
			else
				obs.script_log(obs.LOG_DEBUG,"Got list "..obs.obs_property_name(list))
			end

			obs.obs_property_list_clear(list)

			if scene_uuid == nil then
				obs.script_log(obs.LOG_ERROR,"Scene not set.")
				return false
			end
			
			if not obs.obs_source_is_scene(scene_source) then
				obs.script_log(obs.LOG_ERROR,"Scene source is NOT a scene. How did you do that?")
				return false
			end
			local scene_source = obs.obs_scene_from_source(obs.obs_get_source_by_uuid(scene_uuid))

			if scene_source == nil then
				obs.script_log(obs.LOG_ERROR,"Scene does not exist.")
				return false
			end

			
			local items = obs.obs_scene_enum_item(scene_source)
			if items == nil then
				obs.script_log(obs.LOG_ERROR,"got no items")
			end

			for k, v in pairs(items) do

				local name = obs.obs_source_get_name(item)
				if obs.source_is_group(scene,item) then
					local uuid = obs.obs_source_get_uuid(item)

					obs.obs_property_list_add_string(list,name,uuid)
					obs.script_log(obs.LOG_DEBUG,"Added item "..name..", uuid "..uuid)
				else
					obs.script_log(obs.LOG_DEBUG,"Skipping item"..name)
				end

				obs.script_log(obs.LOG_DEBUG,"item #"..k..","..v)
			end
			--add items that are groups
			obs.sceneitem_list_release(items)
			obs.obs_source_release(scene_source)
			obs.script_log(obs.LOG_DEBUG,"fin")
		end
	)

	obs.obs_properties_add_bool(
		props,
		"do_sim",
		"Let the golisopods do their thang (Golisopods move)"
	)

	return props
end

function new_golisopod(path)
	local golisopod = obs.obs_create_source()--blah blah blah)
	return golisopod
end

function add_golisopod(scene,index)
	local scene = obs.obs_scene_from_source(obs.obs_get_source_by_uuid(scene_uuid))

	if index == nil then
		index = math.random(0,len(golisopod_sources))
	end

	if golisopod_sources[index] then
		local instance = obs_scene_add(scene,golisopod_sources[index])
		if instance == nil then
			obs.script_log(obs.LOG_ERROR,"failed to add pod")
			return
		end
		table.insert(golisopod_instances,instance)
	end
	--duty of caller to add to instance table
	return item
end

function script_update(settings)
	image_path = obs.obs_data_get_string(settings, "image_path")
	scene_uuid = obs.obs_data_get_string(settings, "destination_scene")
	local group_uuid = obs.obs_data_get_string(settings, "destination_group")
	output_group_uuid = obs.obs_get_source_by_uuid(group_uuid)
	simulate = obs.obs_data_get_bool(settings,"do_sim")
end


function script_unload()
	for i in golisopods do
		obs.obs_item_release(i)
	end
	obs.obs_properties_destroy(props)
end
