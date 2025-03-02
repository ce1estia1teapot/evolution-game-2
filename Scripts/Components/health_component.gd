@icon("res://Assets/Icons/notes-medical-solid.svg")
extends Resource
class_name HealthComponent

signal attack_received(health_component: HealthComponent, damages: Dictionary, total_damage: float, attack: Attack)
signal knockback_received(knockback_force: float)
signal health_is_zero(health_component: HealthComponent)
signal health_changed(health_component: HealthComponent, old_health: float, new_health: float)

@export_group("General")
# Health
@export var HEALTH: float : 
	get():
		return HEALTH
	set(p_health):
		# Clamp to reasonable range
		var new_health: float = clampf(p_health, 0.0, INF)
		var old_health: float = HEALTH
		# Round to 2 decimal places
		new_health = round_place(new_health, 2)
		
		# Set HEALTH to new value
		HEALTH = new_health
		
		# Emit signals/messages to alert subscribers of change
		print("Health changed: {health}".format({"health": HEALTH}))
		self.health_changed.emit(self, old_health, new_health)
		# Check for death, emit signal if == 0
		if HEALTH == 0.0:
			self.health_is_zero.emit(self)
			print("You died!")

# This flag should be used in the Component's '_ready()' function by a parent to forbid the Component from setting its fields to default on load,
# preferring to wait for assignment from parent upon pulling world state
var is_waiting_for_ws_update: bool = false

# Armor
@export var armor: int = 0
@export var armor_dam_red_per_point: float = 1.0
var armor_dam_reduction: float :
	get():
		if armor and armor_dam_red_per_point:
			return armor * armor_dam_red_per_point
		else:
			return 0.0

# Active Statuses & Conditions
# k:v Enums.HealthStatus: int (number of stacks)
var active_statuses: Dictionary = {}
var active_conditions: Array[HealthCondition] = []

# Upgrades
var upgrades: Array = []

# Resistances 
# A dictionary of the format Dictionary[Enums.DamageTypes, float]
# Where the float is the percentage resistance against the given damage type.
# Similar for vulnerabilities, but percentages are damage increases

@export_group("Modifiers")
@export var resistances: Dictionary
@export var vulnerabilities: Dictionary

func _ready() -> void:
	pass

func _modify_damage(p_damage: float, p_type: Enums.DamageTypes) -> float:
	"""
	This method takes a float and a damage type, then applies resistances, vulnerabilities, and armor before returning
	"""
	# Return if arguments are null
	if (not p_damage) or (not p_type):
		return 0.0
	
	var current_damage: float = p_damage
	var resistance: float = 0.0
	var vulnerability: float = 0.0
	if resistances:
		resistance = resistances.get(p_type) if (p_type in resistances) else 0.0
	if vulnerabilities:
		vulnerability = vulnerabilities.get(p_type) if (p_type in vulnerabilities) else 0.0
	
	# Apply Resistance and/or vulnerability
	current_damage = current_damage * (1 - resistance)
	current_damage = current_damage / (1 - vulnerability)
	
	# Apply armor, if appropriate
	if p_type == Enums.DamageTypes.BLUDGEONING:
		current_damage = current_damage * (1 - armor_dam_reduction)
	
	return current_damage



func apply_damage(p_damage: float, p_type: Enums.DamageTypes) -> void:
	"""
	This method simply applies damage of a given type to the health component
	"""
	# Calculate modified damage...
	var modified_damage = _modify_damage(p_damage, p_type)
	
	# Apply Damage to health and emit signal
	HEALTH = HEALTH - modified_damage

func apply_attack(p_attack: Attack) -> void:
	if not p_attack:
		return
		
	# Extract stats from attack and modify with resistance, vulnerability, and armor
	var bludgeoning: float = _modify_damage(p_attack.bludgeoning, Enums.DamageTypes.BLUDGEONING)
	var piercing: float = _modify_damage(p_attack.piercing, Enums.DamageTypes.PIERCING)
	var magic: float = _modify_damage(p_attack.magic, Enums.DamageTypes.MAGIC)
	var knockback_force: float = p_attack.knockback_force

	# Sum final damages together for total damage
	var total_damage: float = bludgeoning + piercing + magic
	
	# Apply total damage and emit signal
	var final_damages: Dictionary = {
		Enums.DamageTypes.BLUDGEONING: bludgeoning,
		Enums.DamageTypes.PIERCING: piercing,
		Enums.DamageTypes.MAGIC: magic,
	}
	
	
	var new_health = HEALTH - total_damage
	
	self.health_changed.emit(self, HEALTH, new_health)
	self.knockback_received.emit(knockback_force)
	self.damage_taken.emit(self, final_damages, total_damage, new_health, p_attack)
	
	HEALTH = new_health
	
	
func round_place(num: float,places: int) -> float:
	if (not num) or (not places):
		return num
	
	return (round(num*pow(10,places))/pow(10,places))
