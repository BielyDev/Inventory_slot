class_name InventorySystem extends Node

const INVENTORY_SYSTEM = "res://config.json"


static func push_system_file(_path_mode: int,_path: String,_extension: StringName) -> void:
	var _system = InventorySystem._get_settings_system()
	var _out_system = _system.duplicate()
	
	_system.path_mode = _path_mode
	_system.path = _path
	_system.extension = _extension
	
	InventoryFile.push_inventory(_system,INVENTORY_SYSTEM)
	
	var _out_path: String = str(_out_system.path,"/save")
	var _create: bool
	
	if DirAccess.dir_exists_absolute(_out_path) and DirAccess.get_files_at(_out_path).size() >= 3:
		_move_json_path(
			_out_system.path,
			_system.path,
			_path_mode,
			_path,
			_extension
		)
	else:
		_create = true
		_create_json_path(
			_path,
			_extension,
			true
		)
	
	if _out_system.extension != _extension and !_create:
		_rename_extension_files( _extension)
	
	_create_file_system(_path_mode,_path,_extension)


static func _create_json_path(_path: String,_extension: StringName, _create_files: bool = true) -> void:
	if _extension == "":
		_extension = "json"
	
	if !DirAccess.dir_exists_absolute(_path):
		printerr("This folder doesn't exist, it's impossible to create a directory!")
		return
	
	var _json_path: String = _path
	var _save_path: String = str(_json_path,"/save")
	
	var _file_system_path: String = str(_save_path,"/system.",_extension)
	var _file_save_path: String = str("user://inventory.",_extension)
	var _file_class_path: String = str(_save_path,"/class.",_extension)
	var _file_panel_path: String = str(_save_path,"/panel.",_extension)
	
	var dir = DirAccess.open(_path)
	
	dir.make_dir(_save_path)
	
	if !_create_files: return
	
	var _file_system: FileAccess = FileAccess.open(_file_system_path,FileAccess.WRITE)
	var _file_save: FileAccess = FileAccess.open(_file_save_path,FileAccess.WRITE)
	var _file_class: FileAccess = FileAccess.open(_file_class_path,FileAccess.WRITE)
	var _file_panel: FileAccess = FileAccess.open(_file_panel_path,FileAccess.WRITE)
	
	InventoryFile.push_inventory(_file_system_default_value(),_file_system_path)
	InventoryFile.push_inventory({},_file_save_path)
	InventoryFile.push_inventory({},_file_class_path)
	InventoryFile.push_inventory({},_file_panel_path)
	
	print("Save create")

static func _create_file_system(_path_mode: int = 0,_path: String = "res://",_extension: StringName = "json") -> void:
	
	var _new_file: Dictionary = {
		"path_mode" : _path_mode,
		"path" : _path,
		"extension" : _extension
		}
	
	InventoryFile.push_inventory(_new_file,INVENTORY_SYSTEM)
	_update_path()

static func _rename_extension_files(_extension: String) -> void:
	var files = [
		Inventory.ITEM_PANEL_PATH,
		Inventory.ITEM_INVENTORY_PATH,
		Inventory.PANEL_SLOT_PATH,
		Inventory.ITEM_SETTINGS
	]
	
	for file: String in files:
		DirAccess.copy_absolute(
			file,
			str(file.replace(file.get_file().get_extension(),""),_extension)
		)
		DirAccess.remove_absolute(file)
	
	print("Files renamed")

static func _move_json_path(_out_path: String,_new_path: String,_path_mode: int,_path: String,_extension: StringName) -> void:
	if _out_path == _new_path:
		return
	
	var out_item_panel_path: String = Inventory.ITEM_PANEL_PATH
	var out_settings: String = Inventory.ITEM_SETTINGS
	var out_panel_slot_path: String = Inventory.PANEL_SLOT_PATH
	var out_item_inventory_path: String = Inventory.ITEM_INVENTORY_PATH
	var out_save_path: String = Inventory.SAVE_PATH
	
	_create_json_path(
		_path,
		_extension,
		false
	)
	
	_update_path()
	
	DirAccess.copy_absolute(out_item_panel_path,Inventory.ITEM_PANEL_PATH)
	DirAccess.copy_absolute(out_settings,Inventory.ITEM_SETTINGS)
	DirAccess.copy_absolute(out_panel_slot_path,Inventory.PANEL_SLOT_PATH)
	DirAccess.copy_absolute(out_item_inventory_path,Inventory.ITEM_INVENTORY_PATH)
	
	DirAccess.remove_absolute(out_item_panel_path)
	DirAccess.remove_absolute(out_settings)
	DirAccess.remove_absolute(out_panel_slot_path)
	DirAccess.remove_absolute(out_item_inventory_path)
	DirAccess.remove_absolute(out_save_path)
	DirAccess.remove_absolute(_out_path)
	
	print("Save moved")

static func _get_settings_system() -> Dictionary:
	return InventoryFile.pull_inventory(INVENTORY_SYSTEM)

static func get_save_path() -> String:
	var _file = _get_settings_system()
	
	var _path = _file.path
	
	return _path

static func _file_system_default_value() -> Dictionary:
	return {
		"amount_anchor": 0,
		"amount_show_being_one": false,
		"amount_text": "Amount",
		"description_amount_show": true,
		"description_description": true,
		"description_name_item": true
	}

static func _update_path() -> void:
	Inventory.JSON_PATH = str(get_save_path(),"/")
	Inventory.SAVE_PATH = Inventory.JSON_PATH + "save/"
	Inventory.ITEM_SETTINGS = Inventory.SAVE_PATH + "system." + _get_settings_system().extension
	Inventory.ITEM_PANEL_PATH = Inventory.SAVE_PATH + "class." + _get_settings_system().extension
	Inventory.PANEL_SLOT_PATH = Inventory.SAVE_PATH + "panel." + _get_settings_system().extension
	Inventory.ITEM_INVENTORY_PATH = "user://inventory." + _get_settings_system().extension
