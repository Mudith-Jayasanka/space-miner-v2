extends Node2D

@export var core_scene: PackedScene = preload("res://buildings/core/core.tscn")
@export var transmitter_scene: PackedScene = preload("res://buildings/power_transmitter/power_transmitter.tscn")
@export var miner_scene: PackedScene = preload("res://buildings/miner/miner.tscn")
@export var asteroid_scene: PackedScene = preload("res://entities/asteroid/Asteroid.tscn")

@onready var iron_label: Label = $UI/IronLabel
@onready var building_menu: HBoxContainer = $UI/BuildingMenu

var selected_building_type: String = ""
var ghost_building: Node2D = null

func _ready() -> void:
	ResourceManager.iron_count_changed.connect(_on_iron_count_changed)
	if building_menu:
		building_menu.building_selected.connect(_on_building_selected)

func _on_building_selected(type: String) -> void:
	if ghost_building:
		ghost_building.queue_free()
		ghost_building = null
		
	selected_building_type = type
	_create_ghost(type)

func _create_ghost(type: String) -> void:
	var scene: PackedScene = null
	match type:
		"core": scene = core_scene
		"transmitter": scene = transmitter_scene
		"miner": scene = miner_scene
	
	if scene:
		ghost_building = scene.instantiate()
		ghost_building.modulate.a = 0.5
		ghost_building.set_process(false)
		ghost_building.set_physics_process(false)
		if ghost_building.has_node("Label"):
			ghost_building.get_node("Label").visible = false
		add_child(ghost_building)

func _on_iron_count_changed(new_total: float) -> void:
	iron_label.text = "Iron: %d" % int(new_total)

func _process(_delta: float) -> void:
	if ghost_building:
		ghost_building.global_position = get_global_mouse_position()
		_update_ghost_visuals()

func _update_ghost_visuals() -> void:
	var can_place = _check_placement_valid(ghost_building)
	
	# Visual feedback for placement validity
	if can_place:
		ghost_building.modulate = Color(1, 1, 1, 0.5)
	else:
		ghost_building.modulate = Color(1, 0, 0, 0.5) # Red tint if blocked
	
	var potential_source = $GridManager.get_potential_source(ghost_building.global_position)
	if potential_source:
		GameEvents.surge_visual_requested.emit([[ghost_building.global_position, potential_source.global_position]], true)
	else:
		GameEvents.surge_visual_requested.emit([], true)

func _check_placement_valid(ghost: Node2D) -> bool:
	if not ghost.has_node("CollisionShape2D"):
		return true
		
	var space_state = get_world_2d().direct_space_state
	var shape_query = PhysicsShapeQueryParameters2D.new()
	
	var shape_node = ghost.get_node("CollisionShape2D")
	shape_query.shape = shape_node.shape
	shape_query.transform = ghost.global_transform
	shape_query.collide_with_areas = true
	shape_query.collide_with_bodies = true
	
	# Exclude the ghost itself if it has a RID
	if ghost is CollisionObject2D:
		shape_query.exclude = [ghost.get_rid()]
	
	var results = space_state.intersect_shape(shape_query)
	return results.size() == 0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if selected_building_type != "":
				if _check_placement_valid(ghost_building):
					_place_selected_building(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_clear_selection()
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_I:
			_place_entity(asteroid_scene, get_global_mouse_position())

func _clear_selection() -> void:
	selected_building_type = ""
	if ghost_building:
		ghost_building.queue_free()
		ghost_building = null
	GameEvents.surge_visual_requested.emit([], true)

func _place_selected_building(pos: Vector2) -> void:
	var scene: PackedScene = null
	match selected_building_type:
		"core": scene = core_scene
		"transmitter": scene = transmitter_scene
		"miner": scene = miner_scene
	
	if scene:
		_place_building(scene, pos)
		if selected_building_type == "core":
			_clear_selection()

func _place_building(scene: PackedScene, pos: Vector2) -> void:
	var b = scene.instantiate()
	b.global_position = pos
	add_child(b)
	GameEvents.building_placed.emit(b)

func _place_entity(scene: PackedScene, pos: Vector2) -> void:
	var e = scene.instantiate()
	# Basic check for asteroid placement too
	e.global_position = pos
	if _check_placement_valid(e):
		add_child(e)
	else:
		e.queue_free()
