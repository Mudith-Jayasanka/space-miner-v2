extends Node

# Global Event Bus for decoupled communication

# Building Events
signal building_placed(building: Node2D)
signal building_removed(building: Node2D)

# Grid Events
signal grid_updated()

# Resource Events
signal iron_collected(amount: float)

# Visual/VFX Events
signal surge_visual_requested(path: Array, is_preview: bool)
