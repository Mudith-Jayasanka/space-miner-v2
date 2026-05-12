extends Node2D

func _ready() -> void:
	GameEvents.surge_visual_requested.connect(_on_surge_visual_requested)

func _on_surge_visual_requested(connections: Array) -> void:
	# Clear previous lines
	for child in get_children():
		child.queue_free()
	
	# Create new lines for each connection
	for pair in connections:
		var line = Line2D.new()
		line.points = PackedVector2Array(pair)
		line.width = 2.0
		line.default_color = Color(0, 1, 1, 0.5) # Semi-transparent Cyan
		add_child(line)
