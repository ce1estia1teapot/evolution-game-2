extends Node3D

""" ====  ==== """

""" ==== References ==== """
# Nodes
@onready var n_camera : Camera3D = $BenchCamera

@onready var n_spawner_timer: Timer = $NodeHolders/TimersHolder/SpawnerTimer
@onready var n_quit_timer: Timer = $NodeHolders/TimersHolder/QuitTimer
@onready var n_action_num_timer: Timer = $NodeHolders/TimersHolder/ActionNumTimer

@onready var n_interact_component : InteractComponent = $Components/InteractComponent
@onready var n_inventory_component: InventoryComponent = $Components/InventoryComponent

@onready var n_conveyor_area: Area3D = $Tools/Conveyor/ConveyorArea

@onready var n_hopper_spawn_area: Area3D = $Tools/Hopper/HopperSpawnArea
@onready var n_hopper_spawnables_holder : Node = $NodeHolders/SpawnablesHolder

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

var conveyor_moving : bool = false
var conveyor_move_event : InputEvent

var current_interactor : PlayerAvatar = PlayerAvatar.new()
var current_mode : Enums.CraftingBenchModes
var state_flags : Array[Enums.StateFlags] = []

""" ==== Built-Ins ==== """
func _ready() -> void:
	
	# Signal Connections
	n_interact_component.interacted.connect(on_interact_component_interacted)
	
	n_finish_bin_area.body_entered.connect(on_finish_bin_entered)

func _physics_process(delta: float) -> void:
	"""
	Handles the frame-to-frame physics process for the script
	
	Steps:
		1. If the conveyor is moving, grab the corresponding input
		event and move the conveyor
	"""
	
	if conveyor_moving:
		action_move_conveyor_objects(conveyor_move_event, delta)

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
	print_debug("Entered the Basic crafting bench _unhandled_key_input function")
	
	# Checks/Guard clauses
	print_debug("Checking guard clauses...")
	if not get_is_input_event_relevent(event):
		print_debug("Provided event was not relevant: {event}".format({"event": event}))
		return
	if Enums.StateFlags.IGNORE_INPUTS in state_flags:
		print_debug("Bench is ignoring input. Returning...")
		return
	if self.current_interactor:
		if not (self.current_interactor is PlayerAvatar):
			print_debug("Current interactor is not null, but it is not a PlayerAvatar. {avatar}".format({"avatar": current_interactor}))
			return
	else:
		print_debug("current_interactor is null. Returning...")
		return
	print_debug("Guard clauses passed.")
	
	# Handle Input
	handle_input(event)

""" ==== Utility Functions ==== """
func handle_input(p_input_event : InputEvent) -> void:
	"""
	Handles player control inputs to the bench
	
	Steps:
		1. Accepts the input event
		2. If it's one of the "left" or "right" direction actions:
			a. If it's currently pressed down:
				i. Set the "conveyor_moving" attribute to true, to later be used by "physics_process"
				ii. Set the "conveyor_move_event" attribute to the InputEvent
				iii. call the "action_move_conveyor_objects" function from "physics_process"
			b. When it is released:
				i. Set "conveyor_moving" to false
				ii. Set "conveyor_move_event" to null
			c. Either way, create and check for timer
		3. If it's the "jump" action, call "action_spawn_ball_at_hopper" and create and check for timer
		4. if it's the "quit" action, for now just get_tree().quit(). Eventually, call the "action_release_player" function. Create and check for timer
		5. If it's any one of the action_num_X actions, call action_engage_tool with the inputevent. Create and check for timer
	"""
	var action_num_1_cond = InputMap.action_has_event("action_num_1", p_input_event)
	var action_num_2_cond = InputMap.action_has_event("action_num_2", p_input_event)
	var action_num_3_cond = InputMap.action_has_event("action_num_3", p_input_event)
	var action_num_4_cond = InputMap.action_has_event("action_num_4", p_input_event)
	
	get_viewport().set_input_as_handled()
	
	if InputMap.action_has_event("left", p_input_event) or InputMap.action_has_event("right", p_input_event):
		print_debug("Identified a Left/Right Conveyor Move input: {event}".format({"event": p_input_event}))
		if p_input_event.is_action_pressed("left") or p_input_event.is_action_pressed("right"):
			if not conveyor_moving:
				conveyor_moving = true
			if not conveyor_move_event:
				conveyor_move_event = p_input_event
		elif Input.is_action_just_released("left") or Input.is_action_just_released("right"):
			if conveyor_moving:
				conveyor_moving = false
			if conveyor_move_event:
				conveyor_move_event = null
	elif InputMap.action_has_event("jump", p_input_event):
		print_debug("Identified a 'jump' input: {event}".format({"event": p_input_event}))
		if n_spawner_timer.is_stopped():
			print_debug("Spawn action timer not running. Spawning...")
			n_spawner_timer.start()
			action_spawn_ball_at_hopper()
		else:
			print_debug("Spawn action timer still running. Ignoring...")
	elif InputMap.action_has_event("quit", p_input_event):
		print_debug("Identified a 'quit' input: {event}".format({"event": p_input_event}))
		if n_quit_timer.is_stopped():
			print_debug("Quit timer not running. Executing...")
			n_quit_timer.start()
			get_tree().quit()
			#action_release_player()
		else:
			print_debug("Quit timer still running. Ignoring...")
			
	elif action_num_1_cond or action_num_2_cond or action_num_3_cond or action_num_4_cond:
		print_debug("Identified a action_num input: {event}".format({"event": p_input_event}))
		if n_action_num_timer.is_stopped():
			print_debug("action_num timer not running. Executing...")
			n_action_num_timer.start()
			action_engage_tool(p_input_event)
		else:
			print_debug("action_num timer still running. Ignoring...")

func action_engage_tool(p_event : InputEvent) -> void:
	"""
	This function should be called by the "handle_input" function and is responsible
	for actuating the proper workbench tool when handed an input event corresponding
	to one of the action_num_X actions in the InputMap
	
	Checks:
		1.
	Steps:
		1.
	"""
	pass

func action_spawn_ball_at_hopper() -> void:
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
	var is_balls_in_spawn_area = (len(objs_in_spawn_area)>0) and (objs_in_spawn_area.any(func(obj): return obj.name == "BallTest"))
	if is_balls_in_spawn_area:
		return
	
	var spawn_item = spawn_scene.instantiate()
	var spawn_location = get_random_point_in_box(n_hopper_spawn_area)
	
	spawn_item.global_transform.origin = spawn_location
	n_hopper_spawnables_holder.add_child(spawn_item)

func action_move_conveyor_objects(p_input_event : InputEvent, delta : float) -> void:
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

func action_release_player() -> void:
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
	
	if not current_interactor:
		return

""" ==== Signal Callbacks ==== """
func on_interact_component_interacted(p_interaction_mode: Enums.InteractionComponentMode, p_interactor : PlayerAvatar):
	"""
	Handles the 'interacted' callback from the InteractComponent.
	
	Checks:
		1. Is the bench accepting interactions?
		2. Is the provided interaction mode non-null?
	Steps:
		1. If provided interaction mode is PRIMARY:
			a. Store the interactor in corresponding parameter
			b. Add the 'IGNORE_INTERACTS' flag to state flags to block out further interact attempts
			c. Remove the 'IGNORE_INPUTS' flag from state flags to allow the player to interact with the bench
			d. Grab the player camera / make the bench cam current
			e. Move player avatar to position in front of the bench
			f. Command PlayerAvatar to ignore control inputs
			g. Set bench to standby mode if not already
		2. If provided interaction mode is SECONDARY:
			a.
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
