@icon("res://Assets/Icons/chart-simple-solid.svg")
extends Resource
class_name CharacterStatsComponent

# Movement
@export_category("Stats")
@export_group("Movement")
@export var move_speed: float = 10.0
@export var max_stamina: float = 10.0
@export var stamina: float = 10.0

# Combat
@export_group("Combat")
@export var unarmed_damage = 10
@export var attack_rate = 1
