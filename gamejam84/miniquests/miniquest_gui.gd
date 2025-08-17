extends CanvasLayer

signal quest_accepted()

@onready var quest_text = $PanelContainer/MarginContainer/HBoxContainer/QuestText
@onready var critter_icon = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/CritterIcon
@onready var quest_button = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/OkButton
@onready var audio_player = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/AudioStreamPlayer


func display_quest(critter_count:int, critter_type:String) -> void:
	quest_button.hide()
	quest_text.text = "Quest: Squish " + str(critter_count) + " " + critter_type + "s"
	match(critter_type):
		"forwarder":
			critter_icon.texture = Core.forwarder_icon
		"zigzagger":
			critter_icon.texture = Core.zigzagger_icon
		"spiraler":
			critter_icon.texture = Core.spiraler_icon
		"faker":
			critter_icon.texture = Core.faker_icon
		"chaser":
			critter_icon.texture = Core.chaser_icon
		_:
			critter_icon.texture = Core.forwarder_icon
	show()
	await get_tree().create_timer(1.0, false, false, true).timeout
	quest_button.show()


func _on_ok_button_pressed() -> void:
	hide()
	audio_player.stream = preload("res://art/mini_quest_button.mp3")
	audio_player.play()
	quest_accepted.emit()
