@icon("res://Assets/Icons/boxes-stacked-solid.svg")
extends Node
class_name InventoryComponent

@export var inventory: Array[Item] = []
@export var max_slots: int = 1

## An array containing all upgrades applied to this inventory component
@export var upgrades: Array = []

func retrieve_item_quantity(p_item: Item) -> int:
	"""
	Returns the quantity of the provided item in the inventory.
	
	Comparisons are done via item_id.
	"""
	if not p_item:
		return 0
	
	var item_slots = retrieve_all_item_slots(p_item)
	var item_quantity = 0
	for slot in item_slots:
		item_quantity += len(slot.contents)
	
	return item_quantity

func retrieve_all_item_slots(p_item: Item) -> Array[InvSlot]:
	"""
	Returns an array of all InvSlots containing the provided item in the inventory.
	
	Comparisons done by item_id.
	"""
	
	if not p_item:
		return []
	
	var final_item_slots: Array[InvSlot] = []
	for slot in inventory:
		if slot.item.item_id == p_item.item_id:
			final_item_slots.append(slot)
	
	return final_item_slots

func remove_inv_slots(p_num_slots: int=0) -> int:
	"""
	Attempts to remove the provided number of inventory slots. Prefers empty slots, but makes up 
	any defecit starting at the end of the inventory array.
	
	Stops removing when quota is reached, or when there are no more slots left to remove.
	Returns the actual number of slots removed.
	"""
	if not p_num_slots:
		return 0
	
	p_num_slots = clamp(p_num_slots, 0, len(inventory))
	
	var slots_to_remove: Array[InvSlot] = []
	# First check for the empty slots
	for slot in inventory:
		# If slot is empty and we still need at least one more to reach quota, append current slot
		if (len(slot.contents) == 0) and (len(slots_to_remove) < p_num_slots):
			slots_to_remove.append(slot)
	
	# If enough slots haven't been found yet, start adding from the end of the list
	if (len(slots_to_remove) < p_num_slots):
		for i in range(len(inventory)-1, 0, -1):
			var slot = inventory[i]
			if len(slots_to_remove) < p_num_slots:
				slots_to_remove.append(slot)
			else:
				break
	
	# Once enough slots have been found, remove them
	for slot in slots_to_remove:
		inventory.erase(slot)
	return len(slots_to_remove)

func add_inv_slots(p_num_slots: int=0) -> int:
	"""
	Attempts to add the provided number of slots to the inventory. Stops adding when the quota is reached,
	or when the inventory's max_slots value is reached. 
	
	Returns number of slots actually added.
	"""
	
	if not p_num_slots:
		return 0
	
	var slots_added = 0
	while (slots_added < p_num_slots) and (len(inventory) < max_slots):
		var new_slot = InvSlot.new()
		inventory.append(new_slot)
		slots_added += 1
	
	return slots_added

func insert_items(items: Array[Item]) -> Array[Item]:
	## Takes an array of Items and attempts insertion into inventory stacks.
	## Returns array of Items that failed insertion.
	var failed_inserts: Array[Item] = []
	
	for curr_item in items:
		var inserted = false
		for curr_slot in inventory:
			# If slot is for current item...
			if (curr_slot.item.item_id == curr_item.item_id):
				# If slot has room, insert it set inserted to true for this item
				if (len(curr_slot.contents) < curr_slot.item.stack_size):
					curr_slot.contents.append(curr_item)
					inserted = true
				# If slot is full, pass
				else:
					pass
		# If a proper slot wasn't found, find first empty one
		if ~inserted:
			for curr_slot in inventory:
				if len(curr_slot.contents) == 0:
					inserted = true
					curr_slot.item = curr_item
					curr_slot.contents.append(curr_item)
		
		# If still not inserted after looking for empties, add to failed inserts
		if ~inserted:
			failed_inserts.append(curr_item)
		
	# After all items are processed, return failures
	return failed_inserts

func withdraw_item(p_item: Item, p_quantity: int):
	"""
	Attemps to withdraw the provided quantity of the provided item from the inventory 
	
	Returns an array of the items withdrawn if successful, null otherwise
	"""
	
	var return_array: Array[Item] = []
	var num_items_in_inventory: int = retrieve_item_quantity(p_item)
	var item_slots: Array[InvSlot] = retrieve_all_item_slots(p_item)
	var is_filled: bool = false
	
	# If requested number of items isn't present, return empty array...
	if num_items_in_inventory < p_quantity:
		return null
	
	# Loop over all slots containing the item, filling return array as we go and deleting item from the slots
	for slot in item_slots:
		if is_filled:
			break
		
		for item in slot.contents:
			if len(return_array) < p_quantity:
				return_array.append(item)
				slot.withdraw_item(item)
			else:
				is_filled = true
				break
	
	return return_array
