@tool

extends TypePanel

enum SELECTION {ICON,SCENE}

const ADD_METADATA = preload("res://addons/inventory_slot_plugin/scenes/dock/add_metadata.tscn")
const METADATA = preload("res://addons/inventory_slot_plugin/scenes/dock/metadata.tscn")

@onready var icon: Button = %Icon
@onready var edit_item_name: LineEdit = %item_name
@onready var scene: Button = %scene
@onready var id_unique: Button = $Vbox/TopBar/Hbox/id_unique
@onready var top_bar: PanelContainer = $Vbox/TopBar
@onready var hbox: HBoxContainer = $Vbox/Hbox
@onready var id: SpinBox = %id
@onready var description: TextEdit = %description
@onready var metadata: VBoxContainer = $Vbox/Hbox/Panel/Vbox/Bar/Vbox/metadata


var item_name: String
var item: Dictionary
var selection: int


func _ready() -> void:
	hbox.hide()


func start(_item_name: String,_item: Dictionary) -> void:
	icon.icon = load(_item.icon)
	item_name = _item_name
	item = _item
	scene.text = _item.scene
	
	update_visual()

func update_visual() -> void:
	edit_item_name.text = item_name
	id_unique.text = str(int(item.unique_id)," - ",item_name)
	id.value = int(item.unique_id)
	description.text = item.description
	
	for child: Control in metadata.get_children():
		child.queue_free()
	
	for meta: String in item.metadata:
		var meta_intance = METADATA.instantiate()
		
		meta_intance.metadata_name = meta
		meta_intance.item_panel_node = self
		
		metadata.add_child(meta_intance)



func call_file_dialog(filters: Array) -> void:
	var explorer = EditorFileDialog.new()
	
	explorer.file_selected.connect(file_selection)
	explorer.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	explorer.filters = filters
	
	add_child(explorer)
	explorer.popup_file_dialog()


func file_selection(path: String) -> void:
	var inventory = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	match selection:
		SELECTION.ICON:
			icon.icon = load(path)
			
			item = InventoryFile.search_item(inventory,get_parent().my_class_name,item_name)
			item.icon = path
			InventoryFile.push_inventory(inventory, Inventory.ITEM_PANEL_PATH)
		SELECTION.SCENE:
			scene.text = path
			
			item = InventoryFile.search_item(inventory,get_parent().my_class_name,item_name)
			item.scene = path
			InventoryFile.push_inventory(inventory, Inventory.ITEM_PANEL_PATH)



func _on_scene_pressed() -> void:
	selection = SELECTION.SCENE
	call_file_dialog(["*tscn"])
func _on_icon_pressed() -> void:
	selection = SELECTION.ICON
	call_file_dialog(["*png","*svg","*jpg"])


func _on_id_unique_gui_input(event: InputEvent) -> void:
	move_panel(event,self,top_bar,get_parent())
	
	update_visual()




func _on_item_name_text_submitted(new_text: String) -> void:
	var inventory = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	edit_item_name.release_focus()
	
	changed_item_name(inventory,get_parent().my_class_name,item_name,new_text)
	InventoryFile.push_inventory(inventory, Inventory.ITEM_PANEL_PATH)
	
	item_name = new_text
	update_visual()

func _on_max_amount_value_changed(value: float) -> void:
	var inventory = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	item = InventoryFile.search_item(inventory,get_parent().my_class_name,item_name)
	item.max_amount = int(value)
	InventoryFile.push_inventory(inventory, Inventory.ITEM_PANEL_PATH)


func _on_description_text_changed() -> void:
	var inventory = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	item = InventoryFile.search_item(inventory,get_parent().my_class_name,item_name)
	item.description = description.text
	
	InventoryFile.push_inventory(inventory, Inventory.ITEM_PANEL_PATH)


func _on_remove_pressed() -> void:
	var inventory = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	InventoryFile.remove_item(inventory,get_parent().my_class_name,item_name)
	InventoryFile.push_inventory(inventory, Inventory.ITEM_PANEL_PATH)
	
	queue_free()

func _on_edit_name_pressed() -> void:
	id_unique.NodeVisible.show()
	
	edit_item_name.grab_focus()
	edit_item_name.select_all()


func _on_add_metadata_pressed() -> void:
	var add_popup = ADD_METADATA.instantiate()
	add_popup.item_unique_id = item.unique_id
	
	add_child(add_popup)
