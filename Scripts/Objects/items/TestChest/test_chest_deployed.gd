extends StaticBody3D

@onready var n_interact_component: InteractComponent = $Components/InteractComponent
@onready var n_inventory_component: InventoryComponent = $Components/InventoryComponent


func _ready() -> void:
	n_interact_component.interacted.connect(_on_interact_component_interacted)

func _on_interact_component_interacted():
	PlayerSignalBus.inventory_interacted.emit(self, n_inventory_component)
