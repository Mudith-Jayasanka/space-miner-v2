extends Node2D
class_name PowerSource

@export var power_output: float = 100.0
@export var transmission_range: float = 150.0

# This component is primarily a data container for the GridManager
# but can be extended for visual effects (e.g. idle animations)
