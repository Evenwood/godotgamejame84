extends BaseBehavior
class_name ChaserBehavior

var player: CharacterBody2D
var last_player_position: Vector2
var arrival_threshold: float = 30.0  # How close to consider "arrived"
var is_at_player: bool = false
var player_found: bool = false

func _init():
	pass

func _setup_behavior(start_position: Vector2, start_radians: float):

	if player:
		last_player_position = player.global_position
	else:
		# Fallback if no player found - move forward like a forwarder
		critter.velocity = Vector2(1.0, 0.0).rotated(start_radians) * critter.speed

func process_behavior(delta: float):
	# Find player on first run when we're definitely in the scene tree
	if not player_found:
		if critter.get_tree():
			player = critter.get_tree().get_first_node_in_group("player")
			if player:
				last_player_position = player.global_position
				player_found = true
				print("Chaser found player!")
			else:
				print("No player found in scene")
				return
		else:
			print("Critter not in scene tree yet")
			return
			
	if not player:
		return
		
	var current_player_position = player.global_position
	
	# Check if player has moved significantly
	if current_player_position.distance_to(last_player_position) > arrival_threshold:
		is_at_player = false
		last_player_position = current_player_position
	
	# If we're not at the player's location, chase them
	if not is_at_player:
		var distance_to_player = critter.global_position.distance_to(current_player_position)
		
		# Check if we've arrived at the player
		if distance_to_player <= arrival_threshold:
			is_at_player = true
			critter.velocity = Vector2.ZERO  # Stop moving
		else:
			# Chase the player
			var direction_to_player = (current_player_position - critter.global_position).normalized()
			critter.velocity = direction_to_player * critter.speed
	else:
		# We're at the player - stay still
		critter.velocity = Vector2.ZERO
