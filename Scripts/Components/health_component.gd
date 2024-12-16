@icon("res://Assets/Icons/notes-medical-solid.svg")
extends Node
class_name HealthComponent

signal damage_taken(health_component: HealthComponent, damages: Dictionary, total_damage: float, new_health: float, attack: Attack)
signal attack_applied(health_component: HealthComponent, attack: Attack)
signal health_is_zero(health_component: HealthComponent)

# Health
var HEALTH: float
@export var MAX_HEALTH: float = 100

# Armor
@export var armor: int = 0
@export var armor_dam_red_per_point: float = 1.0
var armor_dam_reduction: float

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
var resistances: Dictionary = {}
var vulnerabilities: Dictionary = {}

func _ready() -> void:
	HEALTH = MAX_HEALTH
	
	armor_dam_reduction = armor * armor_dam_reduction

func apply_attack(p_attack: Attack) -> void:
	if not p_attack:
		return
	
	# Emit signal so parent can use knockback values
	self.attack_applied.emit(self, p_attack)
	
	# Extract stats from attack
	var bludgeoning: float = p_attack.bludgeoning
	var piercing: float = p_attack.piercing
	var magic: float = p_attack.magic
	var knockback: float = p_attack.knockback
	var knockback_force: float = p_attack.knockback_force
	
	# Apply resistances to damage type values to reduce damages
	if Enums.DamageTypes.BLUDGEONING in resistances:
		bludgeoning = (1-resistances[Enums.DamageTypes.BLUDGEONING])*bludgeoning
	if Enums.DamageTypes.PIERCING in resistances:
		piercing = (1-resistances[Enums.DamageTypes.PIERCING])*piercing
	if Enums.DamageTypes.MAGIC in resistances:
		magic = (1-resistances[Enums.DamageTypes.MAGIC])*magic
	
	# Apply vulnerabilities to damage type values to increase damages
	if Enums.DamageTypes.BLUDGEONING in vulnerabilities:
		bludgeoning = bludgeoning/(1-vulnerabilities[Enums.DamageTypes.BLUDGEONING])
	if Enums.DamageTypes.PIERCING in vulnerabilities:
		piercing = piercing/(1-vulnerabilities[Enums.DamageTypes.PIERCING])
	if Enums.DamageTypes.MAGIC in vulnerabilities:
		magic = magic/(1-vulnerabilities[Enums.DamageTypes.MAGIC])
	
	# Apply armor to damage types that it reduces (Bludgeoning?)
	bludgeoning = (1-armor_dam_reduction) * bludgeoning
	
	# Sum final damages together for total damage
	var total_damage: float = bludgeoning + piercing + magic
	
	# Apply total damage and emit signal
	var final_damages: Dictionary = {
		Enums.DamageTypes.BLUDGEONING: bludgeoning,
		Enums.DamageTypes.PIERCING: piercing,
		Enums.DamageTypes.MAGIC: magic,
	}
	
	HEALTH = HEALTH - total_damage
	self.damage_taken.emit(self, final_damages, total_damage, HEALTH, p_attack)
	
