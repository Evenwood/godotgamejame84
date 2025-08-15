extends Label

var float_speed = 50.0
var fade_time = 1.5
var lifetime = 0.0

func _ready():
	# Set initial properties
	modulate = Color.WHITE
	z_index = 100  # Ensure it appears above other elements

func show_points(points: int, start_position: Vector2, color = Color.WHITE):
	text = str(points)
	global_position = start_position
	modulate = color
	
	# Create tweens for movement and fading
	var move_tween = create_tween()
	var fade_tween = create_tween()
	
	# Move upward
	move_tween.tween_property(self, "global_position:y", 
		global_position.y - float_speed, fade_time)
	
	# Fade out
	fade_tween.tween_property(self, "modulate:a", 0.0, fade_time)
	fade_tween.tween_callback(queue_free)
