extends Node
class_name StateMachine
"""
This class is meant to handle generic state transition functionality.
It listens for transition signals from child states and facilitates safe transition to desired states.
"""

@export var INITIAL_STATE: BaseState

var reporting_message_busses: Array[BaseSignalBus] = [MainSignalBus, PlayerSignalBus]
var current_state: BaseState
var states: Dictionary = {}

func _ready() -> void:
	if INITIAL_STATE:
		INITIAL_STATE.enter()
		current_state = INITIAL_STATE
	
	# Check all children for possible states. Add each one identified to the statedict
	for child in get_children():
		if child is BaseState:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transitioned)
	
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
	
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func on_child_transitioned(originating_state: BaseState, new_state_name: String) -> void:
	# Ensure that calling state is the current state attempting to transition...
	if originating_state != current_state:
		return
	
	var new_state: BaseState = states.get(new_state_name.to_lower())
	# Ensure that a new state was properly retrieved...
	if !new_state:
		return

	# If we have a current state, exit it
	if current_state:
		current_state.exit()
	
	# Enter the new state
	new_state.enter()
	
	# Report state change over designated busses...
	if reporting_message_busses:
		for bus in reporting_message_busses:
			if bus and is_instance_of(bus, BaseSignalBus):
				bus.report_state_transition.emit(self, current_state, new_state)
	
	# Update our current state variable
	current_state = new_state
	#print("Leaving the '"+calling_state.name.to_upper()+"' state and entering the '"+new_state.name.to_upper()+"' state")
