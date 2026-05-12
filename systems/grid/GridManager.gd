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

	# 2. Identify Sources
	var sources = _get_all_sources()
	
	# 3. Connectivity Analysis (All potential edges)
	var all_edges = []
	var building_edges = {} # b -> [neighbors]
	for b in buildings:
		building_edges[b] = []
		var range = _get_transmission_range(b)
		for other in buildings:
			if b == other: continue
			if b.global_position.distance_to(other.global_position) <= range:
				building_edges[b].append(other)
				all_edges.append([b, other])

	# 4. Powered Set (Prim's Variation)
	var powered_buildings: Array[Node2D] = []
	var powered_connections = []
	
	if not sources.is_empty():
		for source_node in sources:
			var b = source_node.get_parent()
			if not powered_buildings.has(b):
				powered_buildings.append(b)
				var receiver = _get_power_receiver(b)
				if receiver:
					receiver.is_powered = true
					receiver.efficiency = 1.0

		var changed = true
		while changed:
			changed = false
			var best_edge = null
			var min_dist = INF
			
			for p in powered_buildings:
				var p_range = _get_transmission_range(p)
				for neighbor in building_edges[p]:
					if powered_buildings.has(neighbor): continue
					
					var dist = p.global_position.distance_to(neighbor.global_position)
					if dist < min_dist:
						min_dist = dist
						best_edge = {"parent": p, "child": neighbor}
			
			if best_edge:
				var p = best_edge["parent"]
				var u = best_edge["child"]
				powered_buildings.append(u)
				powered_connections.append([p.global_position, u.global_position])
				var receiver = _get_power_receiver(u)
				if receiver:
					receiver.is_powered = true
					receiver.efficiency = 1.0
				changed = true

	# 5. Global Visual Connections (MST for the whole set of buildings)
	# For simplicity in visualising the "Grey" lines, we show all valid adjacencies
	# or an MST of unpowered islands. 
	# User requirement: "If i remove the second, the other two should still be connected"
	
	var unpowered_connections = []
	# We want to show lines that ARE valid physical connections but NOT powered
	for edge in all_edges:
		var b1 = edge[0]
		var b2 = edge[1]
		
		# If this specific connection isn't in powered_connections, 
		# and it represents a "closest" physical link, show it as grey.
		# Note: Prim's already gives us a tree. For unpowered, we can just show
		# all local adjacencies or a similar MST.
		
		# Simple approach: If both or either are unpowered, show it as a potential grey line
		# IF it's the "closest" neighbor to maintain the tree look.
		pass

	# Refined approach: Emit two sets of connections
	GameEvents.grid_updated.emit()
	
	# We will emit ALL valid connections, but the renderer will need to know which are powered
	# Or we emit two separate signals. Let's update the surge signal.
	
	var final_connections = []
	for edge in all_edges:
		var is_edge_powered = false
		for pc in powered_connections:
			if (edge[0].global_position == pc[0] and edge[1].global_position == pc[1]) or \
			   (edge[0].global_position == pc[1] and edge[1].global_position == pc[0]):
				is_edge_powered = true
				break
		
		# To avoid duplicate lines and messy visuals, we only show edges 
		# that are part of the local "closest node" tree.
		# For Milestone 3, let's just emit the powered ones and a set of "all valid adjacencies"
		# with a flag.
		pass

	GameEvents.surge_visual_requested.emit(powered_connections, false)
	# Emit unpowered ones (simple version: any edge not in powered_connections)
	var grey_connections = []
	for edge in all_edges:
		var p1 = edge[0].global_position
		var p2 = edge[1].global_position
		var found = false
		for pc in powered_connections:
			if (p1 == pc[0] and p2 == pc[1]) or (p1 == pc[1] and p2 == pc[0]):
				found = true
				break
		if not found:
			grey_connections.append([p1, p2])
	
	# We need a way to send unpowered lines. Let's add a parameter or new signal.
	GameEvents.unpowered_grid_visual_requested.emit(grey_connections)

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
	# Only buildings with a PowerSource (Core) or a PowerReceiver with 0 power requirement (Transmitter) can transmit.
	# Miners (PowerReceiver with > 0 requirement) cannot transmit.
	for child in node.get_children():
		if child is PowerSource:
			return child.transmission_range
		if child is PowerReceiver:
			if child.power_required <= 0: # This is a Transmitter
				return child.transmission_range
	return 0.0
