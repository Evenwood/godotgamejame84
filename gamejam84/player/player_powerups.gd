extends RefCounted
class_name PlayerPowerups

signal powerup_activated(powerup_type: String)
signal powerup_expired(powerup_type: String)

var player: CharacterBody2D
var active_powerups: Dictionary = {}
var original_scale: Vector2
var critter_dict: Dictionary = {}

func setup(player_ref: CharacterBody2D):
	player = player_ref
	original_scale = player.scale

func activate_powerup(powerup_type: String, duration: float, effect_value: float):
	print("Power-up collected: ", powerup_type)
	match powerup_type:
		"size_boost":
			_apply_size_boost(duration, effect_value)
		"freeze":
			_apply_freeze(duration, effect_value)
		"smoke_bomb":
			_apply_smoke_bomb(1, effect_value)
		_:
			print("Unknown power-up type: ", powerup_type)
	powerup_activated.emit(powerup_type)

func _apply_size_boost(duration: float, multiplier: float):
	_remove_existing_powerup("size_boost")
	player.scale = original_scale * multiplier
	player.damage = 2
	_create_powerup_timer("size_boost", duration, _remove_size_boost)

func _remove_size_boost():
	_cleanup_powerup("size_boost")
	player.scale = original_scale
	player.damage = 1
	powerup_expired.emit("size_boost")

func _apply_freeze(duration: float, multiplier: float):
	_remove_existing_powerup("freeze")
	var critters = player.get_tree().get_nodes_in_group("critters")
	for c in critters:
		critter_dict[c.name] = c.velocity
		c.velocity = Vector2(0, 0)
	_create_powerup_timer("freeze", duration, _remove_freeze)

func _remove_freeze():
	_cleanup_powerup("freeze")
	var critters = player.get_tree().get_nodes_in_group("critters")
	for c in critters:
		if c.name in critter_dict:
			c.velocity = critter_dict[c.name]
			critter_dict.erase(c.name)
	powerup_expired.emit("freeze")

#func _apply_smoke_bomb(duration: float, multiplier: float):
#	_remove_existing_powerup("smoke_bomb")
#	var critters = player.get_tree().get_nodes_in_group("critters")
#	for c in critters:
#		player.critter_swatted.emit(c, player.damage)
#	_create_powerup_timer("smoke_bomb", duration, _remove_smoke_bomb)
func _apply_smoke_bomb(duration: float, multiplier: float):
	_remove_existing_powerup("smoke_bomb")
	var critters = player.get_tree().get_nodes_in_group("critters")
	for c in critters:
		player.smoke_bomb_hit.emit(c, player.damage)
	_create_powerup_timer("smoke_bomb", duration, _remove_smoke_bomb)
	
func _remove_smoke_bomb():
	_cleanup_powerup("smoke_bomb")
	powerup_expired.emit("smoke_bomb")

func _remove_existing_powerup(powerup_type: String):
	if powerup_type in active_powerups:
		var old_timer = active_powerups[powerup_type]
		old_timer.queue_free()

func _create_powerup_timer(powerup_type: String, duration: float, callback: Callable):
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	timer.timeout.connect(callback)
	player.add_child(timer)
	timer.start()
	active_powerups[powerup_type] = timer

func _cleanup_powerup(powerup_type: String):
	if powerup_type in active_powerups:
		var timer = active_powerups[powerup_type]
		active_powerups.erase(powerup_type)
		timer.queue_free()

func is_powerup_active(powerup_type: String) -> bool:
	return powerup_type in active_powerups

func get_powerup_time_remaining(powerup_type: String) -> float:
	if powerup_type in active_powerups:
		var timer = active_powerups[powerup_type]
		return timer.time_left
	return 0.0
