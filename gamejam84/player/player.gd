extends CharacterBody2D

# Signals
signal swat_started(start_position: Vector2)
signal swat_completed(final_position: Vector2)
signal swat_something(swat_object, swat_point: Vector2)
signal critter_swatted(critter, damage)
signal player_collided(collision_object, collision_point: Vector2)
signal powerup_activated(powerup_type: String)
signal powerup_expired(powerup_type: String)
signal smoke_bomb_hit(critter, damage)

# Core components - delegate responsibilities
@onready var movement_handler = PlayerMovement.new()
@onready var powerup_handler = PlayerPowerups.new()
@onready var boundary_handler = PlayerBoundaries.new()

@export var damage = 1

var collision_handler: PlayerCollision

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = true

func _ready() -> void:
	add_to_group("player")
	damage = Core.PLAYER_BASE_DAMAGE
	scale = Core.PLAYER_BASE_SCALE
	
	# Initialize components
	movement_handler.setup(self)
	powerup_handler.setup(self)
	boundary_handler.setup(self)
	collision_handler = PlayerCollision.new(self, movement_handler)
	
	# Connect component signals to main player signals
	_connect_component_signals()
	
	# Connect to powerups in scene
	_connect_to_powerups()


func update_player_stats():
	damage = Core.PLAYER_BASE_DAMAGE + Core.damage_increase
	scale = Core.PLAYER_BASE_SCALE + (Core.size_increase * Core.SCALE_INCREMENT)

func reset_player():
	damage = Core.PLAYER_BASE_DAMAGE
	scale = Core.PLAYER_BASE_SCALE

func _connect_component_signals():
	# Forward movement signals
	movement_handler.swat_started.connect(func(pos): swat_started.emit(pos))
	movement_handler.swat_completed.connect(func(pos): swat_completed.emit(pos))
	
	# Forward powerup signals  
	powerup_handler.powerup_activated.connect(func(type): powerup_activated.emit(type))
	powerup_handler.powerup_expired.connect(func(type): powerup_expired.emit(type))
	
	# Forward collision signals
	collision_handler.player_collided.connect(func(obj, point): player_collided.emit(obj, point))
	collision_handler.swat_something.connect(\
		func(obj, point): swat_something.emit(obj, point))
	collision_handler.critter_swatted.connect(\
		func(critter): critter_swatted.emit(critter, damage))
	collision_handler.swat_interrupted.connect(_on_swat_interrupted)
	
func _connect_to_powerups():
	var powerups = get_tree().get_nodes_in_group("powerups")
	for powerup in powerups:
		if powerup.has_signal("powerup_collected"):
			powerup.powerup_collected.connect(_on_powerup_collected)

func _on_powerup_collected(powerup_type: String, duration: float, effect_value: float):
	powerup_handler.activate_powerup(powerup_type, duration, effect_value)

func _unhandled_input(event) -> void:
	movement_handler.handle_input(event)

func _physics_process(delta: float) -> void:
	movement_handler.process_movement(delta)
	move_and_slide()
	boundary_handler.enforce_boundaries(self)
	collision_handler.check_collisions()

# Public interface for other systems
func is_powerup_active(powerup_type: String) -> bool:
	return powerup_handler.is_powerup_active(powerup_type)

func get_powerup_time_remaining(powerup_type: String) -> float:
	return powerup_handler.get_powerup_time_remaining(powerup_type)

func _on_swat_interrupted(collision_point: Vector2):
	# Use the movement handler's interrupt method instead
	movement_handler.interrupt_swat()
	swat_completed.emit(collision_point)
	$CollisionShape2D.disabled = true
