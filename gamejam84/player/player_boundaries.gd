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
	player.global_position.x = clamp(player.global_position.x, play_area.position.x, play_area.position.x + play_area.size.x)
	player.global_position.y = clamp(player.global_position.y, play_area.position.y, play_area.position.y + play_area.size.y)

	if player.global_position.x <= play_area.position.x or player.global_position.x >= play_area.position.x + play_area.size.x:
		player.velocity.x = 0
	if player.global_position.y <= play_area.position.y or player.global_position.y >= play_area.position.y + play_area.size.y:
		player.velocity.y = 0
