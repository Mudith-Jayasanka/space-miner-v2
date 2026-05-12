extends Node2D
class_name PowerReceiver

signal efficiency_changed(new_ratio: float)
signal power_status_changed(powered: bool)

@export var power_required: float = 20.0
@export var transmission_range: float = 200.0 # Used for extending the grid

var is_powered: bool = false:
	set(value):
		if is_powered != value:
			is_powered = value
			power_status_changed.emit(is_powered)

var efficiency: float = 0.0:
	set(value):
		if efficiency != value:
			efficiency = value
			efficiency_changed.emit(efficiency)

func _ready() -> void:
	# Register for grid updates
	GameEvents.grid_updated.connect(_on_grid_updated)

func _on_grid_updated() -> void:
	# Logic for reacting to grid updates will be triggered by GridManager
	# setting the is_powered and efficiency properties directly.
	pass
