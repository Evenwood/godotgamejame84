extends RefCounted
#class_name PlayerCollision

signal player_collided(collision_object, collision_point: Vector2)
signal swat_something(swat_object, swat_point: Vector2)
signal critter_swatted(critter)
signal swat_interrupted(collision_point: Vector2) 

var player: CharacterBody2D

func _init(player_ref: CharacterBody2D, movement_ref: PlayerMovement):
	player = player_ref

func check_collisions():
	if player.get_slide_collision_count() > 0:
		for i in player.get_slide_collision_count():
			var collision = player.get_slide_collision(i)
			var swat_object = collision.get_collider()
			var swat_point = collision.get_position()
			
			swat_something.emit(swat_object, swat_point)
			player_collided.emit(swat_object, swat_point)
			
			if swat_object.is_in_group("critters"):
				print("Hit a critter")
				critter_swatted.emit(swat_object)
				
			# Handle swat interruption
			swat_interrupted.emit(swat_point)
