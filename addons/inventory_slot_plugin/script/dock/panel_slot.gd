@tool
extends TypePanel

@onready var option_class: OptionButton = %Class
@onready var panel_name: LineEdit = %PanelName
@onready var id: SpinBox = %Id
@onready var amount: SpinBox = %Amount
@onready var tittle: ButtonVisible = %Tittle
@onready var settings: VBoxContainer = $Vbox/Settings
@onready var top_bar: HBoxContainer = $Vbox/TopBar
@onready var id_warning: Label = $Vbox/Settings/ID/Warning

var out_panel_name: String
var panel_slot_controller: Control
var option_selected: int 

func _ready() -> void:
	settings.hide()
	
	Inventory.changed_panel_data.connect(update_option_class)
	update_option_class()


func start(_panel_name: StringName,_id: int, slot_amount: int, class_unique: String) -> void:
	out_panel_name = _panel_name
	panel_name.text = _panel_name
	id.value = _id
	amount.value = slot_amount
	
	for i in option_class.item_count:
		if option_class.get_item_text(i) == class_unique:
			option_class.select(i)
	
	
	tittle.text = str(_id," - ",_panel_name)


func update_option_class() -> void:
	option_class.clear()
	option_class.add_item("all")
	
	var _all_class = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	for _class in _all_class:
		option_class.add_item(_class)
	
	option_class.select(option_selected)


func change_panel_name(new_name: String) -> void:
	panel_name.release_focus()
	
	var panels = InventoryFile.pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	changed_dic_name(panels,out_panel_name,new_name)
	
	InventoryFile.push_inventory(panels,Inventory.PANEL_SLOT_PATH)
	
	out_panel_name = new_name
	
	tittle.text = str(id.value," - ",out_panel_name)
	
	Inventory.changed_panel_data.emit()

func _on_remove_pressed() -> void:
	var panels = InventoryFile.pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	for panel in panels:
		if panels.get(panel).id == id.value:
			panels.erase(panel)
	
	InventoryFile.push_inventory(panels ,Inventory.PANEL_SLOT_PATH)
	Inventory.changed_panel_data.emit()
	
	queue_free()


func _on_panel_name_text_submitted(new_text: String) -> void:
	change_panel_name(new_text)


func _on_id_value_changed(value: float) -> void:
	var panels = InventoryFile.pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	for panel in panels:
		if panel != out_panel_name:
			if panels.get(panel).id == value:
				id_warning.show()
				return
	
	id_warning.hide()
	
	var dic = search_dic(panels,out_panel_name)
	
	dic.id = value
	
	InventoryFile.push_inventory(panels, Inventory.PANEL_SLOT_PATH)
	tittle.text = str(value," - ",out_panel_name)
	
	Inventory.changed_panel_data.emit()


func _on_amount_value_changed(value: float) -> void:
	var panels = InventoryFile.pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	var dic = search_dic(panels,out_panel_name)
	
	dic.slot_amount = value
	
	InventoryFile.push_inventory(panels, Inventory.PANEL_SLOT_PATH)
	
	Inventory.changed_panel_data.emit()


func _on_class_item_selected(index: int) -> void:
	option_selected = index
	
	var panels = InventoryFile.pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	var dic = search_dic(panels,out_panel_name)
	
	dic.class_unique = option_class.get_item_text(index)
	
	InventoryFile.push_inventory(panels, Inventory.PANEL_SLOT_PATH)
	
	Inventory.changed_panel_data.emit()


func _on_tittle_gui_input(event: InputEvent) -> void:
	move_panel(event,self,top_bar,get_parent())

func _on_panel_name_focus_exited() -> void:
	change_panel_name(panel_name.text)

func _on_edit_name_pressed() -> void:
	tittle.NodeVisible.show()
	
	panel_name.grab_focus()
	panel_name.select_all()
