@tool
extends Node

signal new_item(_item_panel: Dictionary , _item_inventory: Dictionary, _panel_slot: Dictionary)
signal new_data(_item_panel: Dictionary , _item_inventory: Dictionary ,_system_slot: Dictionary)
signal discart_item(_item_panel: Dictionary ,_item_inventory: Dictionary  ,_system_slot: Dictionary)
signal item_leftlover(_item_panel: Dictionary ,_item_inventory: Dictionary ,amount: int)
signal item_entered_panel(_item: Dictionary ,_new_id: int)
signal item_exiting_panel(_item: Dictionary ,_out_id: int)
signal button_slot_changed(_slot: Control ,_move: bool)
signal new_data_global()
signal changed_panel_data()

signal reload_dock()

enum ERROR {
	SLOT_BUTTON_VOID = -2,
	VOID = -1,
	SUCESS,
	NO_SPACE_FOR_ITEM_IN_SLOTS,
	ITEM_LEFT_WITH_FULL_SLOTS,
	INVALID_ARGUMENTS,
	SEPARATER
}

#Ready value ===
@onready var PLUGIN_PATH: String = str(get_script().resource_path.get_base_dir(),"/../..")
@onready var IMAGE_DEFAULT: String = str(PLUGIN_PATH,"/assets/item_image/life.png")


var ITEM_PANEL_PATH: String
var ITEM_INVENTORY_PATH: String
var PANEL_SLOT_PATH: String
var JSON_PATH: String
var SAVE_PATH: String
var ITEM_SETTINGS: String

var item_selected: Control # Item node dos slots

## Sub functions ================================================================

func _ready() -> void:
	OS.request_permissions()
	
	InventorySystem._update_path()
	
	set_process_input(false)
	
	process_mode = PROCESS_MODE_ALWAYS
	button_slot_changed.connect(_function_slot_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		item_selected.global_position = event.position - (item_selected.size/2)


##===============================================================================
# New functions ================================================================

## Main functions ----------------------------------------
func add_item(_panel_id: int, _item_unique_id: int, _amount: int = 1, _slot: int = -1, _id: int = -1, _unique: bool = false, _metadata: Variant = null):
	
	var _item_panel = InventoryFile.search_item_id(_panel_id ,_item_unique_id )
	var item_inventory
	
	if InventoryFile.is_json(ITEM_INVENTORY_PATH):
		item_inventory = search_item(_panel_id ,_item_panel.unique_id )
	
	var _panel_slot = InventoryFile.get_panel(_panel_id)
	
	if !_error(_panel_slot,_item_panel):
		return [ERROR.INVALID_ARGUMENTS]
	
	if _unique:
		return _append_item_filter_slot_amount(_panel_slot , _item_panel, _amount, _slot, _id, _metadata)
	
	if _slot == ERROR.SLOT_BUTTON_VOID: # Para botoes vazios, normalmente craidos com o botao direito.
		var _new_item = _append_item(_panel_slot, _item_panel, _amount, ERROR.SLOT_BUTTON_VOID, -1,_metadata)
		
		return _new_item
	
	var _separate = _separate_item_one(_item_panel, _panel_slot, _amount, _metadata)
	
	if _separate is Array:
		return _separate
	
	if item_inventory is Dictionary:
		
		if item_inventory.amount == _item_panel.max_amount:
			
			var now_search_item = search_item_amount_min(_panel_slot.id, _item_panel.unique_id, _item_panel.max_amount)#  asd
			
			if now_search_item != null:
				item_inventory = now_search_item
		
		if _amount + item_inventory.amount > _item_panel.max_amount:
			
			return _filter_add_full_item(_item_panel ,item_inventory ,_panel_slot ,_amount ,_metadata)
			
		else:
			
			item_inventory.amount = item_inventory.amount + _amount
			
			_refresh_data_item(item_inventory ,_item_panel )
			
			return item_inventory
	
	return _append_item_filter_slot_amount(_panel_slot ,_item_panel ,_amount ,_slot ,_id ,_metadata )

func remove_item(_panel_id: int, _id: int = -1, _slot: int = -1) -> bool:
	
	var _all_item_inventory: Array = InventoryFile.list_all_item_inventory(_panel_id)
	
	for _items_inventory in _all_item_inventory:
		if _slot != -1:
			if _items_inventory.slot == _slot:
				
				discart_item.emit(
					InventoryFile.search_item_id(_panel_id,_items_inventory.unique_id),
					_items_inventory,
					InventoryFile.get_panel(_panel_id)
					)
				
				InventoryFile.push_item_inventory(_items_inventory.id,{})
				return true
			continue
		
		if _items_inventory.id == _id:
			
			discart_item.emit(
				InventoryFile.search_item_id(_panel_id,_items_inventory.unique_id),
				_items_inventory,
				InventoryFile.get_panel(_panel_id)
				)
			
			InventoryFile.push_item_inventory(_items_inventory.id,{})
			return true
	
	return false

func set_panel_item(_item_id: int, _out_panel_id: int, _new_panel_id:int, _slot: int = -1, _unique: bool = false, _out_item_remove: bool = true):
	var _item_inventory: Dictionary = search_item_inventory(_item_id)
	
	if _out_item_remove:
		remove_item(_out_panel_id,_item_id)
	
	var _out_panel: Dictionary = InventoryFile.get_panel(_out_panel_id)
	var _new_panel: Dictionary = InventoryFile.get_panel(_new_panel_id)
	var _item_panel: Dictionary = InventoryFile.search_item_id(_out_panel.id,_item_inventory.unique_id)
	var _new_item: Dictionary = _item_inventory
	var _all_items_new_panel: Array = InventoryFile.list_all_item_inventory(_new_panel.id)
	
	
	if _new_panel.slot_amount == _all_items_new_panel.size() and _slot != ERROR.SLOT_BUTTON_VOID:
		if _unique:
			return ERROR.NO_SPACE_FOR_ITEM_IN_SLOTS
		else:
			var _search_item = search_item_amount_min(_new_panel.id,_item_inventory.unique_id,_item_panel.max_amount)
			
			if _search_item != null:
				
				if _item_panel.max_amount > _search_item.amount:
					
					var _size = _item_panel.max_amount - _search_item.amount
					_search_item.amount = _search_item.amount + _size
					_item_inventory.amount -= _size
					
					InventoryFile.push_item_inventory(_item_inventory.id,_item_inventory)
					InventoryFile.push_item_inventory(_search_item.id,_search_item)
					
					new_data.emit(_item_panel,_item_inventory,InventoryFile.get_panel(_item_inventory.panel_id))
					new_data.emit(InventoryFile.search_item_id(_search_item.panel_id,_search_item.unique_id),_search_item,InventoryFile.get_panel(_search_item.panel_id))
					
					new_data_global.emit()
					
					return new_item
		
		return ERROR.NO_SPACE_FOR_ITEM_IN_SLOTS
	
	if _out_panel == null or new_data == null: return
	
	var _result = add_item(
		_new_panel.id,
		_new_item.unique_id,
		_new_item.amount,
		_slot,
		_new_item.id,
		_unique,
		_new_item.metadata
	)
	
	if _result is Array:
		match _result[0]:
			ERROR.NO_SPACE_FOR_ITEM_IN_SLOTS:
				return _result
			ERROR.ITEM_LEFT_WITH_FULL_SLOTS:
				_new_item.amount = _result[1]
				
				new_data_global.emit()
				item_leftlover.emit(_new_item,_new_panel,_result[1])
				return _result
	
	item_entered_panel.emit(_new_item,_new_panel_id)
	item_exiting_panel.emit(_new_item,_out_panel_id)

func set_slot_item(_panel_item: Dictionary, _item_inventory: Dictionary, _slot: int = -1, _unique: bool = true) -> void:
	var _new_item_inventory: Dictionary = _item_inventory
	
	remove_item(_panel_item.id,_item_inventory.id)
	add_item(
		_panel_item.id,
		_new_item_inventory.unique_id,
		_new_item_inventory.amount,
		_slot,
		_item_inventory.id,
		_unique,
		_item_inventory.metadata,
	)

func changed_slots_items(item_one: Dictionary, item_two: Dictionary) -> void:
	var one = item_one
	var two = item_two
	
	var panel_one = InventoryFile.get_panel(search_panel_id_item(item_one.id))
	var panel_two = InventoryFile.get_panel(search_panel_id_item(item_two.id))
	
	remove_item(panel_one.id,item_one.id)
	remove_item(panel_two.id,item_two.id)
	
	add_item(panel_one.id,one.unique_id,one.amount,two.slot,one.id,true)
	add_item(panel_two.id,two.unique_id,two.amount,one.slot,two.id,true)

func get_metadata(_item_unique_id: int) -> Dictionary:
	var inventory = InventoryFile.pull_inventory(ITEM_PANEL_PATH)
	
	var item = InventoryFile.search_item(inventory, InventoryFile.get_class_name(_item_unique_id), InventoryFile.get_item_name(_item_unique_id))
	if item != null:
		return item.metadata
	else:
		printerr("get_metadata - item_unique_id is invalid.")
		return {}
#---------------------------------------------------------

## Searchs -----------------------------------------------
func search_item(_item_unique_id: int = -1, _slot: int = -1):
	var _all_items: Dictionary = InventoryFile.pull_inventory(ITEM_INVENTORY_PATH)
	
	if _slot != -1:
		for _item: String in _all_items:
			if _all_items.get(_item).slot == _slot:
				return _all_items.get(_item)
	
	for _item: String in _all_items:
		if _all_items.get(_item).unique_id == _item_unique_id:
			return _all_items.get(_item)
	
	return null

func search_item_in_panel(_panel_id: int, _item_unique_id: int = -1, _slot: int = -1):
	var _all_items: Dictionary = InventoryFile.pull_inventory(ITEM_INVENTORY_PATH)
	
	for _item: String in _all_items:
		var item: Dictionary = _all_items.get(_item)
		
		print(" : ",search_panel_id_item(item.id))
		if search_panel_id_item(item.id) == _panel_id:
			if _slot != -1:
				if item.slot == _slot:
					return _all_items.get(_item)
			
			if _item_unique_id != -1:
				if item.unique_id == _item_unique_id:
					return _all_items.get(_item)
	
	return null

func search_item_inventory(_item_id: int = -1):
	var _all_items: Dictionary = InventoryFile.pull_inventory(ITEM_INVENTORY_PATH)
	
	for _item: String in _all_items:
		if _all_items.get(_item).id == _item_id:
			return _all_items.get(_item)
	
	return null

func search_item_amount_min(_panel_id: int, _item_unique_id: int, _max_amount: int):
	var _all_items = InventoryFile.list_all_item_inventory(_panel_id)
	
	for _item: Dictionary in _all_items:
		
		if _item.unique_id == _item_unique_id:
			if _item.amount < _max_amount:
				
				return _item
	
	return null

func search_void_slot(_panel_id: int) -> int:
	var _all_slot: Array = []
	
	for _item: Dictionary in InventoryFile.list_all_item_inventory(_panel_id):
		_all_slot.append(_item.slot)
	
	_all_slot.sort()
	
	for _pass_slot: int in range( InventoryFile.get_panel(_panel_id).slot_amount ):
		if _pass_slot >= _all_slot.size():
			return _pass_slot
		if _pass_slot != _all_slot[_pass_slot]:
			return _pass_slot
	
	return -1

func search_panel_id_item(_item_id: int) -> int:
	var _all_items_inventory: Dictionary = InventoryFile.pull_inventory(ITEM_INVENTORY_PATH)
	
	for _item: String in _all_items_inventory:
		if _all_items_inventory.get(_item).id == _item_id:
			
			return _all_items_inventory.get(_item).panel_id
	
	return -1

#---------------------------------------------------------

## Adjustments -------------------------------------------
func _is_item_valid(array_item: Array, path: String) -> bool:
	for item in array_item:
		if item.path == path:
			return true
	
	return false

func _function_slot_changed(slot, move) -> void:
	
	set_process_input(is_instance_valid(slot) and move == true)
	
	if is_instance_valid(item_selected):
		
		if item_selected.item_inventory.slot == ERROR.SLOT_BUTTON_VOID:
			if item_selected.item_inventory.amount == 0:
				item_selected.get_parent().queue_free()
	
	if move:
		item_selected = slot.item_node
	else:
		item_selected = null

func _append_item(_panel_slot: Dictionary, _item_panel: Dictionary, _amount: int, _slot: int = ERROR.VOID, _id: int = -1, _metadata: Variant = null):
	var _now_slot: int = _slot
	var _all_items_inventory = InventoryFile.pull_inventory(ITEM_INVENTORY_PATH)
	
	if _slot == ERROR.VOID:
		_slot = search_void_slot(_panel_slot.id)
	if _id == -1:
		_id = randi()
	
	_all_items_inventory[str(_id)] = {
		"unique_id" = _item_panel.unique_id,
		"id" = _id,
		"panel_id" = _panel_slot.id,
		"slot" = _slot,
		"amount" = _amount,
		"metadata" = _metadata,
	}
	
	InventoryFile.push_inventory(_all_items_inventory,ITEM_INVENTORY_PATH)
	
	new_item.emit(_item_panel,_all_items_inventory.get(str(_id)),_panel_slot)
	
	return _all_items_inventory

func _separater_item_amount(amount: int, max_amount: int, filter_amount: int):
	var amount_slots = float(amount) / max_amount
	var separate_amount = []
	var next: int = 0
	var max: int = 0
	
	# se tiver muito item
	for i in filter_amount: # Separa quantos slots são necessarios e a quantidade que irar ir pra cada slot
		
		next += 1
		max += 1
		
		if next == max_amount:
			separate_amount.append(next)
			
			next = 0
		
		
		if max == filter_amount:
			separate_amount.append(next)
	
	return separate_amount

func _separate_item_one(_item_panel: Dictionary, _panel_slot: Dictionary, _amount: int, _metadata: Variant):
	
	var _panel_slot_amount: int = InventoryFile.list_all_item_inventory(_panel_slot.id).size()
	
	if _item_panel.max_amount == 1:
		
		var _items: Array = []
		
		if _panel_slot_amount == _panel_slot.slot_amount:
			item_leftlover.emit({}, _item_panel, 1 )
			return [ERROR.ITEM_LEFT_WITH_FULL_SLOTS, 1 ]
		
		for i in _amount:
			if _panel_slot_amount != _panel_slot.slot_amount:
				_items.append(_append_item(_panel_slot,_item_panel , 1 ,-1,-1, _metadata))
			else:
				item_leftlover.emit({},_item_panel,_amount-i)
				return [ERROR.ITEM_LEFT_WITH_FULL_SLOTS,_amount-i]
		
		if _items.size() >= 1:
			return [ERROR.SUCESS,_items]
	
	return false

func _error(_panel_slot,_item_panel) -> bool:
	if _panel_slot.size() == 0:
		printerr("invalid panel_id! ")
		return false
	if _item_panel == null:
		printerr("invalid item_unique_id! ")
		return false
	
	return true

func _filter_add_full_item(_item_panel: Dictionary ,_item_inventory: Dictionary ,_panel_slot: Dictionary ,_amount: int ,_metadata: Variant ):
	
	var _apply_now_item: int = (_item_panel.max_amount - _item_inventory.amount)
	var _filter_amount: int = _amount - _apply_now_item
	
	if InventoryFile.list_all_item_inventory(_panel_slot.id).size() == _panel_slot.slot_amount:
		
		_item_inventory.amount = _item_panel.max_amount
		
		_refresh_data_item(_item_inventory,_item_panel)
		
		item_leftlover.emit(_item_inventory, _item_panel, _amount - _apply_now_item)
		
		return [ERROR.ITEM_LEFT_WITH_FULL_SLOTS, _amount - _apply_now_item]
	else:
		
		_item_inventory.amount = _item_panel.max_amount
		
		var separate_amount = _separater_item_amount(_amount, _item_panel.max_amount, _filter_amount)
		
		_refresh_data_item(_item_inventory,_item_panel)
		
		for new_amount in separate_amount: 
			add_item(_panel_slot.id ,_item_panel.unique_id ,new_amount ,-1 ,-1 ,true ,_metadata )
	
	return _item_inventory

func _refresh_data_item(_item_inventory: Dictionary, _item_panel: Dictionary) -> void:
	var panel_slot = InventoryFile.get_panel_with_unique_id(_item_inventory.unique_id)
	
	if _item_inventory.slot == ERROR.SLOT_BUTTON_VOID:
		remove_item(
			_item_inventory.panel_id,
			_item_inventory.id
		)
		
	else:
		InventoryFile.push_item_inventory(_item_inventory.id,_item_inventory)
	
	new_data.emit(_item_panel,_item_inventory,panel_slot)
	new_data_global.emit()

func _append_item_filter_slot_amount(_panel_slot ,_item_panel ,_amount ,_slot ,_id , _metadata):
	
	if _panel_slot.slot_amount == InventoryFile.list_all_item_inventory(_panel_slot.id).size():
		return [ERROR.NO_SPACE_FOR_ITEM_IN_SLOTS,0]
	
	if _amount > _item_panel.max_amount:
		var _add_number: int = 0
		var _add_array: Array = [ERROR.SEPARATER]
		
		for sep in _amount:
			_add_number += 1
			
			if _add_number == _item_panel.max_amount:
				_add_array.append(_append_item(_panel_slot,_item_panel,_add_number,_slot,_id,_metadata))
				_add_number = 0
		
		if _add_number != 0 and _add_number != _item_panel.max_amount:
			_add_array.append(_append_item(_panel_slot,_item_panel,_add_number,_slot,_id,_metadata))
		
		return _add_array
	
	return _append_item(_panel_slot,_item_panel,_amount,_slot,_id,_metadata)

#---------------------------------------------------------


##===============================================================================
