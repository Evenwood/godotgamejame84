extends BaseBehavior
class_name ForwarderBehavior

func _setup_behavior(start_position: Vector2, start_radians: float):
	critter.velocity = Vector2(1.0, 0.0).rotated(start_radians) * critter.speed

func process_behavior(delta: float):
	# Forwarder just maintains its velocity - no processing needed
	pass
