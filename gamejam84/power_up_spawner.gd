# PowerUpSpawner.gd
extends Node2D

@export var size_powerup_scene: PackedScene
@export var spawn_interval: float = 10.0
@export var max_powerups: int = 3

var spawn_timer: Timer

func _ready():
	# Create and setup timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_spawn_powerup)
	add_child(spawn_timer)
	spawn_timer.start()

func _spawn_powerup():
	var current_powerups = get_tree().get_nodes_in_group("powerups")

	if current_powerups.size() < max_powerups:
		var powerup = size_powerup_scene.instantiate()

		# Random position on screen
		var viewport_size = get_viewport().get_visible_rect().size
		powerup.global_position = Vector2(
			randf() * viewport_size.x,
			randf() * viewport_size.y
		)

		# Add to powerups group
		powerup.add_to_group("powerups")

		# Connect to player
		var player = get_tree().get_first_node_in_group("player")
		if player:
			powerup.powerup_collected.connect(player._on_powerup_collected)

		get_parent().add_child(powerup)
		print("✨ Size power-up spawned!")
