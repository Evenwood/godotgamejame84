extends RefCounted
class_name PlayerMovement

signal swat_started(start_position: Vector2)
signal swat_completed(final_position: Vector2)

enum PlayerState {
	FOLLOWING_MOUSE,
	SWATTING,
	SWAT_PAUSE
}

# Settings
@export var follow_speed: float = 400.0
@export var follow_acceleration: float = 10.0
@export var swat_acceleration: float = 10000.0
@export var max_swat_speed: float = 2000.0
@export var max_velocity_magnitude: float = 2500.0  # Safety net

var player: CharacterBody2D
var current_state = PlayerState.FOLLOWING_MOUSE
var target_position: Vector2
var swat_direction: Vector2
var pause_timer: float = 0.0
var force_stop: bool = false  # Emergency stop flag

func setup(player_ref: CharacterBody2D):
	player = player_ref

func handle_input(event) -> void:
	if Input.is_action_just_pressed("swat") and current_state == PlayerState.FOLLOWING_MOUSE:
		target_position = player.get_global_mouse_position()
		swat_direction = (target_position - player.global_position).normalized()
		
		# Validate swat direction
		if swat_direction.length() < 0.1:
			return  # Don't swat if too close to mouse
			
		current_state = PlayerState.SWATTING
		force_stop = false
		swat_started.emit(target_position)

func process_movement(delta: float) -> void:
	# Emergency velocity check - prevents runaway velocity
	if player.velocity.length() > max_velocity_magnitude:
		print("WARNING: Velocity too high, emergency stop!")
		emergency_stop()
		return
	
	# Handle force stop
	if force_stop:
		player.velocity = Vector2.ZERO
		current_state = PlayerState.FOLLOWING_MOUSE
		force_stop = false
		return
	
	match current_state:
		PlayerState.FOLLOWING_MOUSE:
			_follow_mouse(delta)
		PlayerState.SWATTING:
			_swat(delta)
		PlayerState.SWAT_PAUSE:
			_swat_pause(delta)

func _follow_mouse(delta: float) -> void:
	player.get_node("CollisionShape2D").disabled = true
	var mouse_pos = player.get_global_mouse_position()
	var distance_to_mouse = player.global_position.distance_to(mouse_pos)
	
	if distance_to_mouse < 5.0:
		player.velocity = player.velocity.lerp(Vector2.ZERO, follow_acceleration * delta)
		return
	
	var direction = (mouse_pos - player.global_position).normalized()
	var target_velocity = direction * follow_speed
	player.velocity = player.velocity.lerp(target_velocity, follow_acceleration * delta)
	# Safety clamp for follow mode too
	if player.velocity.length() > follow_speed * 1.5:
		player.velocity = player.velocity.normalized() * follow_speed
		
func _swat(delta: float) -> void:
	player.get_node("CollisionShape2D").disabled = false
	var start_position = player.global_position
	var distance_to_target = start_position.distance_to(target_position)
	
	if distance_to_target < 15.0:
		player.velocity = Vector2.ZERO
		player.global_position = target_position
		current_state = PlayerState.FOLLOWING_MOUSE
		swat_completed.emit(target_position)
		return
	
	var acceleration_vector = swat_direction * swat_acceleration * delta
	player.velocity += acceleration_vector
	
	if player.velocity.length() > max_swat_speed:
		player.velocity = player.velocity.normalized() * max_swat_speed
	
	var next_position = player.global_position + player.velocity * delta
	var distance_this_frame = start_position.distance_to(next_position)
	
	if distance_this_frame >= distance_to_target:
		player.velocity = Vector2.ZERO
		player.global_position = target_position
		current_state = PlayerState.FOLLOWING_MOUSE
		swat_completed.emit(target_position)

func _swat_pause(delta: float):
	player.velocity = Vector2.ZERO
	pause_timer -= delta
	if pause_timer <= 0:
		current_state = PlayerState.FOLLOWING_MOUSE

func start_swat_pause():
	current_state = PlayerState.SWAT_PAUSE
	pause_timer = 0.1
	player.velocity = Vector2.ZERO  # Ensure velocity is cleared

func emergency_stop():
	#-- Emergency stop function to handle runaway velocity
	player.velocity = Vector2.ZERO
	current_state = PlayerState.FOLLOWING_MOUSE
	force_stop = true
	print("Emergency stop activated!")

func interrupt_swat():
	#-- Clean way to interrupt a swat from external sources
	if current_state == PlayerState.SWATTING:
		player.velocity = Vector2.ZERO
		start_swat_pause()
