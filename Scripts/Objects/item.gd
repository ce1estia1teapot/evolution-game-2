extends Resource
class_name Item

"""
This class is intended to represent all items. Wood and stone, as well as
gear (weapons and equipment).

It can support added pickup component to allow item to be dropped to the ground
and inserted into inventory.
"""

""" Attributes """
@export_group("General")
@export var item_name: String = "[DEFAULT ITEM NAME]"
@export var item_id: Enums.ItemID
@export var stack_size: int = 1
@export var interact_message: String = ""

""" === FLAGS === """
@export_group("Item Flags")
@export var is_interactable = false
@export var is_equipped = false

""" === Utility Functions """
#region Utility Functions
func _update_in_world_state() -> void:
	"""
	This function is meant to standardize the construction and transmission of 
	WorldStateReport objects by Entities.
	"""
	pass



#endregion
