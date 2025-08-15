extends CanvasLayer

signal selection_made()

func _on_damage_select_pressed() -> void:
	Core.damage_increase += 1
	hide()
	selection_made.emit()


func _on_size_select_pressed() -> void:
	Core.size_increase += 1
	hide()
	selection_made.emit()


func _on_luck_select_pressed() -> void:
	Core.luck_increase += 1
	hide()
	selection_made.emit()
