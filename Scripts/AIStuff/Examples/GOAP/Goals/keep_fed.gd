extends ExampleGoapGoal
class_name KeepFedGoal

var WorldState

func get_clazz(): return "KeepFedGoal"

# This is not a valid goal when hunger is less than 50.
func is_valid() -> bool:
	return WorldState.get_state("hunger", 0)  > 50 and WorldState.get_elements("food").size() > 0


func priority() -> int:
	return 1 if WorldState.get_state("hunger", 0) < 75 else 2


func get_desired_state() -> Dictionary:
	return {
		"is_hungry": false
	}
