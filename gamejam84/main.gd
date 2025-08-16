extends Node

@export var critter_scene: PackedScene
@onready var audio_player = $AudioStreamPlayer
@onready var audio_player_2 = $AudioStreamPlayer


var score
var time
var game_active = false
var critter_dict = {}
var paused = false
var min_quest_value = 5
var max_quest_value = 10

@onready var player = $Player
@onready var stats = $Stats

var squish_sound
var pop_sound
var pause_sound = preload("res://art/Pause_button.mp3")
var restart_sound = preload("res://art/Restart_button.mp3")
var start_sound = preload("res://art/Start_button.mp3")
var smoke_sound = preload("res://art/Slime_power_up.mp3")
var xl_sound = preload("res://art/Swatter_power_up.mp3")
var freeze_sound = preload("res://art/Freeze_power_up.mp3")
var times_up_sound = preload("res://art/Times_up.mp3")
var swat_sound = preload("res://art/Flyswatter.mp3")
var has_played = false

var current_quest: Miniquest
var quest_bonus_points: int = 50  # Bonus for completing quest

var critter_types = [\
	"forwarder", "zigzagger", "spiraler", "faker", "chaser",\
	"forwarder", "zigzagger", "spiraler", "faker", "chaser"\
	]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Find the player and connect to its signal
	#var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("critter_swatted"):
		player.critter_swatted.connect(_on_critter_swatted)
		print("Critter connected to player's swat signal")
	#player.swat_started.connect(_on_swat_started)
	player.smoke_bomb_hit.connect(_on_smoke_bomb_hit)
	player.powerup_activated.connect(_on_powerup_activated)	
	$MobTimer.wait_time = Core.MOB_SPAWN_RATE	
	
	squish_sound = preload("res://art/squishwet.mp3")
	pop_sound = preload("res://art/squish-pop-256410.mp3")
	audio_player.stream = squish_sound
	#create_new_quest()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(game_active):
		update_score()
		stats.update_stats()
	if(game_active && Input.is_action_just_pressed("escape")):
		process_pause()
	if(game_active && paused != true && Input.is_action_just_pressed("swat")):
		Core.num_swats += 1
	if(game_active && paused != true && Input.is_action_just_pressed("return")):
		$Player.start($StartPosition.position)
	
func new_game():
	audio_player.stream = restart_sound
	audio_player.play()
	
	score = 0
	time = 0
	player.reset_player()
	$PowerUpSpawner.reset_spawner()
	$MobTimer.wait_time = Core.MOB_SPAWN_RATE
	reset_game_state()
	
func round_start():
	$HUD.update_score(score)
	$HUD.update_time(time)
	create_new_quest()
	await get_tree().create_timer(1.0).timeout
	$HUD.show_message("Get Ready")
	$Player.start($StartPosition.position)
	$StartTimer.start()
	
func reset_game_state() -> void:
	round_start()
	game_active = true
	
#func _on_swat_started(start_position: Vector2):
#	current_swat_has_hit = false
	
func _on_mob_timer_timeout() -> void:
	
	if player.is_powerup_active("freeze"):
		#audio_player.stream = freeze_sound
		#audio_player.play()		
		return
	if player.is_powerup_active("smoke_bomb"):
		#audio_player.stream = smoke_sound
		#audio_player.play()
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
	# Get a random critter type
	var critter_type = critter_types[randi() % critter_types.size()]
	# Set the mob's direction perpendicular to the path direction.
	var directionRadians = mob_spawn_location.rotation + PI / 2
	# Add some randomness to the direction.
	directionRadians += randf_range(-PI / 4, PI / 4)
	# Add the critter to the scene before setting it up.
	add_child(critter)
	critter.setup(critter_type, mob_spawn_location.position, directionRadians)
	# Add quest marker if it's the quest target
	if current_quest and not current_quest.is_completed:
		if critter_type == current_quest.critter_type_to_squish:
			critter.set_quest_marker(true, "★", Color.GOLD)

			
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


func increase_level() -> void:
	Core.level += 1
	min_quest_value += 1
	max_quest_value += 2
	if($MobTimer.wait_time > 0.1):
		$MobTimer.wait_time -= Core.TIMER_INCREMENT
		print("Mob Timer Wait Time Now: " + str($MobTimer.wait_time))
	$Level.show()


func apply_level() -> void:
	player.update_player_stats()
	print("Damage now: " + str(player.damage))
	$PowerUpSpawner.update_spawner()


func pause() -> void:
	audio_player.stream = pause_sound
	audio_player.play()
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
	player.remove_power_ups()
	var critters = get_tree().get_nodes_in_group("critters")
	for c in critters:
		c.queue_free()
	$HUD.show_message("Time's Up!")
	audio_player.stop()
	audio_player.stream = times_up_sound
	audio_player.play()
	await get_tree().create_timer(2.0).timeout
	Engine.time_scale = 0
	update_score()
	display_stat_screen()


func display_stat_screen() -> void:
	stats.update_stats()
	stats.clear_view()
	stats.show()
	stats.create_view()


func process_continue() -> void:
	audio_player.stream = restart_sound
	audio_player.play()
	Engine.time_scale = 1
	time = 0
	$HUD.show_message("Level Up!")
	await get_tree().create_timer(2.0).timeout
	Engine.time_scale = 0
	increase_level()

func process_restart() -> void:
	audio_player.stream = restart_sound
	audio_player.play()
	Core.reset_state()
	Engine.time_scale = 1
	new_game()
	
	
func update_score() -> void:
	score = Core.calculate_score()
	$HUD.update_score(score)


func calc_crit() -> bool:
	var crit_chance = randi_range(0, 100)
	if(crit_chance <= Core.luck_increase):
		print("CRITICAL HIT!!!")
		return true
	else:
		return false
	
func _on_score_timer_timeout() -> void:
	time += 1
	Core.time_elapsed += 1
	$HUD.update_time(time)
	if(time >= Core.TIME_LIMIT):
		process_end_game()

func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
		
func _on_critter_swatted(critter, damage):
	audio_player.stream = swat_sound
	audio_player.play()
	_do_swat(critter, damage)
	
func _on_smoke_bomb_hit(critter, damage):
	_do_swat(critter, damage)
	audio_player.stream = smoke_sound
	audio_player.play()
		
func _do_swat(critter, damage):
	
	# Validate critter is still alive before processing
	if not is_instance_valid(critter) or critter.HP <= 0:
		return

	var is_critical_hit = calc_crit()
	
	if is_critical_hit:
		damage *= (2 + (Core.luck_increase) / 3)

	var damage_dealt = critter.get_swatted(damage)
	
	if damage_dealt > 0 && is_critical_hit:
		_show_floating_value(damage, critter.global_position, Color.YELLOW)
	elif damage_dealt > 0:
		_show_floating_value(damage, critter.global_position, Color.RED)

	if critter.HP <= 0:
		calc_critter_points(critter)
		critter.queue_free()
		audio_player.stream = squish_sound
		audio_player.play()
	else:
		audio_player.stream = pop_sound
		audio_player.play()
	
	print("SWATTED: ", critter.name);
	print("Points: " + str(Core.calculate_score()))
	print("Num Swats: " + str(Core.num_swats))
	print("Successful Swats: " + str(Core.successful_swats))
	print("Critters Swatted: " + str(Core.critters_squished))
	print("Power Ups Collected: " + str(Core.power_ups_collected))

func _show_floating_value(value, start_position, color):
	var floating_points = preload("res://floatingpoints/floating_points.tscn").instantiate()
	get_tree().current_scene.add_child(floating_points)
	floating_points.show_points(value, start_position, color)
	
func calc_critter_points(critter) -> void:
	Core.critters_squished += 1
	critter.register_squished_critter()
	Core.critter_bonus_points += critter.point_mod
	
	_update_quest_progress(critter)
	
func _update_quest_progress(critter):
	if current_quest and not current_quest.is_completed:
		if current_quest.squish_critter(critter.critter_type):
			# Update quest display
			$HUD.update_quest_display(\
				current_quest.get_objective(), current_quest.get_progress())
			
			# Check if quest is completed
			if current_quest.is_objective_met():
				Core.quests_completed += 1
				time -= 5 # add 5 seconds to time
				quest_stat_increase()
				await get_tree().create_timer(1.0).timeout
				create_new_quest()
				await get_tree().create_timer(1.0).timeout
				print("Quest Completed! Bonus: +", current_quest.get_reward_points(), " points")
				update_score()
				


func quest_stat_increase() -> void:
	var stat_up = randi_range(0, 2)
	match(stat_up):
		0:
			Core.damage_increase += 1
			$HUD.show_quest_completed("Damage")
			print("Damage Increased")
		1:
			Core.size_increase += 1
			$HUD.show_quest_completed("Size")
			print("Size Increased")
		2:
			Core.luck_increase += 1
			$HUD.show_quest_completed("Luck")
			print("Luck Increased")
	apply_level()

func _on_resume_from_pause() -> void:
	audio_player.stream = restart_sound
	audio_player.play()
	process_pause()

func _on_stats_continue_game() -> void:
	audio_player.stream = restart_sound
	audio_player.play()
	process_continue()

func _on_stats_restart_game() -> void:
	audio_player.stream = restart_sound
	audio_player.play()
	process_restart()


func _on_level_selection_made() -> void:
	apply_level()
	Engine.time_scale = 1
	reset_game_state()
	
func _on_powerup_activated(powerup_type):
	if powerup_type == "size_boost":
		audio_player.stream = xl_sound
		audio_player.play()
		return
	if powerup_type == "freeze":
		audio_player_2.stream = freeze_sound
		audio_player_2.play()
		return	
	print(powerup_type, " ACTIVATED!")

func create_new_quest():
	current_quest = Miniquest.new("Mini Challenge", Core.QUEST_POINTS)  # 25 bonus points
	
	# Random critter count (5-10) and type
	var critter_count = randi_range(min_quest_value, max_quest_value)
	var critter_type = critter_types[randi() % critter_types.size()]
	
	current_quest.set_critters_to_squish(critter_count, critter_type)
	Engine.time_scale = 0
	$Miniquest.display_quest(critter_count, critter_type)
	await $Miniquest.quest_accepted
	Engine.time_scale = 1
	
	# Update HUD to show quest
	$HUD.update_quest_display(\
		current_quest.get_objective(), current_quest.get_progress())
		
	_update_critter_markers()
	print("New Quest: ", current_quest.get_objective())
	
func _update_critter_markers():
	var critters = get_tree().get_nodes_in_group("critters")
	for critter in critters:
		if current_quest and not current_quest.is_completed:
			if critter.critter_type == current_quest.critter_type_to_squish:
				critter.set_quest_marker(true, "★", Color.GOLD)
			else:
				critter.set_quest_marker(false)
