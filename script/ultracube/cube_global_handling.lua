local ultracube_globals = {}

function ultracube_globals.setup_prototypes()
	global.Ultracube = {prototypes = {
		cube = remote.call("Ultracube", "cube_item_prototypes"),
		irreplaceable = remote.call("Ultracube", "irreplaceable_item_prototypes")
	}}
	log("Ultracube init/config_changed set the following data: ".. game.table_to_json(global.Ultracube))
end

return ultracube_globals