extends Node

@export var mob_scene: PackedScene
@onready var audio_player = $AudioStreamPlayer

var score
var time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Find the player and connect to its signal
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("critter_swatted"):
		player.critter_swatted.connect(_on_critter_swatted)
		print("Critter connected to player's swat signal")
	
	var squish_sound = preload("res://art/squishwet.mp3")
	audio_player.stream = squish_sound
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func game_over() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	
func new_game():
	score = 0
	time = 0
	$HUD.update_score(score)
	$HUD.update_time(time)
	$HUD.show_message("Get Ready")
	$Player.start($StartPosition.position)
	$StartTimer.start()

func _on_mob_timer_timeout() -> void:
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_score_timer_timeout() -> void:
	score += 1
	time += 1
	$HUD.update_score(score)
	$HUD.update_time(time)
	if(time >= Core.TIME_LIMIT):
		game_over()

func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
	
func _on_critter_swatted(critter):
	print("SWATTED: ", critter.name);
	audio_player.play()
	critter.queue_free()
	
