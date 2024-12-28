extends RayCast3D
class_name InteractionRay

signal target_changed(new_target)

@export var target_pos: float = -2.5
@export var target_check_period_s: float = 0.5

var target_check_timer: Timer = Timer.new()
var current_target = null

func _ready() -> void:
	target_check_timer.wait_time = target_check_period_s
	target_check_timer.one_shot = false
	
	target_check_timer.timeout.connect(on_target_check_timer_timeout)
	
	target_check_timer.start()

func get_current_target() -> Object:
	return current_target

func on_target_check_timer_timeout() -> void:
	var collider = get_collider()
	
	if collider == current_target:
		pass
	else:
		current_target = collider
		self.target_changed.emit(current_target)
	
	
