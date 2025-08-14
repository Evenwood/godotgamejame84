extends Control
class_name HealthBar

# Settings
@export var segment_width: float = 15.0
@export var segment_height: float = 5.0
@export var segment_spacing: float = 1.0
@export var full_color: Color = Color.GREEN
@export var damaged_color: Color = Color.RED
@export var empty_color: Color = Color.DARK_GRAY

var max_hp: int = 1
var current_hp: int = 1
var segments: Array[ColorRect] = []

func _ready():
	# This will be called when the health bar is first created
	pass

func setup(maximum_health: int):
	max_hp = maximum_health
	current_hp = maximum_health
	_create_segments()

func _create_segments():
	# Clear existing segments
	for segment in segments:
		segment.queue_free()
	segments.clear()
	
	# Calculate total width needed
	var total_width = (segment_width * max_hp) + (segment_spacing * (max_hp - 1))
	
	# Create container
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", segment_spacing)
	add_child(hbox)
	
	# Create individual segments
	for i in range(max_hp):
		var segment = ColorRect.new()
		segment.size = Vector2(segment_width, segment_height)
		segment.custom_minimum_size = Vector2(segment_width, segment_height)
		segment.color = full_color
		
		hbox.add_child(segment)
		segments.append(segment)
	
	# Center the health bar
	size = Vector2(total_width, segment_height)
	pivot_offset = size / 2

func update_health(new_hp: int):
	current_hp = clamp(new_hp, 0, max_hp)
	_update_segment_colors()

func _update_segment_colors():
	var half_health = max_hp / 2.0
	
	for i in range(segments.size()):
		if i < current_hp:
			# Segment is still active
			if current_hp > half_health:
				# Above half health - use full color
				segments[i].color = full_color
			else:
				# At or below half health - use damaged color
				segments[i].color = damaged_color
		else:
			# Segment is empty
			segments[i].color = empty_color

func take_damage(damage: int):
	update_health(current_hp - damage)

func heal(amount: int):
	update_health(current_hp + amount)

func get_current_hp() -> int:
	return current_hp

func is_dead() -> bool:
	return current_hp <= 0
