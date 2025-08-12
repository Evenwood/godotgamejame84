extends Area2D

signal powerup_collected(powerup_type: String, duration: float, effect_value: float)

@export var powerup_type: String = "size_boost"
@export var effect_duration: float = 5.0
@export var size_multiplier: float = 2.0
@export var bob_speed: float = 5.0
@export var bob_height: float = 10.0

var start_position: Vector2
var time_elapsed: float = 0.0

func _ready() -> void:
	# Initial position for bobbing
	start_position = global_position
	# Add the specific powerup type group
	add_to_group("powerups")
	add_to_group("powerup_" + powerup_type)
	# Connect area detection
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	time_elapsed += delta
	var bob_offset = sin(time_elapsed * bob_speed) * bob_height
	global_position.y = start_position.y + bob_offset
	
func _on_area_entered(area):
	if area.get_parent().is_in_group("player"):
		_collect_powerup(area.get_parent())

func _on_body_entered(body):
	if body.is_in_group("player"):
		_collect_powerup(body.get_parent())
		
func _collect_powerup(player):
	Core.power_ups_collected += 1  # Used for score tracking and calculation
	
	print("Size power-up collected!")
	
	powerup_collected.emit(powerup_type, effect_duration, size_multiplier)
	
	_play_collection_effect()
	
	queue_free()
	
func _play_collection_effect():
	var tween = create_tween()
	# Simple scale up effect
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_callback(func(): modulate = Color(1, 1, 1, 0.5))
	# Play sound here: AudioManager.play_sound("powerup_collect")
	
