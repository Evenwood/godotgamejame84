# PowerUpSpawner.gd
extends Node2D

@export var size_powerup_scene: PackedScene
@export var spawn_interval: float = Core.POWER_UP_SPAWN_RATE
@export var max_powerups: int = Core.MAX_POWER_UPS

var spawn_timer: Timer

var powerup_types = ["size_boost", "freeze", "smoke_bomb"]

func _ready():
	# Create and setup timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_spawn_powerup)
	add_child(spawn_timer)
	spawn_timer.start()

func _spawn_powerup():
	# Randomly choose powerup type
	var random_type = powerup_types[randi() % powerup_types.size()]	
	var group_name = "powerup_" + random_type
	# Check limits per type
	var existing_count = get_tree().get_nodes_in_group(group_name).size()
	if existing_count >= 1:  # Only 1 of each type
		return
		
	var current_powerups = get_tree().get_nodes_in_group("powerups")
	if current_powerups.size() >= max_powerups:
		print("Max power-ups reached, skipping spawn")
		return
		
	var powerup = size_powerup_scene.instantiate()
	powerup.powerup_type = random_type # This will change its type
	
	# Random position on screen
	var viewport_size = get_viewport().get_visible_rect().size
	powerup.global_position = Vector2(
		randf() * viewport_size.x,
		randf() * viewport_size.y
	)

	# Connect to player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		powerup.powerup_collected.connect(player._on_powerup_collected)

	get_parent().add_child(powerup)
	print("Power-up spawned!")
