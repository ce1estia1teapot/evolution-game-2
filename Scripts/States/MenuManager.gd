extends Control
class_name MenuManager
"""
This class is meant to handle generic menu transition functionality in addition to
processing player input.

It forms the first state of input consumption: UI Machine -> Player State Machine
"""

@export var INITIAL_MENU: BaseMenu

var reporting_message_busses: Array[BaseSignalBus]

var current_menu: BaseMenu
var menus: Dictionary = {}

func _input(event: InputEvent) -> void:
	pass

func _ready() -> void:
	"""
	1. Check whether there is an initial menu to open. If there is, open it.
	2. Loop over all children, check for BaseMenu class, add them to menus dictionary as name: menu
	"""
	
	# Checking for initial menu and setting it to active
	if INITIAL_MENU:
		INITIAL_MENU.enter()
		current_menu = INITIAL_MENU
	
	for child in get_children():
		if child is BaseMenu:
			# Add child to menus dictionary
			menus[child.name.to_lower()] = child
			# Connec to child's signal
			child.MenuTransitioned.connect(on_child_transitioned)

func _process(delta: float) -> void:
	if current_menu:
		current_menu.update()


func on_child_transitioned(originating_menu: BaseMenu, new_menu_name: String) -> void:
	"""
	1. Verify that the originating menu is the current menu. Return if not
	2. Retrieve new menu from dictionary, verify it was retrieved properly. Return if not
	3. Check for current menu. Exit if found
	4. Enter new menu
	5. (Optionally) report transition over message busses
	6. Set current menu to new menu
	"""
	
	# 1. Verify that originating menu is issuing the transition
	if originating_menu != current_menu:
		return
	
	# 2. Retrieve new menu from dictionary, verify retrieval, return if not found
	var new_menu: BaseMenu = menus.get(new_menu_name.to_lower())
	if not new_menu:
		return
	
	# 3. Check for current menu, exit if found
	if current_menu:
		current_menu.exit()
	
	# 4. Enter new menu
	new_menu.enter()
	
	# 5. Report over signal busses (if there are any)
	if reporting_message_busses:
		for bus in reporting_message_busses:
			if bus and is_instance_of(bus, BaseSignalBus):
				bus.report_menu_transition.emit(self, originating_menu, new_menu)
	
	# 6. Set current menu to new menu
	current_menu = new_menu
