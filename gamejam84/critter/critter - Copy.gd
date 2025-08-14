extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@export var speed = 200
var is_alive: bool = true
var critter_type: String = "forwarder"

var player

var animations_per_type: int = 4

var base_direction: Vector2       # The overall forward direction

# Zigzag parameters
var zigzag_timer: float = 0.0
var zigzag_interval: float = 0.5  # Time between direction changes
var zigzag_angle: float = 45.0    # Degrees to zigzag left/right
var is_zigzag_right: bool = true  # Current zigzag direction

# Spiraler parameters
var spiral_state: String = "forward"  # "forward" or "spiral"
var spiral_timer: float = 0.0
var spiral_forward_duration: float = 1.0    # How long to fly forward
var spiral_spiral_duration: float = 2.0     # How long to spiral
var spiral_center: Vector2                  # Center point for spiraling
var spiral_radius: float = 50.0             # Initial spiral radius
var spiral_angle: float = 0.0               # Current angle in spiral
var spiral_speed: float = 3.0               # How fast to rotate (radians per second)
var base_forward_direction: Vector2         # The critter's overall forward direction

# Faker parameters
var faker_timer: float = 0.0
var faker_current_interval: float = 1.0     # Time until next behavior change
var faker_speed_multiplier: float = 1.0     # Current speed modifier
var faker_base_velocity: Vector2            # The original velocity direction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("critters")
	
	player = get_tree().get_first_node_in_group("player")
		
	#var critter_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())

	#$AnimatedSprite2D.animation = critter_types.pick_random()
	#$AnimatedSprite2D.play()
	#pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if player.is_powerup_active("freeze"):
		return
		
	_process_critter_behavior(delta)

	# Move the character
	move_and_slide()
	
func _process_critter_behavior(delta):
	match critter_type:
		"zigzagger":
			_process_zigzagger(delta)
		"spiraler":
			_process_spiraler(delta)
		"faker":
			_process_faker(delta)
			
func _process_zigzagger(delta):
	zigzag_timer += delta
	if zigzag_timer >= zigzag_interval:
		zigzag_timer = 0.0
		is_zigzag_right = !is_zigzag_right  # Switch direction
		_update_zigzag_velocity()	
		
func _process_spiraler(delta):
	spiral_timer += delta
	
	match spiral_state:
		"forward":
			# Flying straight forward
			velocity = base_forward_direction * speed
			
			# Check if it's time to start spiraling
			if spiral_timer >= spiral_forward_duration:
				spiral_timer = 0.0
				spiral_state = "spiral"
				spiral_center = global_position
				spiral_angle = 0.0
				# Randomize next forward duration for variety
				spiral_forward_duration = randf_range(0.5, 2.0)
				
		"spiral":
			# Create spiral motion
			spiral_angle += spiral_speed * delta
			
			# Calculate position in spiral (expanding outward)
			var spiral_progress = spiral_timer / spiral_spiral_duration
			var current_radius = spiral_radius * (1.0 + spiral_progress * 0.5)  # Gradually expand
			
			var spiral_offset = Vector2(
				cos(spiral_angle) * current_radius,
				sin(spiral_angle) * current_radius
			)
			
			var target_position = spiral_center + spiral_offset
			
			# Move toward the spiral position
			var direction_to_spiral = (target_position - global_position).normalized()
			velocity = direction_to_spiral * speed
			
			# Check if spiral is complete
			if spiral_timer >= spiral_spiral_duration:
				spiral_timer = 0.0
				spiral_state = "forward"
				# Update forward direction based on current velocity
				base_forward_direction = velocity.normalized()
				# Randomize next spiral duration
				spiral_spiral_duration = randf_range(1.0, 3.0)

func _process_faker(delta):
	faker_timer += delta
	
	# Apply current speed multiplier to base velocity
	velocity = faker_base_velocity * faker_speed_multiplier
	
	# Check if it's time to change behavior
	if faker_timer >= faker_current_interval:
		faker_timer = 0.0
		_change_faker_behavior()

# Add this function to randomly change the faker's behavior
func _change_faker_behavior():
	# Randomize next interval (0.5 to 3 seconds)
	faker_current_interval = randf_range(0.5, 3.0)
	
	# Choose random behavior
	var behavior_roll = randf()
	
	if behavior_roll < 0.3:
		# 30% chance: Pause (stop completely)
		faker_speed_multiplier = 0.0
		print("Faker pausing")
		
	elif behavior_roll < 0.55:
		# 25% chance: Slow down significantly
		faker_speed_multiplier = randf_range(0.2, 0.5)
		print("Faker slowing down")
		
	elif behavior_roll < 0.75:
		# 20% chance: Speed up significantly  
		faker_speed_multiplier = randf_range(1.5, 2.5)
		print("Faker speeding up")
		
	else:
		# 25% chance: Normal speed
		faker_speed_multiplier = randf_range(0.8, 1.2)
		print("Faker normal speed")


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	
func setup(type: String, start_position: Vector2, start_radians: float):
	critter_type = type
	add_to_group("critters_" + critter_type)
	
	speed = randf_range(100.0, 500.0)
	
	_set_critter_sprite()
	
	match critter_type:
		"forwarder":
			_setup_forwarder(start_position, start_radians)
		"zigzagger":
			_setup_zigzagger(start_position, start_radians)
		"spiraler":
			_setup_spiraler(start_position, start_radians)
		"faker":
			_setup_faker(start_position, start_radians)
						
func _set_critter_sprite():
	# Just use the critter type as the animation name
	if $AnimatedSprite2D.sprite_frames.has_animation(critter_type):
		$AnimatedSprite2D.animation = critter_type
		$AnimatedSprite2D.play()
	else:
		# Fallback if animation doesn't exist
		print("Warning: No animation found for critter type: ", critter_type)
		# Use the first available animation as fallback
		var all_animations = $AnimatedSprite2D.sprite_frames.get_animation_names()
		if all_animations.size() > 0:
			$AnimatedSprite2D.animation = all_animations[0]
			$AnimatedSprite2D.play()
									
func _setup_forwarder(start_position: Vector2, startRadians: float):
	# Set the mob's position to the random location.
	position = start_position
	# Choose the velocity for the mob.
	#velocity = Vector2(randf_range(100.0, 350.0), 0.0)
	velocity = Vector2(1.0, 0.0) * speed
	velocity = velocity.rotated(startRadians)
	
func _setup_zigzagger(start_position: Vector2, start_radians: float):
	position = start_position
	base_direction = Vector2(1.0, 0.0).rotated(start_radians)
	
	# Randomize the zigzag parameters for variety
	zigzag_interval = randf_range(0.3, 0.7)
	zigzag_angle = randf_range(30.0, 60.0)
	
	# Start with initial zigzag direction
	_update_zigzag_velocity()

func _setup_spiraler(start_position: Vector2, start_radians: float):
	position = start_position
	base_forward_direction = Vector2(1.0, 0.0).rotated(start_radians)
	
	# Randomize parameters for variety
	spiral_forward_duration = randf_range(0.5, 2.0)
	spiral_spiral_duration = randf_range(1.0, 3.0)
	spiral_radius = randf_range(40.0, 80.0)
	spiral_speed = randf_range(2.0, 5.0)
	
	# Start in forward state
	spiral_state = "forward"
	spiral_timer = 0.0
	velocity = base_forward_direction * speed

func _setup_faker(start_position: Vector2, start_radians: float):
	position = start_position
	
	# Set base velocity (the "normal" movement)
	faker_base_velocity = Vector2(1.0, 0.0).rotated(start_radians) * speed
	
	# Start with normal speed
	faker_speed_multiplier = 1.0
	
	# Randomize first interval
	faker_current_interval = randf_range(0.5, 2.0)
	faker_timer = 0.0
	
	# Set initial velocity
	velocity = faker_base_velocity
	
func _update_zigzag_velocity():
	var zigzag_offset = deg_to_rad(zigzag_angle if is_zigzag_right else -zigzag_angle)
	velocity = base_direction.rotated(zigzag_offset) * speed
	
func get_swatted():
	if not is_alive:
		return

	print("Critter got swatted!")
	is_alive = false

	# Create explosion effect
	_create_critter_particles()

	# Hide the original sprite
	animated_sprite.visible = false
	
func _create_critter_particles():
	# Create multiple sprite pieces that fly apart
	var piece_count = randi_range(3, 8)
	var explosion_force = 400.0

	for i in range(piece_count):
		var piece = _create_sprite_piece()
		get_parent().add_child(piece)

		# Random direction
		var angle = (i * 2.0 * PI) / piece_count + randf_range(-0.5, 0.5)
		var direction = Vector2(cos(angle), sin(angle))

		# Apply physics
		piece.global_position = global_position
		piece.linear_velocity = direction * explosion_force * randf_range(0.7, 1.3)
		
func _create_sprite_piece() -> RigidBody2D:
	var piece = RigidBody2D.new()
	var sprite = Sprite2D.new()

	# Copy the current frame from animated sprite
	sprite.texture = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)

	# Make it smaller (like a fragment)
	sprite.scale = Vector2(0.5, 0.5)
	sprite.modulate = Color(1, 1, 1, 0.8)

	piece.add_child(sprite)

	# Physics properties
	piece.gravity_scale = 0
	piece.linear_damp = 2.0
	# Add rotation
	piece.angular_velocity = randf_range(-10, 10)

	# Remove the piece after 0.5 seconds
	get_tree().create_timer(0.5).timeout.connect(func(): piece.queue_free())

	return piece

	
