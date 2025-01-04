extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

@export var nav_box: CSGBox3D

func _ready() -> void:	
	MainSignalBus.sandbox_generate_new_random_nav_pos.connect(on_sandbox_generate_new_random_nav_pos)


func _physics_process(delta: float) -> void:
	var next_position = navigation_agent_3d.get_next_path_position()
	var next_position_local = next_position - global_position
	var direction = next_position_local.normalized()
	
	velocity = direction * 5.0
	move_and_slide()

func generate_position() -> Vector3:
	var random_position := Vector3.ZERO
	
	random_position.x = randf_range(-5.0, 5.0)
	random_position.z = randf_range(-5.0, 5.0)
	
	return random_position


func move_to(p_position: Vector3):
	"""
	Moves the agent to the provided coordinates
	"""
	
	navigation_agent_3d.set_target_position(p_position)

func on_sandbox_generate_new_random_nav_pos():
	var new_position = generate_position()
	move_to(new_position)
