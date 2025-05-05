extends Control

""" ====  ==== """

""" ==== References ==== """
# Nodes
@onready var n_main_menu : Panel = $MainMenu

# Reference Positions
@onready var n_player_standing_position : Node3D = $ReferencePoints/PlayerStandingPosition

""" ==== Parameters ==== """


""" ==== Built-Ins ==== """


""" ==== Utility Functions ==== """
func hide_all_menus():
	for child in get_children():
		if child is CanvasItem:
			child.hide()

func show_menu(p_menu : CanvasItem) -> void:
	hide_all_menus()
	p_menu.show()

func show_main_menu() -> void:
	hide_all_menus()
	n_main_menu.show()



""" ==== Signal Callbacks ==== """
