extends DroppedItem
class_name MetalHatchetDrop

""" Grabbing components on ready... """
@onready var m_hitbox_comp: HitboxComponent = $Components/HitboxComponent
@onready var m_weapon_comp: WeaponComponent = $Components/WeaponComponent

""" Built-ins """
#region Built-in Functions
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if m_weapon_comp.is_equipped:
		self.visible = true
	else:
		self.visible = false
#endregion

""" Signal Callbacks """
func on_interaction_queue_free():
	self.queue_free()
