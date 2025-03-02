@icon("res://Assets/Icons/chart-simple-solid.svg")
extends Resource
class_name WeaponStatsComponent


""" Base Stats """
@export_category("Damage Values")
@export_group("Base")
@export var base_bludgeoning: float = 1
@export var base_piercing: float = 1
@export var base_magic: float = 1
@export var base_knockback: float = 1

@export_group("Current")
@export var current_bludgeoning: float = 1
@export var current_piercing: float = 1
@export var current_magic: float = 1
@export var current_knockback: float = 1

""" Effects """
@export_category("Effects")
@export var applied_conditions: Array[HealthCondition]


func create_attack() -> Attack:
	var final_attack: Attack = Attack.new()
	
	
	
	
	return final_attack
