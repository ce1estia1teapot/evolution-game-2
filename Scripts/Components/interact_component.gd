extends Area3D
class_name InteractComponent

signal interacted()

@export var interact_prompt_message: String = "Interact"

func interact() -> void:
	self.interacted.emit()
