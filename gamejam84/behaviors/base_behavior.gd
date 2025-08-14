extends RefCounted
class_name BaseBehavior

var critter: CharacterBody2D

func setup(critter_ref: CharacterBody2D, start_position: Vector2, start_radians: float):
	critter = critter_ref
	critter.position = start_position
	_setup_behavior(start_position, start_radians)

func _setup_behavior(start_position: Vector2, start_radians: float):
	# Will be overridden in child classes
	pass

func process_behavior(delta: float):
	# Will be overridden in child classes
	pass
