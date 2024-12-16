extends Node
class_name Entity


func broadcast_world_state_update():
	"""
	The common abstract functiopn used by Entities to assemble and broadcase a world state report. Should
	be implemented by each bottom-level class
	"""
	pass
