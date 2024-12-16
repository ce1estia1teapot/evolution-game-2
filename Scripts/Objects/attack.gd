extends Object
class_name Attack

""" === Base Attack === """
var bludgeoning: float = 1
var piercing: float = 1
var magic: float = 1
var knockback: float = 1

var knockback_force: float = 0.0

""" === Applications === """
## A dictionary of the format - Enums.HealthStatus: int (number of stacks)
var statuses: Dictionary = {}
var conditions: Array[HealthCondition] = []
