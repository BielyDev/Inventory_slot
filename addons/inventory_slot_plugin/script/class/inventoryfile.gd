class_name InventoryFile extends Node

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
	var _all_class: Dictionary = pull_inventory(Inventory.ITEM_PANEL_PATH)
	var _array_class: Array = []
	
	for _class in _all_class:
		_array_class.append(_all_class.get(_class))
	
	return _array_class

static func list_all_item_inventory(_panel_id: int = -1) -> Array:
	var _inventory = pull_inventory(Inventory.ITEM_INVENTORY_PATH)
	
	var _all_items: Array
	
	if _panel_id == -1:
		for _items in _inventory:
			
			_all_items.append(_inventory.get(_items))
	else:
		for _items in _inventory:
			
			if _panel_id == _inventory.get(_items).panel_id:
				_all_items.append(_inventory.get(_items))
	
	return _all_items

static func list_all_item_panel(_class_name: StringName = "") -> Array:
	var _inventory = pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	var _all_items: Array
	
	if _class_name == "":
		for _class in _inventory:
			for _items in _inventory.get(_class):
				
				_all_items.append(_inventory.get(_class).get(_items))
	else:
		for _class in _inventory:
			if _class == _class_name:
				
				for _items in _inventory.get(_class):
					
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
	var _items = pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	for _all in _items:
		for _item in _items.get(_all):
			
			var item = _items.get(_all).get(_item)
			
			if _items.get(_all).get(_item).unique_id == _item_unique_id:
				
				return _items.get(_all).get(_item)
	
	printerr("Item ",_item_unique_id," not found!")

static func search_class_name(_class_name: String):
	var _all_class: Dictionary = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	for _class in _all_class:
		if _class == _class_name:
			return _all_class.get(_class)

static func get_panel_id(_unique_id: int) -> int:
	var all_items = pull_inventory(Inventory.ITEM_INVENTORY_PATH)
	
	for i in all_items:
		if all_items.get(i).unique_id == _unique_id:
			return all_items.get(i).panel_id
	
	return -1

static func get_panel(_panel_id: int) -> Dictionary:
	var _panel = pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	for _all in _panel:
		
		if _panel.get(_all).id == _panel_id:
			return _panel.get(_all)
	
	return {}

static func get_panel_with_unique_id(_unique_id: int) -> Dictionary:
	var all_items = pull_inventory(Inventory.ITEM_INVENTORY_PATH)
	
	for i in all_items:
		if all_items.get(i).unique_id == _unique_id:
			
			return all_items.get(i)
	
	return {}

static func get_item_name(_unique_id_item: int) -> StringName:
	
	var _all_items = pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	for _class in _all_items:
		for _items in _all_items.get(_class):
			
			if _all_items.get(_class).get(_items).unique_id == _unique_id_item:
				
				return _items
	
	return ""

static func get_item_panel(_unique_id_item: int) -> Dictionary:
	
	var _all_items = pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	for _class in _all_items:
		for _items in _all_items.get(_class):
			
			if _all_items.get(_class).get(_items).unique_id == _unique_id_item:
				
				return _all_items.get(_class).get(_items)
	
	return {}

static func get_class_name(_unique_id_item: int) -> StringName:
	
	var _all_items = pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	for _class in _all_items:
		for _items in _all_items.get(_class):
			
			if _all_items.get(_class).get(_items).unique_id == _unique_id_item:
				
				return _class
	
	return ""

static func get_item_panel_id_void() -> int:
	var _all_id_array: Array = []
	
	var _all_id_dictionary = pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	for _all_class in _all_id_dictionary:
		if _all_id_dictionary.get(_all_class) is float: continue
		
		for _items in _all_id_dictionary.get(_all_class):
			_all_id_array.append(_all_id_dictionary.get(_all_class).get(_items).unique_id)
	
	
	_all_id_array.sort()
	
	for _id in range(_all_id_array.size()):
		if _id != _all_id_array[_id]:
			return _id
	
	return _all_id_array.size()

static func list_all_panel() -> Array:
	var _all_panel = pull_inventory(Inventory.PANEL_SLOT_PATH)
	var _array_panel: Array
	
	for _panel in _all_panel:
		_array_panel.append(_all_panel.get(_panel))
	
	return _array_panel

## File Whrite ==================================================================

static func push_inventory(_dic: Dictionary,_path: String) -> void:
	var file = FileAccess.open(_path,FileAccess.WRITE)
	
	file.store_string(JSON.stringify(_dic,"\t"))
	file.close()

static func push_item_inventory(_item_id: int, _item_inventory: Dictionary) -> bool:
	var _all_items = pull_inventory(Inventory.ITEM_INVENTORY_PATH)
	
	if _item_inventory == {}:
		_all_items.erase(str(_item_id))
		push_inventory(_all_items, Inventory.ITEM_INVENTORY_PATH)
		
		return true
	else:
		_all_items[str(_item_id)] = _item_inventory
		push_inventory(_all_items, Inventory.ITEM_INVENTORY_PATH)
		
		return true
	
	return false

static func remove_all_item_inventory() -> void:
	for panel in InventoryFile.list_all_panel():
		for item in InventoryFile.list_all_item_inventory(panel.id):
			Inventory.remove_item(panel.id,item.id)

static func _changed_item_name(_inventory: Dictionary,_class_name: String,_out_item_name: String,_new_item_name: String) -> void:
	
	var item = InventoryFile.search_item(_inventory,_class_name,_out_item_name)
	
	if item != null:
		var new_value = _inventory.get(_class_name).get(_out_item_name)
		
		_inventory.get(_class_name).erase(_out_item_name)
		_inventory.get(_class_name)[_new_item_name] = new_value

static func _changed_class_name(_dic: Dictionary,_out_item_name: String,_new_item_name: String) -> void:
	
	var item = search_class_name(_out_item_name)
	
	if item != null:
		var new_value = _dic.get(_out_item_name)
		
		_dic.erase(_out_item_name)
		_dic[_new_item_name] = new_value

## Dictionary ==================================================================

static func new_item_panel(_class_name: String,_icon_path: String = Inventory.IMAGE_DEFAULT,_amount: int = 1,_description: String = "",_path_scene: String = "res://") -> Dictionary:
	var _new_inventory = pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	for _class in _new_inventory:
		
		if _class == _class_name:
			
			_new_inventory.get(_class)[str("new_item_",get_item_panel_id_void())] = {
				"unique_id" : get_item_panel_id_void(),
				"icon" : _icon_path,
				"max_amount" : _amount,
				"description" : _description,
				"scene" : _path_scene
			}
	
	return _new_inventory

static func new_class(_class_name: String) -> Dictionary:
	var _new_inventory = pull_inventory(Inventory.ITEM_PANEL_PATH)
	
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
