extends RigidBody2D

signal critter_died

@onready var death_sound = $DeathSound
@onready var collision_shape = $CollisionShape2D
@onready var sprite = $AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play()
	#pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	

func die():
	death_sound.play()
	sprite.play("death")
	collision_shape.set_deferred("disabled", true)
	emit_signal("critter_died")	
