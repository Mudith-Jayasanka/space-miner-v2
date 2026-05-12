extends Node

# The GridManager handles the power graph and distribution
# It uses a BFS approach to satisfy demand from the Core outwards

var buildings: Array[Node2D] = []

func _ready() -> void:
	GameEvents.building_placed.connect(_on_building_placed)
	GameEvents.building_removed.connect(_on_building_removed)

func _on_building_placed(building: Node2D) -> void:
	if not buildings.has(building):
		buildings.append(building)
		update_grid()

func _on_building_removed(building: Node2D) -> void:
	buildings.erase(building)
	update_grid()

func update_grid() -> void:
	# 1. Reset all receivers
	for b in buildings:
		var receiver = _get_power_receiver(b)
		if receiver:
			receiver.is_powered = false
			receiver.efficiency = 0.0

	# 2. Identify Islands and Sources
	# For Milestone 1, we assume a single interconnected grid for simplicity
	# and start BFS from all PowerSources.
	
	var sources = _get_all_sources()
	if sources.is_empty():
		GameEvents.grid_updated.emit()
		return

	# 3. Multi-Source BFS
	var queue = []
	var visited = {}
	var connections = [] # Array of pairs [[from_pos, to_pos], ...]
	
	# Initial layer: Power Sources
	for source_node in sources:
		var building = source_node.get_parent()
		queue.append(building)
		visited[building] = {
			"source": source_node,
			"parent": null,
			"depth": 0
		}
		# Sources themselves are effectively "powered"
		var receiver = _get_power_receiver(building)
		if receiver:
			receiver.is_powered = true
			receiver.efficiency = 1.0

	var head = 0
	while head < queue.size():
		var current_building = queue[head]
		head += 1
		
		var current_range = _get_transmission_range(current_building)
		
		# Find neighbors within range
		for other_building in buildings:
			if other_building == current_building or visited.has(other_building):
				continue
				
			var dist = current_building.global_position.distance_to(other_building.global_position)
			if dist <= current_range:
				# Connection found
				visited[other_building] = {
					"parent": current_building,
					"depth": visited[current_building]["depth"] + 1
				}
				connections.append([current_building.global_position, other_building.global_position])
				queue.append(other_building)
				
				# Power the receiver
				var receiver = _get_power_receiver(other_building)
				if receiver:
					receiver.is_powered = true
					receiver.efficiency = 1.0 # Simple 1.0 for M1

	GameEvents.grid_updated.emit()
	GameEvents.surge_visual_requested.emit(connections, false)

func get_potential_source(pos: Vector2) -> Node2D:
	# Find the nearest powered building that can transmit to this position
	var nearest_source = null
	var min_dist = INF
	
	for b in buildings:
		var receiver = _get_power_receiver(b)
		var source = _get_power_source(b)
		
		# Building must be powered to be a source
		if (receiver and receiver.is_powered) or source:
			var range = _get_transmission_range(b)
			var dist = b.global_position.distance_to(pos)
			
			if dist <= range and dist < min_dist:
				min_dist = dist
				nearest_source = b
				
	return nearest_source

func _get_power_source(node: Node2D) -> PowerSource:
	for child in node.get_children():
		if child is PowerSource:
			return child
	return null

func _get_power_receiver(node: Node2D) -> PowerReceiver:
	for child in node.get_children():
		if child is PowerReceiver:
			return child
	return null

func _get_all_sources() -> Array[PowerSource]:
	var sources: Array[PowerSource] = []
	for b in buildings:
		for child in b.get_children():
			if child is PowerSource:
				sources.append(child)
	return sources

func _get_transmission_range(node: Node2D) -> float:
	# Check for PowerSource first, then PowerReceiver
	for child in node.get_children():
		if child is PowerSource:
			return child.transmission_range
		if child is PowerReceiver:
			return child.transmission_range
	return 0.0
