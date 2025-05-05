extends RayCast3D
class_name InteractRay

var prompt = ""

func _physics_process(delta: float) -> void:
	
	if is_colliding():
		var collider = get_collider()
		
		if collider is InteractComponent:
			prompt = collider.interact_prompt
		else:
			prompt = collider.name
	else:
		prompt = ""

func attempt_interact(p_interaction_mode: Enums.InteractionComponentMode, p_interactor : PlayerAvatar) -> void:
	if is_colliding():
		var collider = get_collider()
		
		if collider is InteractComponent:
			collider.interact(p_interaction_mode, p_interactor)
