extends Control

@onready var scene_tree: SceneTree = get_tree()
@onready var n_respawn_button: Button = $VBoxContainer/ButtonBox/RespawnButton
@onready var n_quit_button: Button = $VBoxContainer/ButtonBox/QuitButton


func _ready() -> void:
	n_respawn_button.pressed.connect(on_respawn_button_pressed)
	n_quit_button.pressed.connect(on_quit_button_pressed)

func on_respawn_button_pressed():
	scene_tree.reload_current_scene()

func on_quit_button_pressed():
	scene_tree.quit()
