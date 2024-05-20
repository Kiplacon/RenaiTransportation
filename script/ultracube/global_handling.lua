local ultracube_globals = {}

function ultracube_globals.setup_prototypes()
	local cube_list = remote.call("Ultracube", "cube_item_prototypes")
	local irreplaceable_list = remote.call("Ultracube", "irreplaceable_item_prototypes")
	global.Ultracube = {prototypes = {
		cube = {},
		irreplaceable = {}
	}}
	-- Conversion back to Set
	for _, name in ipairs(cube_list) do
		global.Ultracube.prototypes.cube[name] = true
	end
	for _, name in ipairs(irreplaceable_list) do
		global.Ultracube.prototypes.irreplaceable[name] = true
	end
	log("Ultracube init/config_changed set the following data: ".. game.table_to_json(global.Ultracube))
end

return ultracube_globals