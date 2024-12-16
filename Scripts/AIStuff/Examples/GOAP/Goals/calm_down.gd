extends ExampleGoapGoal
class_name CalmDownGoal

var WorldState

func get_clazz(): return "CalmDownGoal"

func is_valid() -> bool:
	return WorldState.get_state("is_frightened", false)


func priority() -> int:
	return 10


func get_desired_state() -> Dictionary:
	return {
		"is_frightened": false
	}
