extends CharacterBody2D

signal swat_started(start_position: Vector2)
signal swat_completed(final_position: Vector2)
signal swat_something(swat_object, swat_point: Vector2)

signal critter_swatted(critter)
signal player_collided(collision_object, collision_point: Vector2)
signal powerup_activated(powerup_type: String)
signal powerup_expired(powerup_type: String)

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

# Boundary settings
@export var boundary_margin: float = 20.0  # Distance from screen edge
var play_area: Rect2

var current_state = PlayerState.FOLLOWING_MOUSE
var target_position: Vector2
var swat_direction: Vector2

var pause_timer: float = 0.0

# Power-up system
var active_powerups: Dictionary = {}
var original_scale: Vector2
var critter_dict: Dictionary = {}

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Store original scale
	original_scale = scale
	
	_setup_play_area()
	
		# Add player to group for power-up detection
	add_to_group("player")
	# Connect signals to handler functions (can also connect in editor)
	player_collided.connect(_on_player_collided)
	# Connect to all power-ups in the scene
	_connect_to_powerups()

func _setup_play_area():
	# Get the viewport size
	var viewport = get_viewport().get_visible_rect()
	
	# Create play area with margins
	play_area = Rect2(
		boundary_margin,
		boundary_margin,
		viewport.size.x - (boundary_margin * 2),
		viewport.size.y - (boundary_margin)
	)

func _unhandled_input(event) -> void:
	if Input.is_action_just_pressed("swat"):
		# Start swat behavior
		target_position = get_global_mouse_position()
		swat_direction = (target_position - global_position).normalized()
		current_state = PlayerState.SWATTING
		swat_started.emit(target_position)

func _connect_to_powerups():
	var powerups = get_tree().get_nodes_in_group("powerups")
	for powerup in powerups:
		if powerup.has_signal("powerup_collected"):
			powerup.powerup_collected.connect(_on_powerup_collected)
			
func _on_powerup_collected(powerup_type: String, duration: float, effect_value: float):
	print("Power-up collected: ", powerup_type)
	# Apply the powerup effect
	match powerup_type:
		"size_boost":
			_apply_size_boost(duration, effect_value)
		"freeze":
			_apply_freeze(duration, effect_value)
		"smoke_bomb":
			_apply_smoke_bomb(1, effect_value)
		# Other powerups here
		_:
			print("Unknown power-up type: powerup_type")
	powerup_activated.emit(powerup_type)
	
func _apply_size_boost(duration: float, multiplier: float):
	# If size is already boosted then reset it
	if "size_boost" in active_powerups:
		var old_timer = active_powerups["size_boost"]
		old_timer.queue_free()
	# Apply size effect
	scale = original_scale * multiplier
	# Create timer for power=up duration
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(_remove_size_boost)
	add_child(timer)
	timer.start()
	# Store in active power-ups
	active_powerups["size_boost"] = timer

func _remove_size_boost():
	if "size_boost" in active_powerups:
		var timer = active_powerups["size_boost"]
		active_powerups.erase("size_boost")
		timer.queue_free()
		# Reset scale
		scale = original_scale
		powerup_expired.emit("size_boost")

func _apply_freeze(duration: float, multiplier: float):
	# If freeze is already boosted then reset it
	if "freeze" in active_powerups:
		var old_timer = active_powerups["freeze"]
		old_timer.queue_free()
	# Apply freeze effect
	var critters = get_tree().get_nodes_in_group("critters")
	for c in critters:
		critter_dict[c.name] = c.velocity
		c.velocity = Vector2(0,0)
	# Create timer for power=up duration
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(_remove_freeze)
	add_child(timer)
	timer.start()
	# Store in active power-ups
	active_powerups["freeze"] = timer		

func _remove_freeze():
	if "freeze" in active_powerups:
		var timer = active_powerups["freeze"]
		active_powerups.erase("freeze")
		timer.queue_free()
		# Reset freeze
		var critters = get_tree().get_nodes_in_group("critters")
		for c in critters:
			if c.name in critter_dict:
				c.velocity = critter_dict[c.name]
				critter_dict.erase(c.name)
		powerup_expired.emit("freeze")

func _apply_smoke_bomb(duration: float, multiplier: float):
	# If smoke bomb is already boosted then reset it
	if "smoke_bomb" in active_powerups:
		var old_timer = active_powerups["smoke_bomb"]
		old_timer.queue_free()
	# Apply freeze effect
	var critters = get_tree().get_nodes_in_group("critters")
	for c in critters:
		critter_swatted.emit(c)
	# Create timer for power=up duration
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(_remove_smoke_bomb)
	add_child(timer)
	timer.start()
	# Store in active power-ups
	active_powerups["smoke_bomb"] = timer		

func _remove_smoke_bomb():
	if "smoke_bomb" in active_powerups:
		var timer = active_powerups["smoke_bomb"]
		active_powerups.erase("smoke_bomb")
		timer.queue_free()
		powerup_expired.emit("smoke_bomb")
		
# Public method to check if a powerup is active
func is_powerup_active(powerup_type: String) -> bool:
	return powerup_type in active_powerups

# Get remaining time for a powerup
func get_powerup_time_remaining(powerup_type: String) -> float:
	if powerup_type in active_powerups:
		var timer = active_powerups[powerup_type]
		return timer.time_left
	return 0.0
		
func _physics_process(delta: float) -> void:
	match current_state:
		PlayerState.FOLLOWING_MOUSE:
			follow_mouse(delta)
		PlayerState.SWATTING:
			swat(delta)
		PlayerState.SWAT_PAUSE:
			swat_pause(delta)
	move_and_slide()
	
	_enforce_boundaries()
	
		# Check for collisions after moving
	if get_slide_collision_count() > 0:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			# If swatting and hit something, stop the swat
			if current_state == PlayerState.SWATTING:
				var swat_object = collision.get_collider()
				var swat_point = collision.get_position()
				swat_something.emit(swat_object, swat_point)
				player_collided.emit(swat_object, swat_point)
				swat_completed.emit(swat_point)
				velocity = Vector2.ZERO
				current_state = PlayerState.SWAT_PAUSE
				$CollisionShape2D.disabled = true
				
func _enforce_boundaries():
	# Clamp player position to play area
	global_position.x = clamp(global_position.x, play_area.position.x, play_area.position.x + play_area.size.x)
	global_position.y = clamp(global_position.y, play_area.position.y, play_area.position.y + play_area.size.y)

	# Stop velocity if hitting boundary (prevents sliding against edges)
	if global_position.x <= play_area.position.x or global_position.x >= play_area.position.x + play_area.size.x:
		velocity.x = 0
	if global_position.y <= play_area.position.y or global_position.y >= play_area.position.y + play_area.size.y:
		velocity.y = 0
		
func _on_player_collided(hit_object, collision_point: Vector2):
	print("Collision with ", hit_object.name, " at ", collision_point)
	if hit_object.is_in_group("critters"):
		print("Hit a critter")
		Core.successful_swats += 1
		critter_swatted.emit(hit_object)

func follow_mouse(delta : float) -> void:
	$CollisionShape2D.disabled = true
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
	$CollisionShape2D.disabled = false
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
		return

func swat_pause(delta):
	velocity = Vector2.ZERO  # Stay completely still
	pause_timer -= delta
	if pause_timer <= 0:
		current_state = PlayerState.FOLLOWING_MOUSE
		
func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
