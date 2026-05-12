extends Node

# Tracks global resource counts

signal iron_count_changed(new_total: float)

var total_iron: float = 0.0:
	set(value):
		total_iron = value
		iron_count_changed.emit(total_iron)

func _ready() -> void:
	GameEvents.iron_collected.connect(_on_iron_collected)

func _on_iron_collected(amount: float) -> void:
	total_iron += amount
