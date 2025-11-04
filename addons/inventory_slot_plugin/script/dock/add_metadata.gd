@tool
extends PanelContainer

@onready var Ok: Button = $Center/VBox/hbox2/Ok
@onready var Cancel: Button = $Center/VBox/hbox2/Cancel

@onready var Name: LineEdit = $Center/VBox/hbox/Name
@onready var StringValue: LineEdit = $Center/VBox/hbox/String

var item_unique_id: int

func _on_name_text_changed(new_text: String) -> void:
	Ok.disabled = new_text == ""

func _on_ok_pressed() -> void:
	var inventory = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	var item = InventoryFile.search_item(inventory, get_parent().get_parent().my_class_name, get_parent().item_name)
	
	item.metadata[Name.text] = StringValue.text
	InventoryFile.push_inventory(inventory, Inventory.ITEM_PANEL_PATH)
	
	get_parent().item = item
	get_parent().update_visual()
	queue_free()

func _on_cancel_pressed() -> void:
	queue_free()
