extends RayCast3D
class_name InteractRay

@onready var n_prompt: Label = $Prompt


func _physics_process(delta: float) -> void:
	n_prompt.text = ""
	
	if is_colliding():
		var collider = get_collider()
		
		if collider is InteractComponent:
			n_prompt.text = collider.interact_prompt_message
		else:
			n_prompt.text = collider.name
		

func attempt_interact() -> void:
	if is_colliding():
		var collider = get_collider()
		
		if collider is InteractComponent:
			collider.interact()
