extends Node2D

@export var core_scene: PackedScene = preload("res://buildings/core/core.tscn")
@export var transmitter_scene: PackedScene = preload("res://buildings/power_transmitter/power_transmitter.tscn")
@export var miner_scene: PackedScene = preload("res://buildings/miner/miner.tscn")
@export var asteroid_scene: PackedScene = preload("res://entities/asteroid/Asteroid.tscn")

@onready var iron_label: Label = $UI/IronLabel

func _ready() -> void:
	ResourceManager.iron_count_changed.connect(_on_iron_count_changed)

func _on_iron_count_changed(new_total: float) -> void:
	iron_label.text = "Iron: %d" % int(new_total)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if Input.is_key_pressed(KEY_SHIFT):
				_place_building(miner_scene, event.position)
			else:
				_place_building(core_scene, event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_place_building(transmitter_scene, event.position)
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_I:
			_place_entity(asteroid_scene, get_global_mouse_position())

func _place_building(scene: PackedScene, pos: Vector2) -> void:
	var b = scene.instantiate()
	b.global_position = pos
	add_child(b)
	GameEvents.building_placed.emit(b)

func _place_entity(scene: PackedScene, pos: Vector2) -> void:
	var e = scene.instantiate()
	e.global_position = pos
	add_child(e)
