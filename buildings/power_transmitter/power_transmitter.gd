extends Area2D

@onready var receiver: PowerReceiver = $PowerReceiver
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	receiver.power_status_changed.connect(_on_power_status_changed)
	_update_visuals()

func _on_power_status_changed(_powered: bool) -> void:
	_update_visuals()

func _update_visuals() -> void:
	if receiver.is_powered:
		sprite.modulate = Color.GREEN
	else:
		sprite.modulate = Color.RED
