extends Node
"""
Contains a utility function to display a damage number at a provided location
"""

"""================== Settings Values =================="""
# Color Presets
const PIERCING_COLOR = "#FFF"
const BLUDGEONING_COLOR = "#FFF"
const MAGIC_COLOR = "#FFF"
const CRIT_COLOR = "#B22"
const OUTLINE_COLOR = "#000"

# Label Text Settings
const FONT_SIZE = 18
const OUTLINE_SIZE = 1

# Label Animation Settings
const ANIMATION_DURATION_S = 0.25
const ANIMATION_DISTANCE_PX = 24
const NUM_DISAPPEAR_TIME_S = 2

# Misc. Settings
const IS_BILLBOARD_ENABLED = BaseMaterial3D.BILLBOARD_ENABLED
const IS_SHADED = true
const IS_FIXED_SIZE = true

func display_number(p_value: int, p_global_position: Vector3, p_dam_type: Enums.DamageTypes,p_is_critical: bool = false):
	"""
	Takes in the value to display, its global position, and whether it represents a crit.
	
	Displays the number on a billboarded label using (eventually) global settings
	"""
	
	var num_label := Label3D.new()
	num_label.global_position = p_global_position
	num_label.text = str(p_value)
	
	num_label.label_settings = LabelSettings.new()
	num_label.label_settings.font_size = FONT_SIZE
	num_label.label_settings.outline_color = OUTLINE_COLOR
	num_label.label_settings.outline_size = OUTLINE_SIZE
	
	num_label.billboard = IS_BILLBOARD_ENABLED
	num_label.shaded = IS_SHADED
	num_label.fixed_size = IS_FIXED_SIZE
	
	# Setting the text color based on damage type - defaults to white
	var color = "#FFF"
	match p_dam_type:
		Enums.DamageTypes.BLUDGEONING:
			color = BLUDGEONING_COLOR
		Enums.DamageTypes.PIERCING:
			color = PIERCING_COLOR
		Enums.DamageTypes.MAGIC:
			color = MAGIC_COLOR
		_:
			pass
	num_label.label_settings.font_color = color
	
	# After applying settings, spawn label and center the pivot using offset
	call_deferred("add_child", num_label)
	
	await num_label.ready
	num_label.offset = Vector2(num_label.size / 2)
	
	# Animate number using tweens
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(num_label, "position: y", num_label.position.y - ANIMATION_DISTANCE_PX, ANIMATION_DURATION_S).set_ease(Tween.EASE_OUT)
	tween.tween_property(num_label, "position: y", num_label.position.y, ANIMATION_DURATION_S).set_ease(Tween.EASE_IN).set_delay(ANIMATION_DURATION_S)
	tween.tween_property(num_label, "scale", Vector2.ZERO, ANIMATION_DURATION_S).set_ease(Tween.EASE_IN).set_delay(ANIMATION_DURATION_S)
	tween.tween_property(num_label, "transparency", 0, NUM_DISAPPEAR_TIME_S).set_ease(Tween.EASE_IN).set_delay(ANIMATION_DURATION_S)
	
	# After animation is complete, remove the number
	await tween.finished
	num_label.queue_free()
