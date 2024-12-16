extends ExampleGoapGoal
class_name KeepFirepitBurningGoal

var WorldState

func get_clazz(): return "KeepFirepitBurningGoal"


func is_valid() -> bool:
	return WorldState.get_elements("firepit").size() == 0


func priority() -> int:
	return 1


func get_desired_state() -> Dictionary:
	return {
		"has_firepit": true
	}
