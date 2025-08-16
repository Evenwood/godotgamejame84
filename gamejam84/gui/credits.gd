extends CanvasLayer

@onready var audio_player = $AudioStreamPlayer

var button_click = preload("res://art/button_1.mp3")
var exit_sound = preload("res://art/Exit_button.mp3")

func _on_title_button_pressed() -> void:
	audio_player.stream = button_click
	audio_player.play()
	get_tree().change_scene_to_file("res://gui/title.tscn")


func _on_exit_button_pressed() -> void:
	audio_player.stream = exit_sound
	audio_player.play()
	get_tree().quit()
