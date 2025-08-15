extends RefCounted
class_name PlayerBoundaries

var play_area: Rect2
var boundary_margin: float = 20.0

func setup(player: CharacterBody2D):
	_setup_play_area(player)

func _setup_play_area(player: CharacterBody2D):
	var viewport = player.get_viewport().get_visible_rect()
	play_area = Rect2(
		boundary_margin,
		boundary_margin,
		viewport.size.x - (boundary_margin * 2),
		viewport.size.y - boundary_margin
	)

func enforce_boundaries(player: CharacterBody2D):
	var old_position = player.global_position
	
	# Clamp position
	player.global_position.x = clamp(player.global_position.x, play_area.position.x, play_area.position.x + play_area.size.x)
	player.global_position.y = clamp(player.global_position.y, play_area.position.y, play_area.position.y + play_area.size.y)

	# If position was clamped, also clamp velocity to prevent bouncing
	if player.global_position.x != old_position.x:
		player.velocity.x = 0
		# If moving towards the boundary, stop that component
		if (player.global_position.x <= play_area.position.x and player.velocity.x < 0) or \
		   (player.global_position.x >= play_area.position.x + play_area.size.x and player.velocity.x > 0):
			player.velocity.x = 0
	
	if player.global_position.y != old_position.y:
		player.velocity.y = 0
		# If moving towards the boundary, stop that component
		if (player.global_position.y <= play_area.position.y and player.velocity.y < 0) or \
		   (player.global_position.y >= play_area.position.y + play_area.size.y and player.velocity.y > 0):
			player.velocity.y = 0
	
	# Additional safety: if velocity is pointing out of bounds, clamp it
	var future_pos = player.global_position + player.velocity * 0.016  # Check 1 frame ahead
	if not play_area.has_point(future_pos):
		# Reduce velocity magnitude if it would take us out of bounds
		var safe_velocity = _calculate_safe_velocity(player.global_position, player.velocity)
		if safe_velocity != player.velocity:
			player.velocity = safe_velocity

func _calculate_safe_velocity(current_pos: Vector2, current_velocity: Vector2) -> Vector2:
	#-- Calculate a safe velocity that won't take the player out of bounds
	var safe_velocity = current_velocity
	
	# Check X bounds
	if current_velocity.x > 0 and current_pos.x + current_velocity.x * 0.016 > play_area.position.x + play_area.size.x:
		safe_velocity.x = max(0, (play_area.position.x + play_area.size.x - current_pos.x) / 0.016)
	elif current_velocity.x < 0 and current_pos.x + current_velocity.x * 0.016 < play_area.position.x:
		safe_velocity.x = min(0, (play_area.position.x - current_pos.x) / 0.016)
	
	# Check Y bounds  
	if current_velocity.y > 0 and current_pos.y + current_velocity.y * 0.016 > play_area.position.y + play_area.size.y:
		safe_velocity.y = max(0, (play_area.position.y + play_area.size.y - current_pos.y) / 0.016)
	elif current_velocity.y < 0 and current_pos.y + current_velocity.y * 0.016 < play_area.position.y:
		safe_velocity.y = min(0, (play_area.position.y - current_pos.y) / 0.016)
	
	return safe_velocity
	
#func enforce_boundaries(player: CharacterBody2D):
#	player.global_position.x = clamp(player.global_position.x, play_area.position.x, play_area.position.x + play_area.size.x)
#	player.global_position.y = clamp(player.global_position.y, play_area.position.y, play_area.position.y + play_area.size.y)

#	if player.global_position.x <= play_area.position.x or player.global_position.x >= play_area.position.x + play_area.size.x:
#		player.velocity.x = 0
#	if player.global_position.y <= play_area.position.y or player.global_position.y >= play_area.position.y + play_area.size.y:
#		player.velocity.y = 0
