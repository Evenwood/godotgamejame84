extends Node2D

@onready var tween: = get_tree().create_tween()
@onready var title: = $CanvasLayer/TitleLabel

func _ready() -> void:
	title.text = Core.TITLE
	var length = Core.TITLE.length()
	tween.tween_property(title, "visible_characters", length, 2)

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
