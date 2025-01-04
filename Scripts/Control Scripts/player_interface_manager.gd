extends Control
class_name PlayerInterfaceManager

""" ==== Node References ==== """
@onready var n_health_bar_hud: HealthBarHUD = $HealthBarHUD
@onready var n_hurt_overlay: TextureRect = $HurtOverlay
@onready var n_death_screen_test: Panel = $DeathScreenTest

""" ===== Exports ==== """
@export_group("Hurt Overlay")
@export var hurt_overlay_fadeout_s: float = 0.5

""" ==== Attributes ==== """
var hurt_tween: Tween

""" ==== Built-in Functions ===="""
func _ready() -> void:
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE

""" ==== Menu Change Functions ==== """
#region Menu Change Functions

func show_death_screen() -> void:
	"""
	Shows the player death screen.
	
	It should:
		1. Set its own mouse filtering to 'stop'
		2. Call 'show()' on n_death_screen_test
	"""
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	
	n_death_screen_test.show()

#endregion

""" ==== Utility Functions ==== """
func on_damage_taken(p_new_health: float) -> void:
	"""
	Called by the player when damage is taken to handle updating UI stuff when damage is taken
	1. Update healthbar
	2. Animate hurt overlay
	"""
	
	# Update Healthbar
	n_health_bar_hud.set_healthbar_value(p_new_health)
	
	# Animate hurt overlay
	n_hurt_overlay.modulate = Color.WHITE
	if hurt_tween:
		hurt_tween.kill()
	hurt_tween = self.create_tween()
	hurt_tween.tween_property(n_hurt_overlay, "modulate", Color.TRANSPARENT, hurt_overlay_fadeout_s)
