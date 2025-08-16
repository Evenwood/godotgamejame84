extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game

@onready var quest_objective_label = $QuestObjective
@onready var quest_progress_label = $QuestProgress

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_game_over():
	show_message("Time's Up!")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = Core.MAIN_MESSAGE
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	
func update_score(score):
	$ScoreLabel.text = str(score)
	
func update_time(time):
	$TimerLabel.text = str(Core.TIME_LIMIT - time)


func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()

func _on_message_timer_timeout() -> void:
	$Message.hide()
	
func update_quest_display(objective: String, progress: String):
	quest_objective_label.text = "Quest: " + objective
	quest_progress_label.text = progress

func show_quest_completed(bonus_points: int):
	# Show a temporary completion message
	var completion_text = "Quest Complete! +" + str(bonus_points) + " points"
	# You could create a temporary label or use your existing message system
	show_message(completion_text)
