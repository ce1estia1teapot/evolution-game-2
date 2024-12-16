extends Node3D
class_name A_EXPLOSION_1

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_explosion(p_position: Vector3):
	position = p_position
	animation_player.play("Init")
