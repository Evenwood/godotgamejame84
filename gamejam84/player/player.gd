extends CharacterBody2D

signal hit

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta):
	var mouse_pos = get_global_mouse_position()
	var distance_to_mouse = global_position.distance_to(mouse_pos)

	# Stop moving if very close to mouse
	if distance_to_mouse < 5.0:
		velocity = velocity.lerp(Vector2.ZERO, 10.0 * delta)
	else:
		var direction = (mouse_pos - global_position).normalized()
		var target_velocity = direction * speed
		velocity = velocity.lerp(target_velocity, 3 * delta)

	move_and_slide()


func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
