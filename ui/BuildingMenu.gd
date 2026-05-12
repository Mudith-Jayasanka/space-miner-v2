extends HBoxContainer

signal building_selected(type: String)

func _on_core_button_pressed() -> void:
	building_selected.emit("core")

func _on_transmitter_button_pressed() -> void:
	building_selected.emit("transmitter")

func _on_miner_button_pressed() -> void:
	building_selected.emit("miner")
