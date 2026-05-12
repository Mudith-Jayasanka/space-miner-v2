extends Node2D

var grid_lines: Node2D
var preview_lines: Node2D

func _ready() -> void:
	grid_lines = Node2D.new()
	grid_lines.name = "GridLines"
	add_child(grid_lines)
	
	preview_lines = Node2D.new()
	preview_lines.name = "PreviewLines"
	add_child(preview_lines)
	
	GameEvents.surge_visual_requested.connect(_on_surge_visual_requested)

func _on_surge_visual_requested(connections: Array, is_preview: bool) -> void:
	var container = preview_lines if is_preview else grid_lines
	
	# Clear previous lines in the target container
	for child in container.get_children():
		child.queue_free()
	
	# Create new lines for each connection
	for pair in connections:
		var line = Line2D.new()
		line.points = PackedVector2Array(pair)
		line.width = 2.0
		
		if is_preview:
			line.default_color = Color(1, 1, 0, 0.4) # Semi-transparent Yellow for preview
			# Dash effect for preview
			line.texture_mode = Line2D.LINE_TEXTURE_TILE
		else:
			line.default_color = Color(0, 1, 1, 0.5) # Semi-transparent Cyan for fixed
			
		container.add_child(line)
