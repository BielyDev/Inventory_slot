@tool
extends PanelContainer

@onready var Name: Label = $Hbox/Name
@onready var Value: LineEdit = $Hbox/Value

var item_panel_node: PanelContainer
var metadata_name: String
var dic: Dictionary
var item: Dictionary
var inventory: Dictionary

func _ready() -> void:
	item = item_panel_node.item
	
	Name.text = metadata_name
	Value.text = item.metadata[metadata_name]

func _on_delete_pressed() -> void:
	inventory = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	item = InventoryFile.search_item(inventory, item_panel_node.get_parent().my_class_name, item_panel_node.item_name)
	item.metadata.erase(metadata_name)
	InventoryFile.push_inventory(inventory, Inventory.ITEM_PANEL_PATH)
	
	item_panel_node.item = item
	item_panel_node.update_visual()


func _on_value_text_submitted(new_text: String) -> void:
	inventory = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	item.metadata[metadata_name] = new_text
	InventoryFile.push_inventory(inventory, Inventory.ITEM_PANEL_PATH)
	item_panel_node.update_visual()
