extends Area2D
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
	global_position = get_global_mouse_position()
	position.clamp(Vector2.ZERO, screen_size)


func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
