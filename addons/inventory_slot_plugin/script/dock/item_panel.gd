@tool

extends TypePanel

enum SELECTION {ICON,SCENE}

@onready var icon: Button = %Icon
@onready var edit_item_name: LineEdit = %item_name
@onready var scene: Button = %scene
@onready var id_unique: Button = $Vbox/TopBar/Hbox/id_unique
@onready var top_bar: PanelContainer = $Vbox/TopBar
@onready var hbox: HBoxContainer = $Vbox/Hbox
@onready var id: SpinBox = %id
@onready var description: TextEdit = %description


var item_name: String
var item: Dictionary
var selection: int


func _ready() -> void:
	hbox.hide()


func start(_item_name: String,_item: Dictionary) -> void:
	icon.icon = load(_item.icon)
	item_name = _item_name
	item = _item
	
	update_visual()

func update_visual() -> void:
	edit_item_name.text = item_name
	id_unique.text = str(item.unique_id," - ",item_name)
	id.value = item.unique_id
	description.text = item.description



func call_file_dialog(filters: Array) -> void:
	var explorer = EditorFileDialog.new()
	
	explorer.file_selected.connect(file_selection)
	explorer.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	explorer.filters = filters
	
	add_child(explorer)
	explorer.popup_file_dialog()


func file_selection(path: String) -> void:
	var inventory = InventoryFile.pull_inventory(InventoryFile.ITEM_PANEL_PATH)
	
	match selection:
		SELECTION.ICON:
			icon.icon = load(path)
			
			InventoryFile.search_item(inventory,get_parent().my_class_name,item_name).icon = path
			InventoryFile.push_inventory(inventory, InventoryFile.ITEM_PANEL_PATH)
		SELECTION.SCENE:
			scene.text = path
			
			InventoryFile.search_item(inventory,get_parent().my_class_name,item_name).scene = path
			InventoryFile.push_inventory(inventory, InventoryFile.ITEM_PANEL_PATH)



func _on_scene_pressed() -> void:
	selection = SELECTION.SCENE
	call_file_dialog(["*tscn"])
func _on_icon_pressed() -> void:
	selection = SELECTION.ICON
	call_file_dialog(["*png","*svg","*jpg"])


func _on_id_unique_gui_input(event: InputEvent) -> void:
	move_panel(event,self,top_bar,get_parent())
	
	update_visual()



func _on_delete_pressed() -> void:
	var inventory = InventoryFile.pull_inventory(InventoryFile.ITEM_PANEL_PATH)
	
	InventoryFile.remove_item(inventory,get_parent().my_class_name,item_name)
	InventoryFile.push_inventory(inventory, InventoryFile.ITEM_PANEL_PATH)
	
	queue_free()


func _on_item_name_text_submitted(new_text: String) -> void:
	var inventory = InventoryFile.pull_inventory(InventoryFile.ITEM_PANEL_PATH)
	
	edit_item_name.release_focus()
	
	changed_item_name(inventory,get_parent().my_class_name,item_name,new_text)
	InventoryFile.push_inventory(inventory, InventoryFile.ITEM_PANEL_PATH)
	
	item_name = new_text
	update_visual()

func _on_max_amount_value_changed(value: float) -> void:
	var inventory = InventoryFile.pull_inventory(InventoryFile.ITEM_PANEL_PATH)
	
	InventoryFile.search_item(inventory,get_parent().my_class_name,item_name).max_amount = int(value)
	InventoryFile.push_inventory(inventory, InventoryFile.ITEM_PANEL_PATH)


func _on_description_text_changed() -> void:
	var inventory = InventoryFile.pull_inventory(InventoryFile.ITEM_PANEL_PATH)
	
	InventoryFile.search_item(inventory,get_parent().my_class_name,item_name).description = description.text
	InventoryFile.push_inventory(inventory, InventoryFile.ITEM_PANEL_PATH)
