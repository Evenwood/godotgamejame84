extends CharacterBody2D

signal swat_started(start_position: Vector2)
signal swat_completed(final_position: Vector2)
signal swat_something(swat_object, swat_point: Vector2)

enum PlayerState {
	FOLLOWING_MOUSE,
	SWATTING,
	SWAT_PAUSE
}

# Mouse following settings
@export var follow_speed: float = 400.0
@export var follow_acceleration: float = 10.0

# Swat settings
@export var swat_acceleration: float = 10000.0
@export var max_swat_speed: float = 2000.0

var current_state = PlayerState.FOLLOWING_MOUSE
var target_position: Vector2
var swat_direction: Vector2

var pause_timer: float = 0.0

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _unhandled_input(event) -> void:
	if Input.is_action_just_pressed("swat"):
		# Start swat behavior
		target_position = get_global_mouse_position()
		swat_direction = (target_position - global_position).normalized()
		current_state = PlayerState.SWATTING
		swat_started.emit(target_position)
		print("Swatting to: ", target_position)

func _physics_process(delta: float) -> void:
	match current_state:
		PlayerState.FOLLOWING_MOUSE:
			follow_mouse(delta)
		PlayerState.SWATTING:
			swat(delta)
		PlayerState.SWAT_PAUSE:
			swat_pause(delta)
	move_and_slide()
	
		# Check for collisions after moving
	if get_slide_collision_count() > 0:
		print("Bumped into something!")
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			print("Hit: ", collision.get_collider().name)
			
			# If swatting and hit something, stop the swat
			if current_state == PlayerState.SWATTING:
				var swat_object = collision.get_collider()
				var swat_point = collision.get_position()
				swat_something.emit(swat_object, swat_point)
				swat_completed.emit(swat_point)
				velocity = Vector2.ZERO
				current_state = PlayerState.SWAT_PAUSE
				print("Swat interrupted by collision!")

func follow_mouse(delta : float) -> void:
	# Get the mouse position and calculate direction
	var mouse_pos = get_global_mouse_position()
	var distance_to_mouse = global_position.distance_to(mouse_pos)
	
	# Add dead zone - stop moving when very close to mouse
	if distance_to_mouse < 5.0:
		velocity = velocity.lerp(Vector2.ZERO, follow_acceleration * delta)
		return
	
	var direction = (mouse_pos - global_position).normalized()
	
	# Scale speed based on distance (slower when closer)
	#min(follow_speed, distance_to_mouse * 2.0)
	var adjusted_speed = follow_speed 
	
	# Calculate target velocity and smoothly interpolate
	var target_velocity = direction * adjusted_speed
	velocity = velocity.lerp(target_velocity, follow_acceleration * delta)
	
func swat(delta : float) -> void:
	# Store current position before moving
	var start_position = global_position
	
	# Calculate distance to target
	var distance_to_target = start_position.distance_to(target_position)
	
	# If we're very close, stop abruptly
	if distance_to_target < 15.0:
		velocity = Vector2.ZERO  # Immediate stop
		global_position = target_position  # Snap to exact position
		current_state = PlayerState.FOLLOWING_MOUSE
		swat_completed.emit(target_position)
		print("Swat complete - abrupt stop!")
		return
	
	# Accelerate toward target
	var acceleration_vector = swat_direction * swat_acceleration * delta
	velocity += acceleration_vector
	
	# Clamp to max speed
	if velocity.length() > max_swat_speed:
		velocity = velocity.normalized() * max_swat_speed
	
	# Check if we would overshoot this frame
	var next_position = global_position + velocity * delta
	var distance_this_frame = start_position.distance_to(next_position)
	
	# If we're going to overshoot, just go directly to target
	if distance_this_frame >= distance_to_target:
		velocity = Vector2.ZERO
		global_position = target_position
		current_state = PlayerState.FOLLOWING_MOUSE
		swat_completed.emit(target_position)
		print("Prevented overshoot - landed exactly!")
		return

func swat_pause(delta):
	velocity = Vector2.ZERO  # Stay completely still
	pause_timer -= delta
	if pause_timer <= 0:
		current_state = PlayerState.FOLLOWING_MOUSE
		
func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
