extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@export var speed = 200
var is_alive: bool = true
var critter_type: String = "forwarder"
var player

# Behavior handler - all movement is delegated to this
var behavior_handler

func _ready() -> void:
	add_to_group("critters")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if player.is_powerup_active("freeze"):
		return
		
	if behavior_handler:
		behavior_handler.process_behavior(delta)
	
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	
func setup(type: String, start_position: Vector2, start_radians: float):
	critter_type = type
	add_to_group("critters_" + critter_type)
	speed = randf_range(100.0, 500.0)
	
	_set_critter_sprite()
	_create_behavior_handler(type, start_position, start_radians)

func _set_critter_sprite():
	if $AnimatedSprite2D.sprite_frames.has_animation(critter_type):
		$AnimatedSprite2D.animation = critter_type
		$AnimatedSprite2D.play()
	else:
		print("Warning: No animation found for critter type: ", critter_type)
		var all_animations = $AnimatedSprite2D.sprite_frames.get_animation_names()
		if all_animations.size() > 0:
			$AnimatedSprite2D.animation = all_animations[0]
			$AnimatedSprite2D.play()

func _create_behavior_handler(type: String, start_position: Vector2, start_radians: float):
	match type:
		"forwarder":
			behavior_handler = ForwarderBehavior.new()
		"zigzagger":
			behavior_handler = ZigzaggerBehavior.new()
		"spiraler":
			behavior_handler = SpiralerBehavior.new()
		"faker":
			behavior_handler = FakerBehavior.new()
		"chaser":
			behavior_handler = ChaserBehavior.new()
			scale = Vector2(2.0, 2.0)
		_:
			behavior_handler = ForwarderBehavior.new()
	
	behavior_handler.setup(self, start_position, start_radians)

func get_swatted():
	if not is_alive:
		return

	print("Critter got swatted!")
	is_alive = false
	_create_critter_particles()
	animated_sprite.visible = false
	
func _create_critter_particles():
	var piece_count = randi_range(3, 8)
	var explosion_force = 400.0

	for i in range(piece_count):
		var piece = _create_sprite_piece()
		get_parent().add_child(piece)

		var angle = (i * 2.0 * PI) / piece_count + randf_range(-0.5, 0.5)
		var direction = Vector2(cos(angle), sin(angle))

		piece.global_position = global_position
		piece.linear_velocity = direction * explosion_force * randf_range(0.7, 1.3)
		
func _create_sprite_piece() -> RigidBody2D:
	var piece = RigidBody2D.new()
	var sprite = Sprite2D.new()

	sprite.texture = animated_sprite.sprite_frames.get_frame_texture(\
		animated_sprite.animation, animated_sprite.frame)
	sprite.scale = Vector2(0.5, 0.5)
	sprite.modulate = Color(1, 1, 1, 0.8)

	piece.add_child(sprite)
	piece.gravity_scale = 0
	piece.linear_damp = 2.0
	piece.angular_velocity = randf_range(-10, 10)

	get_tree().create_timer(0.5).timeout.connect(func(): piece.queue_free())
	return piece
