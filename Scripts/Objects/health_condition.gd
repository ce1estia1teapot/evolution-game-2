extends Node
class_name HealthCondition


var condition_name: String
var duration_seconds: float

func apply_condition(target: Node):
	"""
	apply_condition should:
		1. Edit relevant values on the target
		2. Attach a timer with proper duration to the target
		3. Connect a callback to timer's countdown signal
		4. On expiration, reverse its effects and queue free
	"""
	pass

func attach_and_timer(target: Node) -> void:
	var timer: Timer = Timer.new()
