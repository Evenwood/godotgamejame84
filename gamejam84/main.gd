extends Node

@export var mob_scene: PackedScene
@onready var audio_player = $AudioStreamPlayer

var score
var time
var game_active = false
var critter_dict = {}
var paused = false

@onready var player = $Player

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
	if Input.is_action_just_pressed("escape"):
		processPause()
	if(game_active && paused != true && Input.is_action_just_pressed("swat")):
		Core.num_swats += 1


func game_over() -> void:
	game_active = false
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
	game_active = true

func _on_mob_timer_timeout() -> void:
	
	if player.is_powerup_active("freeze"):
		return
	if player.is_powerup_active("smoke_bomb"):
		return	
		
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
	var velocity = Vector2(randf_range(100.0, 350.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	
	var count = 0
	var critters = get_tree().get_nodes_in_group("critters")
	for c in critters:
		count += 1
	print("There are: " + str(count) + " mobs")


func freeze_critters() -> void:
	var critters = get_tree().get_nodes_in_group("critters")
	for c in critters:
		critter_dict[c.name] = c.linear_velocity
		c.linear_velocity = Vector2(0,0)
	$MobTimer.stop()
		

func unfreeze_critters() -> void:
	var critters = get_tree().get_nodes_in_group("critters")
	for c in critters:
		c.linear_velocity = critter_dict[c.name]
	$MobTimer.start()


func pause() -> void:
	paused = true
	freeze_critters()
	$ScoreTimer.stop()
	update_score()
	Engine.time_scale = 0.0
	$Pause.show()
	
	
func unpause() -> void:
	paused = false
	$Pause.hide()
	unfreeze_critters()
	$ScoreTimer.start()
	update_score()
	Engine.time_scale = 1


func processPause() -> void:
	if(paused):
		unpause()
	else:
		pause()
		
	
func update_score() -> void:
	score = Core.calculate_score()
	$HUD.update_score(score)
	
	
func _on_score_timer_timeout() -> void:
	time += 1
	Core.time_elapsed += 1
	$HUD.update_time(time)
	if(time >= Core.TIME_LIMIT):
		game_over()


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
	critter.queue_free()
	$death_animation.position = critter.position
	$death_animation.play()


func _on_resume_from_pause() -> void:
	processPause()
