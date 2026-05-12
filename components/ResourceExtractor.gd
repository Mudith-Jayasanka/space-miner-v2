extends Node2D
class_name ResourceExtractor

@export var mining_speed: float = 5.0 # Iron per second
@export var mining_range: float = 120.0

var target_asteroid: Asteroid = null
var is_active: bool = false

func _process(delta: float) -> void:
	if not is_active:
		return
		
	if target_asteroid == null or not is_instance_valid(target_asteroid):
		_find_target()
		
	if target_asteroid:
		var extracted = target_asteroid.extract_iron(mining_speed * delta)
		if extracted > 0:
			GameEvents.iron_collected.emit(extracted)
		else:
			target_asteroid = null # Asteroid depleted

func _find_target() -> void:
	var asteroids = get_tree().get_nodes_in_group("asteroids")
	var closest_dist = INF
	var closest_ast = null
	
	for ast in asteroids:
		if ast is Asteroid:
			# Get the distance between centers
			var dist = global_position.distance_to(ast.global_position)
			
			# Check if the circles intersect: 
			# Distance between centers <= (Miner Range + Asteroid Radius)
			var asteroid_radius = 64.0 # Default radius from tscn
			# Adjust for asteroid scale
			asteroid_radius *= ast.scale.x
			
			if dist <= (mining_range + asteroid_radius) and dist < closest_dist:
				closest_dist = dist
				closest_ast = ast
				
	target_asteroid = closest_ast
