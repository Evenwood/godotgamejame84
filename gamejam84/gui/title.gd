extends CanvasLayer

@onready var tween: = get_tree().create_tween()
@onready var title: = $TitleLabel
@onready var audio_player = $AudioStreamPlayer

var button_click = preload("res://art/button_1.mp3")
var exit_sound = preload("res://art/Exit_button.mp3")


func _ready() -> void:
	title.text = Core.TITLE
	var length = Core.TITLE.length()
	tween.tween_property(title, "visible_characters", length, 2)

func _on_start_button_pressed() -> void:
	audio_player.stream = button_click
	audio_player.play()
	get_tree().change_scene_to_file("res://gui/intro.tscn")
	

func _on_exit_button_pressed() -> void:
	audio_player.stream = exit_sound
	audio_player.play()
	get_tree().quit()


func _on_credit_button_pressed() -> void:
	audio_player.stream = button_click
	audio_player.play()
	get_tree().change_scene_to_file("res://gui/credits.tscn")
