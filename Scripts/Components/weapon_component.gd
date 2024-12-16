@icon("res://Assets/Icons/gun-solid.svg")
extends Node
class_name WeaponComponent
"""
This component handles pulling together weapon stats to create an attack, and transmitting that
attack to the target's Hitbox component
"""

""" Attributes """
@export_category("General Settings")
@export var weapon_stats_component: WeaponStatsComponent = null

""" Flags """
@export_category("Flags")
@export var is_equipped: bool = true


func create_attack() -> Attack:
	var final_attack: Attack = Attack.new()
	
	if weapon_stats_component:
		final_attack = weapon_stats_component.create_attack()
	
	return final_attack
