extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@export var nav_box: CSGBox3D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var random_position := Vector3.ZERO
		if nav_box:
			var width = nav_box.size.x
			var depth = nav_box.size.z
			var platform_x = nav_box.global_position.x
			var platform_z = nav_box.global_position.z
			
			random_position.x = randf_range(platform_x-(width/2), platform_x-(width/2))
			random_position.z = randf_range(platform_z-(depth/2), platform_z-(depth/2))
		else:
			random_position.x = randf_range(-5.0, 5.0)
			random_position.z = randf_range(-5.0, 5.0)
		navigation_agent_3d.set_target_position(random_position)

func _physics_process(delta: float) -> void:
	var next_position = navigation_agent_3d.get_next_path_position()
	var next_position_local = next_position - global_position
	var direction = next_position_local.normalized()
	
	velocity = direction * 5.0
	move_and_slide()
