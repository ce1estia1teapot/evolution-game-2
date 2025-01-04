extends Node

"""
The WorldState is intended to hold a current record of entity states submitted by each entity to keep track of information of interest for each:
	Dictionary {Entity_name(string): {property(string): value(primitive)} }
	
	Net info fields needed:
		1. Health
		2. Position
		3. Rotation
	
	Information of interest by Entity type:
		Player:
			1. Health
			2. Armor
			2. Position
			3. Rotation
		Enemies:
			1. 
"""

## Dictionary in the form {Entity: [Array of nodes]}.
var WORLD_STATE: Dictionary = {}


""" ==== Built-in Functions ==== """


"""  ==== Misc. Methods ===="""
func update_world_state(p_reporting_node_name: String, p_report: Dictionary) -> void:
	"""
	This function takes a reporting node and appends the provided report to that nodes's array of
	reports.
	
	1. Set the value of WORLD_STATE[p_reporting_node_name] = p_report
	2. Emit signal 'world_state_updated' on MainSignalBus
	"""
	if (not p_reporting_node_name) or (not p_report):
		push_warning("Failed to update world state: Node or Report was missing from last call to update_world_state in World.gd")
	
	WORLD_STATE[p_reporting_node_name] = p_report
	print("World state: {ws}".format({"ws": WORLD_STATE}))
	MainSignalBus.world_state_updated.emit(WORLD_STATE)

func reset_world_state() -> void:
	WORLD_STATE.clear()

func trim_array(p_array: Array, p_max_length: int) -> Array:
	var final_array := p_array
	while len(final_array) > p_max_length:
		final_array.pop_front()
	return final_array

"""  ==== Signal Callbacks ===="""
