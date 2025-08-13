extends CanvasLayer

@onready var critters = $StatPanel/MarginContainer/LabelContainer/CritterLabel
@onready var powers = $StatPanel/MarginContainer/LabelContainer/PowerUpLabel
@onready var swats = $StatPanel/MarginContainer/LabelContainer/SwatLabel
@onready var succ_swats = $StatPanel/MarginContainer/LabelContainer/SuccSwatLabel
@onready var accuracy = $StatPanel/MarginContainer/LabelContainer/AccuracyLabel
@onready var time = $StatPanel/MarginContainer/LabelContainer/TimeLabel

func update_stats() -> void:
	critters.text = "Critters Squished: " + str(Core.critters_squished)
	powers.text = "Power Ups Collected: " + str(Core.power_ups_collected)
	swats.text = "Number of Swats: " + str(Core.num_swats)
	succ_swats.text = "Successful Swats: " + str(Core.successful_swats)
	accuracy.text = "Accuracy: " + calc_accuracy()
	time.text = "Time Elapsed: " + str(Core.time_elapsed) + " seconds"
	
func calc_accuracy() -> String:
	var acc: float = 0.0
	if(Core.num_swats == 0):
		return "100%"
	else:
		acc = float(Core.successful_swats) / float(Core.num_swats)
		acc *= 100
		var percentage = snapped(acc, 0.1)
		var percentString: String = str(percentage) + "%"
		return percentString
