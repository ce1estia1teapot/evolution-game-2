extends Node
class_name InvSlot


@export var item: Item = null
@export var contents: Array[Item] = []

func clear_slot():
	"""
	Clears the slot, resetting the item type and contents array.
	"""
	
	item = null
	contents = []

func withdraw_item(p_item: Item):
	contents.erase(p_item)
