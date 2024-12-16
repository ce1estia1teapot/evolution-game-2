extends BaseState
class_name EnemyFollowState

@export var enemy: CharacterBody3D
@export var move_speed := 40.0
var player: CharacterBody3D

func enter():
	player = get_tree().get_first_node_in_group("Player")
