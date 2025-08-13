extends RigidBody2D

@onready var animated_sprite = $AnimatedSprite2D
var is_alive: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("critters")

		
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())

	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play()
	#pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	
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
	var timer = Timer.new()
	timer.wait_time = 0.5  
	timer.one_shot = true
	timer.timeout.connect(func(): piece.queue_free())
	get_parent().add_child(timer)
	timer.start()

	return piece

	
