extends DroppedItem
class_name RockDrop

@onready var n_interact_component: InteractComponent = $Components/InteractComponent

func _ready() -> void:
	n_interact_component.interacted.connect(_on_interact_component_interacted)
	
	# Set interact component's interact prompt to be whatever is in the associated item, if anything
	if associated_item:
		if associated_item.interact_message:
			n_interact_component.interact_prompt = associated_item.interact_message

func _on_interact_component_interacted(p_interaction_mode: Enums.InteractionComponentMode):
	if p_interaction_mode == Enums.InteractionComponentMode.PRIMARY:
		gather_item()

func gather_item() -> void:
	"""
	This function should: 
		1. despawn the RockDrop
		2. Emit a PlayerSignalBus message indicating that a RockItem has been collected (which is received by 
		the player class, initiating an insert of the provided item into their InventoryComponent)
	"""
	
	PlayerSignalBus.gatherable_collected.emit(associated_item)
	
	self.queue_free()
