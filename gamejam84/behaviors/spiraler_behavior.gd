extends BaseBehavior
class_name SpiralerBehavior

var spiral_state: String = "forward"
var spiral_timer: float = 0.0
var spiral_forward_duration: float = 1.0
var spiral_spiral_duration: float = 2.0
var spiral_center: Vector2
var spiral_radius: float = 50.0
var spiral_angle: float = 0.0
var spiral_speed: float = 3.0
var base_forward_direction: Vector2

func _setup_behavior(start_position: Vector2, start_radians: float):
	base_forward_direction = Vector2(1.0, 0.0).rotated(start_radians)
	spiral_forward_duration = randf_range(0.5, 2.0)
	spiral_spiral_duration = randf_range(1.0, 3.0)
	spiral_radius = randf_range(40.0, 80.0)
	spiral_speed = randf_range(2.0, 5.0)
	spiral_state = "forward"
	spiral_timer = 0.0
	critter.velocity = base_forward_direction * critter.speed

func process_behavior(delta: float):
	spiral_timer += delta
	
	match spiral_state:
		"forward":
			critter.velocity = base_forward_direction * critter.speed
			if spiral_timer >= spiral_forward_duration:
				spiral_timer = 0.0
				spiral_state = "spiral"
				spiral_center = critter.global_position
				spiral_angle = 0.0
				spiral_forward_duration = randf_range(0.5, 2.0)
				
		"spiral":
			spiral_angle += spiral_speed * delta
			var spiral_progress = spiral_timer / spiral_spiral_duration
			var current_radius = spiral_radius * (1.0 + spiral_progress * 0.5)
			
			var spiral_offset = Vector2(
				cos(spiral_angle) * current_radius,
				sin(spiral_angle) * current_radius
			)
			
			var target_position = spiral_center + spiral_offset
			var direction_to_spiral = (target_position - critter.global_position).normalized()
			critter.velocity = direction_to_spiral * critter.speed
			
			if spiral_timer >= spiral_spiral_duration:
				spiral_timer = 0.0
				spiral_state = "forward"
				base_forward_direction = critter.velocity.normalized()
				spiral_spiral_duration = randf_range(1.0, 3.0)
