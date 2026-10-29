obs = obslua
image_path = "~/Projects/golisopod_war/golisopods/"

scene_uuid = nil
output_group_uuid = nil

simulate = false

golisopod_instances = {}

function script_description()
	return "for my oomfie, Lynx <3"
end


function script_properties()
	local props = obs.obs_properties_create()
	return props
end

