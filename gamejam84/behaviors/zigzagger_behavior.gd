extends BaseBehavior
class_name ZigzaggerBehavior

var base_direction: Vector2
var zigzag_timer: float = 0.0
var zigzag_interval: float = 0.5
var zigzag_angle: float = 45.0
var is_zigzag_right: bool = true

func _setup_behavior(start_position: Vector2, start_radians: float):
	base_direction = Vector2(1.0, 0.0).rotated(start_radians)
	zigzag_interval = randf_range(0.3, 0.7)
	zigzag_angle = randf_range(30.0, 60.0)
	_update_zigzag_velocity()

func process_behavior(delta: float):
	zigzag_timer += delta
	if zigzag_timer >= zigzag_interval:
		zigzag_timer = 0.0
		is_zigzag_right = !is_zigzag_right
		_update_zigzag_velocity()

func _update_zigzag_velocity():
	var zigzag_offset = deg_to_rad(zigzag_angle if is_zigzag_right else -zigzag_angle)
	critter.velocity = base_direction.rotated(zigzag_offset) * critter.speed
