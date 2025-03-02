extends Area3D
class_name InteractComponent

"""
This class exposes an interact prompt to an observer, as well as "interact" functions that may be called.

The intended use is as follows:
	1. An observer requests the interact prompt to display somehow
	2. Observer accepts gameplay input corresponding to primary,
	secondary, or tertiary interact ('E', 'F', or otherwise)
	3. This gameplay input commands the observer's InteractRay to
	call the 'interact' method below.
	4. The 'interacted' signal is called in every case, but the
	provided argument will be a value from Enums.InteractionComponentMode,
	specifying which interact type was used
	5. The component's parent should connect to this signal and define
	callback. NOT ALL INTERACT TYPES NEED TO BE USED. If the parent
	only wants to define a primary interact, they may simply 'pass' in
	the event that one of the other arguments is provided

SUMMARY:
	The different interaction functions are to be defined by the component's PARENT.
	The component only exposes the ability to display a prompt and accept interact
	requests.
"""

signal interacted(p_interaction_mode: Enums.InteractionComponentMode)

@export var interact_prompt: String = ""
## Intended to mark whether the parent body is gatherable (like a stick or rock) in which case interact behavior may be defined here
## in the component

func interact(p_interaction_mode: Enums.InteractionComponentMode) -> void:
	
	self.interacted.emit(p_interaction_mode)
