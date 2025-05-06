extends RigidBody3D

@onready var n_collision_shape_3d: CollisionShape3D = $CollisionShape3D

func _on_body_entered(body: Node) -> void:
	if body.name == "ConveyorPlaceholder":
		self.freeze = false
