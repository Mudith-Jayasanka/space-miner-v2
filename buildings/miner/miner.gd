extends Node2D

@onready var receiver: PowerReceiver = $PowerReceiver
@onready var extractor: ResourceExtractor = $ResourceExtractor
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	receiver.power_status_changed.connect(_on_power_status_changed)
	receiver.efficiency_changed.connect(_on_efficiency_changed)
	_update_state()

func _on_power_status_changed(_powered: bool) -> void:
	_update_state()

func _on_efficiency_changed(_ratio: float) -> void:
	_update_state()

func _update_state() -> void:
	extractor.is_active = receiver.is_powered
	# Scaled mining speed based on efficiency
	extractor.mining_speed = 5.0 * receiver.efficiency
	
	if receiver.is_powered:
		sprite.modulate = Color.CYAN
	else:
		sprite.modulate = Color.RED
