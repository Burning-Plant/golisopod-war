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
		"Add pod to current scene",
		add_random_golisopod
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

function load_golisopods(folder_path)
	if type(folder_path)~="string" then
		obs.script_log(obs.LOG_ERROR,"golsiopod folder not a string")
		return false
	end

	for k, v in ipairs(golisopod_sources) do
		obs.obs_source_release(v)
		obs.script_log(obs.LOG_DEBUG,"Released golisopod")
	end

	folder_path = tostring(folder_path)

	directory = io.popen("ls "..folder_path, rl)
	for filename in directory:lines("l") do
		pod = new_golisopod(filename,filename)
		golisopod_sources[filename] = pod
		obs.script_log(obs.LOG_INFO,"added golisopod from file "..filename)
	end
	directory:close()
	return
end

function new_golisopod(file_path,name)
	local settings = obs.obs_data_create()
	obs.obs_data_set_string(settings, "file", file_path)

	local source = obs.obs_source_create(
		"image_source",
		name,
		settings,
		nil
	    )

	obs.obs_data_release(settings)

    	if source == nil then
        	obs.script_log(obs.LOG_ERROR, "Could not create image source")
        	return nil
    	end

	return source
end

function add_random_golisopod(scene)
	local keys = {}

	for key in pairs(golisopod_sources) do
	    table.insert(keys, key)
	end
	local randomIndex = math.random(1, #keys)
	local key = keys[randomIndex]

	item = add_golisopod(scene,key)

	local group = obs.obs_get_source_by_uuid(output_group_uuid)
	if group == nil then
		obs.script_log(obs.LOG_ERROR,"No group set!")
		return false
	end

	obs.obs_sceneitem_group_add_item(group,item)

	obs.obs_source_release(group)

	table.insert(golisopod_instances,item)
	return false
end

function add_golisopod(scene, index)
	local source = obs.obs_get_source_by_uuid(scene_uuid)
	local scene = obs.obs_scene_from_source(source)
	if not scene then
		obs.script_log(obs.LOG_ERROR,"No scene. Is it set?")
		return false
	end

	if not golisopod_sources[index] then
		obs.script_log(obs.LOG_ERROR,"this source dont exist")
		return false
	end

	local instance = obs.obs_scene_add(scene,golisopod_sources[index])
	if instance == nil then
		obs.script_log(obs.LOG_ERROR,"failed to add pod")
		return
	end
	table.insert(golisopod_instances,instance)

	obs.obs_source_release(source)
	obs.obs_scene_release(scene)
	return item
	--duty of caller to add to instance table
end

function script_update(settings)
	image_path = obs.obs_data_get_string(settings, "image_path")
	load_golisopods(image_path)
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

function script_load()
end
