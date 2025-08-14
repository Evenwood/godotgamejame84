extends Node

@export var critter_scene: PackedScene
@onready var audio_player = $AudioStreamPlayer

var score
var time
var game_active = false
var critter_dict = {}
var paused = false

@onready var player = $Player
@onready var stats = $Stats

var critter_types = ["default", "default", "default", "default", "default"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Find the player and connect to its signal
	#var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("critter_swatted"):
		player.critter_swatted.connect(_on_critter_swatted)
		print("Critter connected to player's swat signal")
		
		
	
	var squish_sound = preload("res://art/squishwet.mp3")
	audio_player.stream = squish_sound
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(game_active):
		update_score()
		stats.update_stats()
	if (game_active && Input.is_action_just_pressed("escape")):
		process_pause()
	if(game_active && paused != true && Input.is_action_just_pressed("swat")):
		Core.num_swats += 1
	
func new_game():
	score = 0
	time = 0
	reset_game_state()
	
func reset_game_state() -> void:
	$HUD.update_score(score)
	$HUD.update_time(time)
	$HUD.show_message("Get Ready")
	$Player.start($StartPosition.position)
	$StartTimer.start()
	game_active = true

func _on_mob_timer_timeout() -> void:
	
	if player.is_powerup_active("freeze"):
		return
	if player.is_powerup_active("smoke_bomb"):
		return	
		
	_spawn_critter()
	
	var count = 0
	var critters = get_tree().get_nodes_in_group("critters")
	for c in critters:
		count += 1
	print("There are: " + str(count) + " mobs")

func _spawn_critter() -> void:
	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	
	var critter = critter_scene.instantiate()
	var critter_type = critter_types[randi() % critter_types.size()]
	# Set the mob's direction perpendicular to the path direction.
	var directionRadians = mob_spawn_location.rotation + PI / 2
	# Add some randomness to the direction.
	directionRadians += randf_range(-PI / 4, PI / 4)
	critter.setup(critter_type, mob_spawn_location.position, directionRadians)

	# Spawn the mob by adding it to the Main scene.
	add_child(critter)

func freeze_critters() -> void:
	var critters = get_tree().get_nodes_in_group("critters")
	for c in critters:
		critter_dict[c.name] = c.velocity
		c.velocity = Vector2(0,0)
	$MobTimer.stop()
		

func unfreeze_critters() -> void:
	var critters = get_tree().get_nodes_in_group("critters")
	for c in critters:
		c.velocity = critter_dict[c.name]
	$MobTimer.start()


func pause() -> void:
	paused = true
	freeze_critters()
	$ScoreTimer.stop()
	update_score()
	Engine.time_scale = 0
	$Pause.show()
	
	
func unpause() -> void:
	paused = false
	$Pause.hide()
	unfreeze_critters()
	$ScoreTimer.start()
	update_score()
	Engine.time_scale = 1


func process_pause() -> void:
	if(paused):
		unpause()
	else:
		pause()
		
func process_end_game() -> void:
	game_active = false
	$ScoreTimer.stop()
	$MobTimer.stop()
	var critters = get_tree().get_nodes_in_group("critters")
	for c in critters:
		c.queue_free()
	$HUD.show_message("Time's Up!")
	await get_tree().create_timer(2.0).timeout
	Engine.time_scale = 0
	update_score()
	stats.update_stats()
	stats.show()
	
func process_continue() -> void:
	Engine.time_scale = 1
	time = 0
	reset_game_state()

func process_restart() -> void:
	Core.reset_state()
	Engine.time_scale = 1
	new_game()
	
func update_score() -> void:
	score = Core.calculate_score()
	$HUD.update_score(score)
	
	
func _on_score_timer_timeout() -> void:
	time += 1
	Core.time_elapsed += 1
	$HUD.update_time(time)
	if(time >= Core.TIME_LIMIT):
		process_end_game()
		


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
	
	
func _on_critter_swatted(critter):
	Core.critters_squished += 1
	print("SWATTED: ", critter.name);
	print("Points: " + str(Core.calculate_score()))
	print("Num Swats: " + str(Core.num_swats))
	print("Successful Swats: " + str(Core.successful_swats))
	print("Critters Swatted: " + str(Core.critters_squished))
	print("Power Ups Collected: " + str(Core.power_ups_collected))
	audio_player.play()
	#$death_animation.position = critter.position
	#$death_animation.play()
	critter.get_swatted()
	critter.queue_free()


func _on_resume_from_pause() -> void:
	process_pause()


func _on_stats_continue_game() -> void:
	process_continue()


func _on_stats_restart_game() -> void:
	process_restart()
