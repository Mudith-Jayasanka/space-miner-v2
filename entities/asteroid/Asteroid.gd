extends StaticBody2D
class_name Asteroid

enum Size { SMALL, MEDIUM, LARGE }

@export var size_type: Size = Size.MEDIUM
@export var iron_amount: float = 100.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_apply_size_stats()

func _apply_size_stats() -> void:
	match size_type:
		Size.SMALL:
			iron_amount = 50.0
			scale = Vector2(0.5, 0.5)
		Size.MEDIUM:
			iron_amount = 200.0
			scale = Vector2(1.0, 1.0)
		Size.LARGE:
			iron_amount = 1000.0
			scale = Vector2(2.0, 2.0)

func extract_iron(amount: float) -> float:
	var actual_amount = min(amount, iron_amount)
	iron_amount -= actual_amount
	
	# Optional: Shrink or change visual as it depletes
	if iron_amount <= 0:
		queue_free()
		
	return actual_amount
