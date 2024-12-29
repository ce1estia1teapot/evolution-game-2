extends Character
class_name PlayerAvatar

""" ==== CHILD NODES ==== """
@onready var n_head: Node3D = $Head
@onready var n_camera: Camera3D = $Head/Camera3D
@onready var n_collision_shape: CollisionShape3D = $CollisionShape3D
@onready var n_overhead_detector: ShapeCast3D = $OverheadDetector

""" ==== SETTINGS ===="""
@export_category("Player Settings")
@export_group("Gameplay")
@export var fall_damage_threshold: int = 5

@export_group("Movement")
@export var speed = 5.0
@export var acceleration = 16
@export var jump_velocity = 8
@export var crouch_height: float = 2.0
@export var crouch_speed: float = 8.0

@export_group("Camera")
@export var camera_sensitivity: float = 0.1
@export var camera_min_angle: float = -80.0
@export var camera_max_angle: float = 80.0

""" ==== Attributes ==== """
var m_look_rot: Vector2
var player_gravity: Vector3
var stand_height: float
var old_vel: float = 0.0

func _ready() -> void:
	stand_height = n_collision_shape.shape.height
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
		elif Input.is_action_pressed("crouch") or n_overhead_detector.is_colliding():
			crouch(delta, false)
		else:
			crouch(delta, true)

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
	
	var diff = velocity.y - old_vel
	if (diff > fall_damage_threshold) and (old_vel < 0):
		print("Fall damage taken: {dam}".format({"dam": diff}))
	old_vel = velocity.y

func crouch(p_delta: float, p_reverse: bool = false):
	var target_height: float = crouch_height if not p_reverse else stand_height
	
	# Shrink the collision shape
	n_collision_shape.shape.height = lerp(n_collision_shape.shape.height, target_height, crouch_speed * p_delta)
	# Reposition the shape according to new height
	n_collision_shape.position.y = lerp(n_collision_shape.position.y, target_height * 0.5, crouch_speed * p_delta)
	# Reposition head (and camera) to new height
	n_head.position.y = lerp(n_head.position.y, target_height - 1, crouch_speed * p_delta)
	
