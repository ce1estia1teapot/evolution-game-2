@icon("res://Assets/Icons/fingerprint-solid.svg")
extends Area3D
class_name InteractionComponent

"""
This component is intended to make an object interactable when intersected by an InteractionRay.

When object hovered over, root of tree should:
	1. Apply the interaction highlight shader to the object
	2. Display the proper type of interaction prompt (basic, weapon, detailed, machine)

When interact key pressed on object, component should:
	1. Apply the object's "interact" function as defined in this component. Open GUI for machines/chests,
	pick up stack in the case of dropped items
"""

signal interaction_hovered(interact_target: InteractionComponent, interact_author: InteractionRay)
signal interaction_queue_free()

@export_category("General")
@export var interaction_mode: Enums.InteractionComponentMode

@export_category("Dropped Item Settings")
@export var stack_size: int :
	get(): return stack_size if interaction_mode != Enums.InteractionComponentMode.MACHINE else null
	set(value): stack_size = value

func _ready() -> void:
	self.area_entered.connect(on_area_entered)

""" Signal Callbacks """
#region Signal Callbacks
func on_area_entered(author: Node):
	"""
	This function is called whenever another node (author) enters the area.
	
	If author is an InteractionRay, 
	"""
	
	if author is InteractionRay:
		interaction_hovered.emit(self, author)
#endregion

""" Utility Functions """
func get_root_parent() -> Node3D:
	return self.get_parent().get_parent()

func remove_from_ground() -> void:
	self.interaction_queue_free.emit()
