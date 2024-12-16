extends Character
class_name PlayerController

""" Child Nodes """
@onready var armature: Node3D = $Armature
@onready var hatchet: MetalHatchet = $Armature/Skeleton3D/HandSocketR/Equipment/metal_hatchet
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: StateMachine = $StateMachine

@onready var health_component: HealthComponent = $Components/HealthComponent
@onready var hitbox_component: HitboxComponent = $Components/HitboxComponent
@onready var inventory_component: InventoryComponent = $Components/InventoryComponent
@onready var char_stats_component: CharacterStatsComponent = $Components/StatsComponent
@onready var pickup_component: PickupComponent = $Components/PickupComponent

@onready var spring_arm_pivot: Node3D = $FirstPersonSpringArmPivot
@onready var spring_arm: SpringArm3D = $FirstPersonSpringArmPivot/SpringArm3D
@onready var interaction_ray: RayCast3D = $FirstPersonSpringArmPivot/SpringArm3D/FirstPersonCam/InteractionRay

""" === EXPORTS === """
# Movement
@export_category("Movement")
@export_group("Camera")
@export var SPRING_ARM_MAX_X_ROTATION: float = PI/2
@export var SPRING_ARM_MAX_Y_ROTATION: float = PI/2

@export_group("Character")
@export var SPEED = 5.0
@export var ACCELERATION = 0.15

@export_category("Interaction")
@export var interaction_range: float = 3.0

""" ==== STATE VARIABLES ==== """
@onready var m_current_state := state_machine.current_state
var m_mouse_mode := Input.mouse_mode

""" ==== SETTINGS ==== """
const DEFAULT_MOUSE_MODE = Input.MouseMode.MOUSE_MODE_CAPTURED

""" ==== MISC. ==== """
var m_explosion = preload("res://Scenes/Assets/a_explosion.tscn")

func _ready() -> void:
	""" Connect to relevant signals"""
	health_component.damage_taken.connect(on_damage_taken)
	health_component.health_is_zero.connect(on_health_is_zero)
	
	pickup_component.items_grabbed.connect(on_items_grabbed)
	
	""" Initializing player parameters to set values... """
	interaction_ray.target_position.y = interaction_range
	
	""" Setting default settings """
	Input.mouse_mode = DEFAULT_MOUSE_MODE

func _unhandled_input(event: InputEvent) -> void:
	# Process event in dedicated function
	handle_input_event(event)
	
	if event.is_action_pressed("ui_accept"):
		hatchet.m_weapon_comp.is_equipped = not hatchet.m_weapon_comp.is_equipped
		
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	""" Handling mouse input for camera rotation """
	if event is InputEventMouseMotion:
		# Rotate the pivot about the y-axis according to the (pixel space) x-motion of the mouse
		spring_arm_pivot.rotate_y(-event.relative.x * 0.005)
		# Do the opposite for the x-axis motion of the spring arm
		spring_arm.rotate_x(-event.relative.y * 0.005)
		
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -SPRING_ARM_MAX_X_ROTATION, SPRING_ARM_MAX_X_ROTATION)
		
	""" Handling mouse capture mode toggle """
	if Input.is_action_just_pressed("mouse_capture_mode_toggle"):
		if Input.mouse_mode == Input.MouseMode.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MouseMode.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MouseMode.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	
	if direction:
		# Update state to running state if not updated...
		if !(is_instance_of(m_current_state, PlayerRunningState)):
			state_machine.current_state.Transitioned.emit($StateMachine.current_state, "PlayerRunningState")
			m_current_state = state_machine.current_state
		
		# Calculate velocity...
		velocity.x = lerp(velocity.x, direction.x * SPEED, ACCELERATION)
		velocity.z = lerp(velocity.z, direction.z * SPEED, ACCELERATION)
		
		# Rotate armature to match velocity direction
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(-velocity.x, -velocity.z), ACCELERATION)
	else:
		if !(is_instance_of(m_current_state, PlayerIdleState)):
			state_machine.current_state.Transitioned.emit($StateMachine.current_state, "PlayerIdleState")
			m_current_state = state_machine.current_state
		
		velocity.x = lerp(velocity.x, 0.0, ACCELERATION)
		velocity.z = lerp(velocity.z, 0.0 * SPEED, ACCELERATION)
		
	animation_tree.set("parameters/RunSpeedFraction/blend_position", velocity.length()/SPEED)

	move_and_slide()


""" ==== UTILITY FUNCTIONS ==== """
func handle_input_event(p_event: InputEvent):
	if p_event.is_action_pressed("primary_action"):
		# 1. Do nothing if player is in menus
		pass
		
		# Spawn explosion at cursor on click


""" === Signal Callbacks === """
# Health Component Callbacks
func on_damage_taken(health_component: HealthComponent, damage: float, new_health: float, attack: Attack):
	print("Player Damage Taken!")
	PlayerSignalBus.player_damaged.emit(health_component,damage, new_health, attack)

func on_health_is_zero(health_component: HealthComponent):
	print("Player Health is zero!")

# Pickup Component Callbacks
func on_items_grabbed(grabber: PickupComponent, grabbed_item: Item, grabbed_quant: int):
	"""
	This function:
		1. Checks the grabbed item
		2. Attempts insertion into inventory component
			2a. If success, pass
			2b. If failed, spew items back out using pickup component
		3. Send signal to player signal bus detailing result of pickup
	"""
	var pickup_variables = {"name": grabbed_item.item_name, "quantity": grabbed_quant}
	print("Picked up {quantity}x {name}!".format(pickup_variables))
