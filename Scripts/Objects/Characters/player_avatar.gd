extends Character
class_name PlayerAvatar

""" ==== CHILD NODES ==== """
@onready var n_head: Node3D = $Head
@onready var n_camera: Camera3D = $Head/Camera3D

""" ==== SETTINGS ===="""
@export_category("Player Settings")
@export_group("Movement")
@export var speed = 5.0
@export var acceleration = 16
@export var jump_velocity = 8

@export_group("Camera")
@export var camera_sensitivity: float = 0.1
@export var camera_min_angle: float = -80.0
@export var camera_max_angle: float = 80.0

""" ==== Attributes ==== """
var m_look_rot: Vector2
var player_gravity: Vector3

func _ready() -> void:
	player_gravity = get_gravity()
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		m_look_rot.y -= camera_sensitivity * event.relative.x
		m_look_rot.x -= camera_sensitivity * event.relative.y
		m_look_rot.x = clampf(m_look_rot.x, camera_min_angle, camera_max_angle)
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, acceleration * delta)
	
	move_and_slide()
	n_head.rotation_degrees.x = m_look_rot.x
	rotation_degrees.y = m_look_rot.y
