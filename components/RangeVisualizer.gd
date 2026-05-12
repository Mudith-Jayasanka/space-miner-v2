extends Node2D

@export var radius: float = 100.0
@export var color: Color = Color(0, 1, 1, 0.2)

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color)

func update_radius(new_radius: float) -> void:
	radius = new_radius
	queue_redraw()
