class_name InventoryFile extends Node

const IMAGE_DEFAULT = "res://addons/inventory_slot_plugin/assets/item_image/life.png"
const JSON_PATH = "res://addons/inventory_slot_plugin/json/"
const SYSTEM_PATH = JSON_PATH + "system/"
const SAVE_PATH = JSON_PATH + "save/"
const ITEM_PANEL_PATH = SYSTEM_PATH + "item_panel.json"
const PANEL_SLOT_PATH = SYSTEM_PATH + "panel_slot.json"
const ITEM_SETTINGS = SYSTEM_PATH + "item_settings.json"
const ITEM_INVENTORY_PATH = SAVE_PATH + "inventory.json"


## File Learns ===================================================================

static func is_json(_path: String) -> bool:
	if !FileAccess.file_exists(_path):
		return false
	else:
		var file = FileAccess.open(_path ,FileAccess.READ)
		
		if file.get_as_text() == null:
			return false
		if file.get_as_text() == "":
			return false
		
		var json = JSON.parse_string(file.get_as_text())
		
		if json is Dictionary == false:
			return false
		
		if json.size() >= 1 and json != {}:
			
			return true
	
	return false

static func pull_inventory(_path: String) -> Dictionary:
	if is_json(_path):
		var file = FileAccess.open(_path,FileAccess.READ)
		
		var all_class: Dictionary = JSON.parse_string(file.get_as_text())
		file.close()
		
		return all_class
	
	return {}

static func list_all_class() -> Array:
	var _all_class: Dictionary = pull_inventory(ITEM_PANEL_PATH)
	var _array_class: Array = []
	
	for _class in _all_class:
		_array_class.append(_all_class.get(_class))
	
	return _array_class

static func list_all_item_inventory(_panel_id: int = -1) -> Array:
	var _inventory = pull_inventory(ITEM_INVENTORY_PATH)
	
	var _all_items: Array
	
	if _panel_id == -1:
		for _items in _inventory:
			
			_all_items.append(_inventory.get(_items))
	else:
		for _items in _inventory:
			
			if _panel_id == _inventory.get(_items).panel_id:
				_all_items.append(_inventory.get(_items))
	
	return _all_items

static func list_all_item_panel(_panel_id: int = -1) -> Array:
	var _inventory = pull_inventory(ITEM_PANEL_PATH)
	
	var _all_items: Array
	
	if _panel_id == -1:
		for _class in _inventory:
			for _items in _inventory.get(_class):
				
				_all_items.append(_inventory.get(_class).get(_items))
	else:
		for _class in _inventory:
			for _items in _inventory.get(_class):
				
				if _panel_id == _inventory.get(_items).panel_id:
					_all_items.append(_inventory.get(_class).get(_items))
	
	return _all_items

static func search_item(_inventory: Dictionary,_class_name: String,_item_name: String):
	for _class in _inventory:
		
		if _class_name == _class:
			
			for _item in _inventory.get(_class):
				
				if _item_name == _item:
					
					return _inventory.get(_class_name).get(_item_name)
	
	printerr("Item ",_item_name," not found!")

static func search_item_id(_panel_id: int, _item_unique_id: int = -1):
	var _items = pull_inventory(ITEM_PANEL_PATH)
	
	for _all in _items:
		for _item in _items.get(_all):
			
			var item = _items.get(_all).get(_item)
			
			if _items.get(_all).get(_item).unique_id == _item_unique_id:
				
				return _items.get(_all).get(_item)
	
	printerr("Item ",_item_unique_id," not found!")

static func get_panel_id(_unique_id: int) -> int:
	var all_items = pull_inventory(ITEM_INVENTORY_PATH)
	
	for i in all_items:
		if all_items.get(i).unique_id == _unique_id:
			return all_items.get(i).panel_id
	
	return -1

static func get_panel(_panel_id: int) -> Dictionary:
	var _panel = pull_inventory(PANEL_SLOT_PATH)
	
	for _all in _panel:
		
		if _panel.get(_all).id == _panel_id:
			return _panel.get(_all)
	
	return {}

static func get_panel_with_unique_id(_unique_id: int) -> Dictionary:
	var all_items = pull_inventory(ITEM_INVENTORY_PATH)
	
	for i in all_items:
		if all_items.get(i).unique_id == _unique_id:
			
			return all_items.get(i)
	
	return {}

static func get_item_name(_unique_id_item: int) -> StringName:
	
	var _all_items = InventoryFile.pull_inventory(InventoryFile.ITEM_PANEL_PATH)
	
	for _class in _all_items:
		for _items in _all_items.get(_class):
			
			if _all_items.get(_class).get(_items).unique_id == _unique_id_item:
				
				return _items
	
	return ""

static func get_class_name(_unique_id_item: int) -> StringName:
	
	var _all_items = InventoryFile.pull_inventory(InventoryFile.ITEM_PANEL_PATH)
	
	for _class in _all_items:
		for _items in _all_items.get(_class):
			
			if _all_items.get(_class).get(_items).unique_id == _unique_id_item:
				
				return _class
	
	return ""

## File Whrite ==================================================================

static func push_inventory(_dic: Dictionary,_path: String) -> void:
	var file = FileAccess.open(_path,FileAccess.WRITE)
	
	file.store_string(JSON.stringify(_dic,"\t"))
	file.close()

static func push_item_inventory(_item_id: int, _item_inventory: Dictionary) -> bool:
	var _all_items = pull_inventory(ITEM_INVENTORY_PATH)
	
	if _item_inventory == {}:
		_all_items.erase(str(_item_id))
		push_inventory(_all_items, ITEM_INVENTORY_PATH)
		
		return true
	else:
		_all_items[str(_item_id)] = _item_inventory
		push_inventory(_all_items, ITEM_INVENTORY_PATH)
		
		return true
	
	return false

## Dictionary ==================================================================

static func new_item_panel(_class_name: String,_icon_path: String = InventoryFile.IMAGE_DEFAULT,_amount: int = 1,_description: String = "",_path_scene: String = "res://") -> Dictionary:
	var _new_inventory = pull_inventory(ITEM_PANEL_PATH)
	
	for _class in _new_inventory:
		
		if _class == _class_name:
			
			_new_inventory.get(_class)[str("new_item_",TypePanel.get_item_panel_id_void())] = {
				"unique_id" : TypePanel.get_item_panel_id_void(),
				"icon" : _icon_path,
				"max_amount" : _amount,
				"description" : _description,
				"scene" : _path_scene
			}
	
	return _new_inventory

static func new_class(_class_name: String) -> Dictionary:
	var _new_inventory = pull_inventory(ITEM_PANEL_PATH)
	
	_new_inventory[_class_name] = {}
	
	return _new_inventory

static func remove_item(_inventory: Dictionary,_class_name: String,_item_name: String) -> void:
	_inventory.get(_class_name).erase(_item_name)

static func remove_class(_inventory: Dictionary,_class_name: String) -> void:
	_inventory.erase(_class_name)

static func changed_dictionary_name(_dictionary: Dictionary,_class_name: String,_new_class_name: String) -> Dictionary:
	
	var new_value = _dictionary.get(_class_name)
	
	_dictionary.erase(_class_name)
	_dictionary[_new_class_name] = new_value
	
	return _dictionary

##====================================================================
