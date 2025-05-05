extends Control
class_name HealthBarHUD

@onready var n_health_bar_background: ProgressBar = $HealthBarBackground
@onready var n_health_bar: ProgressBar = $HealthBar

@export var health = 100

var healthbar_tween: Tween

func _ready() -> void:
	if health:
		n_health_bar.value = health
		n_health_bar_background.value = health

func set_healthbar_value(p_new_health: float):
	n_health_bar.value = p_new_health
	
	# Animate damage overlay and healthbar background with hurt_tween
	if healthbar_tween:
		healthbar_tween.kill()
	healthbar_tween = self.create_tween()
	healthbar_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	healthbar_tween.tween_property(n_health_bar_background, "value", p_new_health, 1.2)
