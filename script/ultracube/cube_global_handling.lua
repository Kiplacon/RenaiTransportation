local ultracube_globals = {}

function ultracube_globals.setup_prototypes()
	storage.Ultracube = {prototypes = {
		cube = remote.call("Ultracube", "cube_item_prototypes"),
		irreplaceable = remote.call("Ultracube", "irreplaceable_item_prototypes")
	}}
	log("Ultracube init/config_changed set the following data: ".. helpers.table_to_json(storage.Ultracube))
end

return ultracube_globals
