extends BaseBehavior
class_name FakerBehavior

var faker_timer: float = 0.0
var faker_current_interval: float = 1.0
var faker_speed_multiplier: float = 1.0
var faker_base_velocity: Vector2

func _setup_behavior(start_position: Vector2, start_radians: float):
	faker_base_velocity = Vector2(1.0, 0.0).rotated(start_radians) * critter.speed
	faker_speed_multiplier = 1.0
	faker_current_interval = randf_range(0.5, 2.0)
	faker_timer = 0.0
	critter.velocity = faker_base_velocity

func process_behavior(delta: float):
	faker_timer += delta
	critter.velocity = faker_base_velocity * faker_speed_multiplier
	
	if faker_timer >= faker_current_interval:
		faker_timer = 0.0
		_change_faker_behavior()

func _change_faker_behavior():
	faker_current_interval = randf_range(0.5, 3.0)
	var behavior_roll = randf()
	
	if behavior_roll < 0.3:
		faker_speed_multiplier = 0.0
	elif behavior_roll < 0.55:
		faker_speed_multiplier = randf_range(0.2, 0.5)
	elif behavior_roll < 0.75:
		faker_speed_multiplier = randf_range(1.5, 2.5)
	else:
		faker_speed_multiplier = randf_range(0.8, 1.2)
