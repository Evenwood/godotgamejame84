extends CanvasLayer

signal resume_from_pause()

func _on_resume_button_pressed() -> void:
	resume_from_pause.emit()
	hide()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
