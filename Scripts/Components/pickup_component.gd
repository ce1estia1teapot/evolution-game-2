@icon("res://Assets/Icons/magnet-solid.svg")
extends Area3D
class_name PickupComponent

"""
This class handles 2 main functions:
	1. Allowing an entity to identify and pick up dropped items
	2. Defining dropped items and enabling their pickup.
"""

""" Exports """
@export_category("General Settings")

@export_category("Dropped Item Settings")
## Represents the mesh that will be shown on the ground if the component is set to drop mode
@export var dropped_mesh: Resource
@export var dropped_stack_size: int = 1

""" Signals """
signal items_grabbed(grabber: PickupComponent, grabbed_item: Item, grabbed_quant: int)


func _ready() -> void:
	# Signal connections
	self.area_entered.connect(on_own_area_entered)

func on_own_area_entered(p_target_area: Area3D):
	"""
	Checks incoming area for InteractionComponent and grabs ground item.
	"""
	
	# If target area is a pickup component and this pickup component is a grabber...
	if (p_target_area is InteractionComponent):
		grab_ground_item(p_target_area)

func grab_ground_item(p_target_area: InteractionComponent):
	"""
	Description:
		1. Emit a signal detailing what item was grabbed
		2. Remove it from the ground
	"""
	
	self.items_grabbed.emit(self, p_target_area.get_root_parent(), p_target_area.stack_size)
	p_target_area.remove_from_ground()
