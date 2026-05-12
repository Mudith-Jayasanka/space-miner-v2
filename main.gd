extends Node2D

@export var core_scene: PackedScene = preload("res://buildings/core/core.tscn")
@export var transmitter_scene: PackedScene = preload("res://buildings/power_transmitter/power_transmitter.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_place_building(core_scene, event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_place_building(transmitter_scene, event.position)

func _place_building(scene: PackedScene, pos: Vector2) -> void:
	var b = scene.instantiate()
	b.global_position = pos
	add_child(b)
	GameEvents.building_placed.emit(b)
