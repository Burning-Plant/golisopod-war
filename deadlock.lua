obs = obslua
image_path = "~/Projects/obs_deadlock/golisopods/"

scene_uuid = nil
output_group_uuid = nil

simulate = false

golisopod_instances = {}

function script_description()
	return "for my oomf, Lynx <3"
end


props = obs.obs_properties_create()

function script_properties() 
	obs.obs_properties_add_path(
		props,
		"image_path",
		"Image file",
		obs.OBS_PATH_FILE,
		"Image files (*.png *.jpg *.jpeg *.webp);;",
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

			local name obs.obs_source_get_uuid(scene_source)
			obs.obs_source_release(scene_source)	

			return name
		end
	)

	obs.obs_properties_add_list(
		prop,
		"destination_group",
		"Destination Group",
		obs.OBS_COMBO_TYPE_LIST,
		obs.OBS_COMBO_FORMAT_STRING
	)
	obs.obs_properties_add_button(
		props,
		"repopulate_group",
		"Repopulate Destination List",
		function()
			--load scene
			--enumerate items
			--add items that are groups
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
	local golisopod = obs.obs_create_source(--blah blah blah)
	return golisopod
end

function script_update(settings)
	image_path = obs.obs_data_get_string(settings, "image_path")
	scene_uuid = obs.obs_data_get_string(settings, "destination_scene")
	local group_uuid = obs.obs_data_get_string(settings, "destination_group")
	output_group_uuid = obs.obs_get_source_by_uuid(group_uuid)
	simulate = obs.obs_data_get_bool(settings,"do_sim")
end

function add_golisopod(scene)
	--add item to scene
	--duty of caller to add to instance table
	return item
end

function script_unload()
	for i in golisopods do
		obs.obs_item_release(i)
	end
	obs.obs_properties_destroy(props)
end
