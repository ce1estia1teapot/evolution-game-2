extends Node
class_name BaseState

signal Transitioned(curr_state: BaseState, desired_state_name: String)

func enter():
	pass
	
func exit():
	pass

func update(_delta: float):
	pass
	
func physics_update(_delta: float):
	pass
