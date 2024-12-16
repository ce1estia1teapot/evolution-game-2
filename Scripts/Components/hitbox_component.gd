@icon("res://Assets/Icons/crosshairs-solid.svg")
extends Area3D
class_name HitboxComponent

@export var health_component: HealthComponent

func receive_attack(attack: Attack):
	if health_component:
		health_component.apply_attack(attack)
