extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@export var speed = 200
@export var HP = 1
@export var point_mod = 0

var is_alive: bool = true
var critter_type: String = "forwarder"
var player

# Health bar
@export var health_bar_scene: PackedScene  # Assign your health bar scene
var health_bar: HealthBar
var health_bar_offset: Vector2 = Vector2(0, 8)  # Position below critter

# Behavior handler - all movement is delegated to this
var behavior_handler

@onready var quest_marker: Label = null

func _ready() -> void:
	add_to_group("critters")
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta):
	if player.is_powerup_active("freeze"):
		return
		
	if behavior_handler:
		behavior_handler.process_behavior(delta)
	# Update health bar position
	_update_health_bar_position()
	move_and_slide()
	
func _update_health_bar_position():
	# Get current frame texture to determine sprite size
	var current_texture = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)
	var sprite_height: float = 32.0  # Default fallback
	var sprite_width: float = 32.0  # Default fallback
	
	if current_texture:
		sprite_height = current_texture.get_size().y
		sprite_width = current_texture.get_size().x
	
	# Calculate position below the scaled sprite
	var scaled_height = sprite_height * scale.y
	var scaled_width = sprite_width * scale.x
	var critter_bottom = global_position.y
	
	if health_bar:
		health_bar.global_position = Vector2(
			global_position.x - (scaled_width / 2) - (health_bar.size.x / 2),
			critter_bottom + 5
		)
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Clean up health bar when critter exits screen
	if health_bar:
		health_bar.queue_free()
	queue_free()
	
func setup(type: String, start_position: Vector2, start_radians: float):
	critter_type = type
	add_to_group("critters_" + critter_type)
	speed = randf_range(100.0, 500.0)
	# Set HP based on critter type
	if critter_type == "chaser":
		HP = Core.TOUGH_CRITTER_HP
	else:
		HP = Core.REG_CRITTER_HP
	scale_critter()  # Modify parameters based on current level (Higher Level = Tougher Critters)
	_set_critter_sprite()
	_create_behavior_handler(type, start_position, start_radians)
	_create_health_bar()
	
func _create_health_bar():
	# Only show health bar if HP > 1
	if HP <= 1:
		return
	
	if health_bar_scene:
		health_bar = health_bar_scene.instantiate()
		# Add to a UI layer or the main scene, not as child of critter
		get_tree().current_scene.add_child(health_bar)
		# Pass 'self' as the owner so health bar can clean up automatically
		health_bar.setup(HP, self)

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

func scale_critter():
	speed += randf_range(0.0, Core.level * Core.VELOCITY_INCREMENT)
	HP += randi_range(0, Core.level / 2)
	if(HP > Core.TOUGH_CRITTER_HP):
		point_mod = (HP - Core.TOUGH_CRITTER_HP) * 2
		
func register_squished_critter():
	match critter_type:
		"forwarder":
			Core.forwarders += 1
		"zigzagger":
			Core.zigzaggers += 1
		"spiraler":
			Core.spiralers += 1
		"faker":
			Core.fakers += 1
		"chaser":
			Core.chasers += 1
		_:
			Core.forwarders += 1

func get_swatted(damage) -> int:
	# Return actual damage dealt, 0 if no damage
	if HP <= 0:
		return 0  # Already dead
		
	var damage_dealt = damage
	Core.successful_swats += 1

	print("Was Swatted")
	print("Damage Dealt: " + str(damage_dealt))
	HP -= damage_dealt
	
	# Update health bar
	if health_bar:
		health_bar.update_health(HP)
	
	if HP <= 0:
		_die()
		
	return damage_dealt
	
func _die():
	$CollisionShape2D.disabled = true
	_create_critter_particles()
	animated_sprite.visible = false
	
	# Remove health bar
	if health_bar:
		health_bar.queue_free()
		health_bar = null
			
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
	
func set_quest_marker(show_marker: bool, symbol: String = "★", color: Color = Color.GOLD):
	if show_marker:
		_remove_quest_marker()  # Remove any existing marker
		quest_marker = Label.new()
		quest_marker.text = symbol  # Could be "★", "!", "?", "♦", etc.
		quest_marker.modulate = color
		quest_marker.add_theme_font_size_override("font_size", 12)
		var critter_size = get_critter_size()
		# Position marker above the critter (centered horizontally, above vertically)
		#quest_marker.position = Vector2(-12, -critter_size.y/2 - 15)
		quest_marker.position = Vector2(-critter_size.x/2, -critter_size.y)
		quest_marker.z_index = 10
		add_child(quest_marker)
	else:
		_remove_quest_marker()

func get_critter_size() -> Vector2:
	var animated_sprite = $AnimatedSprite2D
	if not animated_sprite:
		return Vector2.ZERO
	# Get current frame texture size (most accurate)
	var current_texture = animated_sprite.sprite_frames.get_frame_texture(\
		animated_sprite.animation, animated_sprite.frame)
	if current_texture:
		return current_texture.get_size() * animated_sprite.scale
	# Fallback
	return Vector2(32, 32) * animated_sprite.scale
	
func _remove_quest_marker():
	if quest_marker and is_instance_valid(quest_marker):
		quest_marker.queue_free()
		quest_marker = null

# Call this in your critter's _exit_tree to clean up
func _exit_tree():
	_remove_quest_marker()
