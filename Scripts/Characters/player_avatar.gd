extends Character
class_name PlayerAvatar

""" ==== CHILD NODES ==== """
# Head parts
@onready var n_head: Node3D = $Head
@onready var n_camera: Camera3D = $Head/Camera3D
@onready var n_interact_ray: InteractRay = $Head/InteractRay

# Components
@onready var n_health_component: HealthComponent = $Components/HealthComponent

# UI Stuff
@onready var n_player_interface_manager: PlayerInterfaceManager = $PlayerInterfaceManager
@onready var n_hurt_overlay: TextureRect = $PlayerInterfaceManager/HurtOverlay
@onready var n_health_bar_hud: HealthBarHUD = $PlayerInterfaceManager/HealthBarHUD
@onready var n_death_screen_test: Panel = $PlayerInterfaceManager/DeathScreenTest

# Misc.
@onready var n_collision_shape: CollisionShape3D = $CollisionShape3D
@onready var n_overhead_detector: ShapeCast3D = $OverheadDetector


""" ==== SETTINGS ===="""
@export_category("Player Settings")
@export_group("Gameplay")
@export var fall_damage_threshold: int = 5

@export_group("Movement")
@export var speed = 5.0
@export var movement_acceleration = 16
@export var jump_velocity = 8
@export var crouch_height: float = 2.0
@export var crouch_speed: float = 8.0

@export_group("Camera")
@export var camera_sensitivity: float = 0.1
@export var camera_min_angle: float = -80.0
@export var camera_max_angle: float = 80.0

""" ==== Debug Settings ==== """
var blanket_debug_switch: bool = true

var is_printing_inputs_to_console: bool = true if blanket_debug_switch else false
var is_printing_health_debug_messages: bool = true if blanket_debug_switch else false

""" ==== Attributes ==== """
var m_look_rot: Vector2
var player_gravity: Vector3
var stand_height: float
var old_vel: float = 0.0

# Flags
var is_taking_control_input: bool = true

# Tweens
var attribute_placeholder

""" ==== Built-in Functions ==== """
#region Built-in Functions
func _ready() -> void:
	# Signal Connections
	PlayerSignalBus.inventory_interacted.connect(_on_inventory_interacted)
	
	n_health_component.attack_received.connect(on_health_component_attack_received)
	n_health_component.health_changed.connect(on_health_component_health_changed)
	n_health_component.health_is_zero.connect(on_health_component_health_is_zero)
	n_health_component.knockback_received.connect(on_health_component_knockback_received)
	
	# Setting defaults
	n_health_bar_hud.set_healthbar_value(n_health_component.HEALTH)
	stand_height = n_collision_shape.shape.height
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Updating player data based on WorldState
	if self.name in WorldState.WORLD_STATE:
		var state_dict: Dictionary = WorldState.WORLD_STATE.get(self.name)
		_parse_world_state_dict(state_dict)
	else:
		_update_in_world_state()
	


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		m_look_rot.y -= camera_sensitivity * event.relative.x
		m_look_rot.x -= camera_sensitivity * event.relative.y
		m_look_rot.x = clampf(m_look_rot.x, camera_min_angle, camera_max_angle)
	
	_handle_gameplay_input()

func _parse_world_state_dict(p_dict: Dictionary) -> void:
	"""
	This function is intended to parse a WorldState state dictionary and set the relevant
	values on the Player and its components accordingly.
	"""
	# == Extracting Values ==
	# Health Component Values
	var health: float = p_dict.get(Enums.WorldStateKeys.HEALTH)
	
	if is_printing_health_debug_messages:
		print("_parse_world_state_dict read value: {temp}".format({"temp": health}))
	
	# == Setting Values ==
	# Health Component Values
	n_health_component.HEALTH = health

func _generate_world_state_dict() -> Dictionary:
	"""
	This function is meant to standardize the construction and transmission of 
	WorldState update dictionaries.
	
	Each component should have a similar method defined
	"""
	var report_dict: Dictionary = {
		Enums.WorldStateKeys.HEALTH : n_health_component.HEALTH
	}
	
	return report_dict

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
		velocity.x = lerp(velocity.x, direction.x * speed, movement_acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, movement_acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, movement_acceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, movement_acceleration * delta)
	
	move_and_slide()
	n_head.rotation_degrees.x = m_look_rot.x
	rotation_degrees.y = m_look_rot.y
	
	# Fall Damage calculation and application
	var diff = velocity.y - old_vel
	if (diff > fall_damage_threshold) and (old_vel < 0):
		fall_damage(diff - fall_damage_threshold)
		crouch(delta)
	old_vel = velocity.y

func _handle_gameplay_input() -> void:
	if Input.is_action_just_pressed("quit"):
		if is_printing_inputs_to_console:
			print("Detected input: 'quit'")		
		get_tree().quit()
		
	elif Input.is_action_just_pressed("mouse_capture_mode_toggle"):
		if is_printing_inputs_to_console:
			print("Detected input: 'mouse_capture_mode_toggle'")
			
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	elif Input.is_action_just_pressed("interact_primary"):
		n_interact_ray.attempt_interact(Enums.InteractionComponentMode.PRIMARY)

func _update_in_world_state() -> void:
	var update_dict: Dictionary = _generate_world_state_dict()
	
	WorldState.update_world_state(self.name, update_dict)
#endregion

""" ==== Misc. Functions ==== """
#region Misc. Functions
func crouch(p_delta: float, p_reverse: bool = false):
	var target_height: float = crouch_height if not p_reverse else stand_height
	
	# Shrink the collision shape
	n_collision_shape.shape.height = lerp(n_collision_shape.shape.height, target_height, crouch_speed * p_delta)
	# Reposition the shape according to new height
	n_collision_shape.position.y = lerp(n_collision_shape.position.y, target_height * 0.5, crouch_speed * p_delta)
	# Reposition head (and camera) to new height
	n_head.position.y = lerp(n_head.position.y, target_height - 1, crouch_speed * p_delta)

func fall_damage(p_damage: float) -> void:
	"""
	This function is intended to handle the player taking fall damage, as defined in
	_physics_process()
	
	1. Print message to console
	2. Send damage to health component for processing
	3. Animate the damage overlay
	"""
	
	# Print message
	print("Raw fall damage: {dam}".format({"dam": p_damage}))
	
	# Send damage to health component
	n_health_component.apply_damage(p_damage, Enums.DamageTypes.FALL)

#endregion



""" ==== Signal Callbacks ===="""
#region Signal Bus Callbacks
func _on_inventory_interacted(p_target: CollisionObject3D, p_inventory: InventoryComponent):
	print("Player interacted with " + p_target.name)

#endregion


#region Health Component Signal Callbacks
func on_health_component_attack_received(p_health_component: HealthComponent, p_damages: Dictionary, p_total_damage: float, p_attack: Attack):
	#TODO: Implement this
	pass

func on_health_component_health_changed(p_health_component: HealthComponent, p_old_health: float, p_new_health: float) -> void:
	"""
	This functions handles when the Health value of the player's health component is changed
	
	1. Update the value for the player's health in the world state
	2. Tell UI manager to animate properly
	"""
	
	n_player_interface_manager.on_damage_taken(p_new_health)
	
	# Update in world state
	_update_in_world_state()

func on_health_component_health_is_zero(p_health_component: HealthComponent) -> void:
	"""
	Called when the HealthComponent's HEALTH value reaches zero.
	
	It should:
		1. Set is_taking_control_input to 'false'
		2. Tell the interface_manager to show_death_screen()
	"""
	
	is_taking_control_input = false
	n_player_interface_manager.show_death_screen()

func on_health_component_knockback_received(p_knockback_force: float) -> void:
	#TODO: Implement this
	pass
#endregion
