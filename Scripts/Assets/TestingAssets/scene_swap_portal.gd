extends Area3D

@export_file("*.tscn") var target_scene : String

func _ready() -> void:
	
	#Emitted when the received body enters this area. body can be a PhysicsBody3D or a GridMap
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(p_body: Node3D):
	if p_body is PlayerAvatar:
		get_tree().change_scene_to_file(target_scene)
