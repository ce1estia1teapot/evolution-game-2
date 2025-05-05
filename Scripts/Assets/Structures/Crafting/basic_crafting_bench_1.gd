extends Node3D

""" ====  ==== """

""" ==== References ==== """
# Nodes
@onready var n_camera : Camera3D = $BenchCamera
@onready var n_interact_component : InteractComponent = $Components/InteractComponent

@onready var n_conveyor_area: Area3D = $Tools/Conveyor/ConveyorArea

@onready var n_hopper_spawn_area: Area3D = $Tools/Hopper/HopperSpawnArea
@onready var n_hopper_spawnables_holder : Node3D = $Tools/Hopper/Spawnables

@onready var n_finish_bin_area: Area3D = $Tools/FinishBin/FinishBinArea

# Reference Positions
@onready var n_player_standing_position : Node3D = $ReferencePoints/PlayerStandingPosition

""" ==== Parameters ==== """
@export var spawn_scene : PackedScene
@export var conveyor_item_speed_mps : float = 0.25

var actions_of_interest : Array[String] = [
	"quit",
	
	"left",
	"right",
	"jump",
	
	"action_num_1",
	"action_num_2",
	"action_num_3",
	"action_num_4",
]
var current_interactor : PlayerAvatar
var current_mode : Enums.CraftingBenchModes
var state_flags : Array[Enums.StateFlags] = []

""" ==== Built-Ins ==== """
func _ready() -> void:
	
	# Signal Connections
	n_interact_component.interacted.connect(on_interact_component_interacted)
	
	n_finish_bin_area.body_entered.connect(on_finish_bin_entered)

func _unhandled_key_input(event: InputEvent) -> void:
	"""
	Handles player control inputs meant for the bench.
	
	Checks:
		1. Check the event against the InputEvents of iterest
		2. Check whether the bench is accepting control inputs
		3. Check whether there is a current interactor working w/ the bench
		4. If current_interactor, check that it is a PlayerAvatar
	Steps:
		1. Call the handle_input function
	"""
	
	# Checks/Guard clauses
	if not get_is_input_event_relevent(event):
		return
	if Enums.StateFlags.IGNORE_INPUTS in state_flags:
		return
	if self.current_interactor:
		if not (self.current_interactor is PlayerAvatar):
			return
	else:
		return
	
	# Handle Input
	handle_input(event)

""" ==== Utility Functions ==== """
func handle_input(p_input_event : InputEvent) -> void:
	"""
	Handles player control inputs to the bench
	
	1. Accepts the input event
	2. If it's one of the "left" or "right" direction actions, call the "move_conveyor_objects" function
	3. If it's the "jump" action, call "spawn_ball_at_hopper"
	4. 
	"""
	
	get_viewport().set_input_as_handled()
	if InputMap.action_has_event("left", p_input_event) or InputMap.action_has_event("right", p_input_event):
		#TODO
		pass
	if InputMap.action_has_event("jump", p_input_event):
		pass
	

func spawn_ball_at_hopper() -> void:
	"""
	This function is invoked by the input action that spawns spawn_scene.
	The function is intended to spawn a spawn_scene, move it to the hopper's location, and add it to the spawnables holder node on the hopper
	
	Checks:
		1. Is there already a ball in the spawn area?
	Steps:
		1. Instantiate spawn_scene
		2. Set the global_transform.origin on the spawn_scene to a random point in the hopper's spawn area
		3. Add the spawn_scene to the hoppers Spawnables holder
	"""
	
	var objs_in_spawn_area = n_hopper_spawn_area.get_overlapping_bodies()
	var is_balls_in_spawn_area = len(objs_in_spawn_area) and objs_in_spawn_area.any(func(obj): return obj.name == "BallTest")
	if is_balls_in_spawn_area:
		return
	
	var spawn_item = spawn_scene.instantiate()
	var spawn_location = get_random_point_in_box(n_hopper_spawn_area)
	
	spawn_item.global_transform.origin = spawn_location
	n_hopper_spawnables_holder.add_child(spawn_item)

func move_conveyor_objects(p_input_event : InputEvent, delta : float) -> void:
	"""
	This function moves all items on the conveyor left or right depending on the provided input event.
	
	Checks:
		1. If any object will fall off left side, stop all movement
	"""
	# Calculate Distance to Move based on delta
	var move_distance : float = delta * conveyor_item_speed_mps
	# Decide direction based on input event
	if InputMap.action_has_event("left", p_input_event):
		move_distance = move_distance * -1
	elif InputMap.action_has_event("right", p_input_event):
		pass
	else:
		move_distance = 0
	
	for body in n_conveyor_area.get_overlapping_bodies():
		body.position.x += move_distance
	
func get_random_point_in_box(area: Area3D) -> Vector3:
	var collision_shape = area.get_node("CollisionShape3D")
	var box_shape = collision_shape.shape as BoxShape3D
	var extents = box_shape.size / 2.0
	var local_x = randf_range(-extents.x, extents.x)
	var local_y = randf_range(-extents.y, extents.y)
	var local_z = randf_range(-extents.z, extents.z)
	var local_point = Vector3(local_x, local_y, local_z)
	return area.global_transform * local_point

func get_is_input_event_relevent(p_event : InputEvent) -> bool:
	"""
	Returns a bool reflecting whether the provided InputEvent represents
	an action found in the actions_of_interest parameter
	"""
	
	for action in actions_of_interest:
		if InputMap.event_is_action(p_event, action):
			return true
	return false

func set_state_flag(p_flag : Enums.StateFlags, p_boolean : bool) -> void:
	"""
	Adds or removes the state flag from list for ignoring control inputs from player.
	If current value matches input, nothing happens.
	"""
	
	var is_flag = p_flag in state_flags
	if p_boolean:
		if is_flag:
			pass
		else:
			state_flags.append(p_flag)
	else:
		if is_flag:
			state_flags.erase(p_flag)
		else:
			pass

func set_is_ignoring_interacts(p_boolean : bool) -> void:
	"""
	Adds or removes the state flag from list for ignoring interacts from player.
	If current value matches input, nothing happens.
	"""
	
	var ignore_input_flag = Enums.StateFlags.IGNORE_INTERACTS
	set_state_flag(ignore_input_flag, p_boolean)

func set_is_ignoring_input_events(p_boolean : bool) -> void:
	"""
	Adds or removes the state flag from list for ignoring input_events from player.
	If current value matches input, nothing happens.
	"""
	
	var ignore_input_flag = Enums.StateFlags.IGNORE_INPUTS
	set_state_flag(ignore_input_flag, p_boolean)
	
	set_process_input(not p_boolean)

func start_standby_mode() -> void:
	"""
	This function should handle making all the changes to get the bench into standby mode
	
	Checks:
		1. Is the bench already in standby mode?
	Steps:
		1. Arm any enabled lights so they begin to glow
	"""
	
	# Checks
	if current_mode == Enums.CraftingBenchModes.STANDBY:
		return

func release_player() -> void:
	"""
	This function should sort of do the opposite of the "on_interact_component_interacted" function.
	
	Where the other brings the player into the bench, this function should release them back to control
	of their character and update anything on the bench that needs to be changed when a player isn't 
	directly working with it.
	
	Checks:
		1. Is there a current interactor?
	Steps:
		1. Remove the 'IGNORE_INTERACTS' flag from state flags
		2. Add the 'IGNORE_INPUTS' flag to state flags
	"""

""" ==== Signal Callbacks ==== """
func on_interact_component_interacted(p_interaction_mode: Enums.InteractionComponentMode, p_interactor : PlayerAvatar):
	"""
	Handles the 'interacted' callback from the InteractComponent.
	
	Checks:
		1. Is the bench accepting interactions?
	Steps:
		1. Store the interactor in corresponding parameter
		2. Add the 'IGNORE_INTERACTS' flag to state flags to block out further interact attempts
		3. Remove the 'IGNORE_INPUTS' flag from state flags to allow the player to interact with the bench
		4. Grab the player camera / make the bench cam current
		5. Move player avatar to position in front of the bench
		6. Command PlayerAvatar to ignore control inputs
		7. Set bench to standby mode if not already
	"""
	
	# 1. 
	current_interactor = p_interactor
	
	# 2.
	self.set_is_ignoring_interacts(true)
	
	# 3.
	self.set_is_ignoring_input_events(false)
	
	# 4.
	n_camera.make_current()
	
	# 5.
	p_interactor.move_to_point(n_player_standing_position.position)
	
	# 6.
	p_interactor.set_is_ignoring_control_inputs(true)

func on_finish_bin_entered(p_body : Node):
	"""
	This callback will despawn the bodies that enter the Area3D associated with the FinishBin
	"""
	
	if p_body.name == "BallTest":
		p_body.queue_free()
