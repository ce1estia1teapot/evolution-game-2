extends Control
class_name BaseMenu

signal MenuTransitioned(current_menu: BaseMenu, desired_menu_name: String)

func enter():
	## Function to be executed when a menu is opened.
	pass

func exit():
	## Function to be executed before a menu is closed
	pass

func update():
	## Function to update the menu each frame (if needed)
	pass
