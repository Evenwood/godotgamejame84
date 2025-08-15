extends RefCounted
class_name PlayerCollision

signal critter_swatted(critter)
signal swat_interrupted(collision_point: Vector2) 

var player: CharacterBody2D
var swat_detector: Area2D
var movement_handler: PlayerMovement
var swat_active: bool = false
var hit_critters: Array[CharacterBody2D] = []  # Track hits during this swat

func _init(player_ref: CharacterBody2D, movement_ref: PlayerMovement):
	player = player_ref
	movement_handler = movement_ref
	_get_existing_swat_detector()
	_connect_signals()

func _get_existing_swat_detector():
	# Get the existing Area2D from the player scene
	swat_detector = player.get_node("SwatDetector")  # Adjust path as needed
	
	if not swat_detector:
		print("SwatDetector Area2D not found as child of Player!")
		return
	
	# Set up collision layers/masks if not set in editor
	#if swat_detector.collision_layer == 1:  # Default value, probably not set
	#	swat_detector.collision_layer = 0  # Don't collide with anything
	#	swat_detector.collision_mask = 1   
	
	# Get the collision shape and initially disable it
	var swat_collision = swat_detector.get_node("CollisionShape2D")
	if swat_collision:
		swat_collision.disabled = true
	else:
		print("SwatDetector is missing CollisionShape2D child!")
	
func _connect_signals():
	if not swat_detector:
		return
		
	# Connect movement signals
	movement_handler.swat_started.connect(_on_swat_started)
	movement_handler.swat_completed.connect(_on_swat_completed)
	
	# Connect Area2D signals
	swat_detector.body_entered.connect(_on_critter_entered_swat_area)

func _on_swat_started(start_position: Vector2):
	if not swat_detector:
		return
	print("Swat detection activated")	
	swat_active = true
	hit_critters.clear()  # Reset hit tracking
	
	# Enable swat detection
	var swat_collision = swat_detector.get_node("CollisionShape2D")
	if swat_collision:
		swat_collision.disabled = false
	# Check for critters already in the swat area
	_check_existing_bodies_in_area()

func _check_existing_bodies_in_area():
	print("Checking bodies in area")
	# Get all bodies currently overlapping with the swat detector
	var overlapping_bodies = swat_detector.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		# Process each overlapping body as if it just entered
		_on_critter_entered_swat_area(body)
		
func _on_swat_completed(final_position: Vector2):
	if not swat_detector:
		return
	print("Swat detection deactivated")
		
	swat_active = false
	hit_critters.clear()  # Clear hit tracking
	
	# Disable swat detection
	var swat_collision = swat_detector.get_node("CollisionShape2D")
	if swat_collision:
		swat_collision.disabled = true

func _on_critter_entered_swat_area(body):
	# Only process if swat is active and this critter hasn't been hit yet
	if not swat_active:
		return
		
	if not body.is_in_group("critters"):
		return
		
	if body in hit_critters:
		return  # Already hit this critter during this swat
		
	# Check if critter is still alive (in case of timing issues)
	if body.HP <= 0:
		return
		
	print("Swat hit detected on: ", body.name)
	hit_critters.append(body)  # Mark as hit
	critter_swatted.emit(body)

func interrupt_swat():
	# Clean interruption
	if swat_active:
		_on_swat_completed(player.global_position)
