extends CanvasLayer

signal continue_game()
signal restart_game()

@onready var critters = $StatPanel/MarginContainer/LabelContainer/CritterLabel
@onready var powers = $StatPanel/MarginContainer/LabelContainer/PowerUpLabel
@onready var swats = $StatPanel/MarginContainer/LabelContainer/SwatLabel
@onready var succ_swats = $StatPanel/MarginContainer/LabelContainer/SuccSwatLabel
@onready var accuracy = $StatPanel/MarginContainer/LabelContainer/AccuracyLabel
@onready var time = $StatPanel/MarginContainer/LabelContainer/TimeLabel
@onready var level = $StatPanel/MarginContainer/LabelContainer/LevelLabel

@onready var forwarder = $CritterPanel/MarginContainer/LabelContainer/ForwarderLabel
@onready var zigzagger = $CritterPanel/MarginContainer/LabelContainer/ZigzaggerLabel
@onready var spiraler = $CritterPanel/MarginContainer/LabelContainer/SpiralerLabel
@onready var faker = $CritterPanel/MarginContainer/LabelContainer/FakerLabel
@onready var chaser = $CritterPanel/MarginContainer/LabelContainer/ChaserLabel

func _ready() -> void:
	forwarder.tooltip_text = "Worth " + str(Core.FORWARDER_SQUISH_POINTS)
	zigzagger.tooltip_text = "Worth " + str(Core.ZIGZAGGER_SQUISH_POINTS)
	spiraler.tooltip_text = "Worth " + str(Core.SPIRALER_SQUISH_POINTS)
	faker.tooltip_text = "Worth " + str(Core.FAKER_SQUISH_POINTS)
	chaser.tooltip_text = "Worth " + str(Core.CHASER_SQUISH_POINTS)

func update_stats() -> void:
	critters.text = "Critters Squished: " + str(Core.critters_squished)
	powers.text = "Power Ups Collected: " + str(Core.power_ups_collected)
	swats.text = "Number of Swats: " + str(Core.num_swats)
	succ_swats.text = "Successful Swats: " + str(Core.successful_swats)
	accuracy.text = "Accuracy: " + calc_accuracy()
	time.text = "Time Elapsed: " + str(Core.time_elapsed) + " seconds"
	level.text = "Current Level: " + str(Core.level + 1)
	
	forwarder.text = "Forwarders: " + str(Core.forwarders)
	zigzagger.text = "Zigzaggers: " + str(Core.zigzaggers)
	spiraler.text = "Spiralers: " + str(Core.spiralers)
	faker.text = "Fakers: " + str(Core.fakers)
	chaser.text = "Chasers: " + str(Core.chasers)
	
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


func _on_continue_button_pressed() -> void:
	hide()
	continue_game.emit()
	


func _on_restart_button_pressed() -> void:
	hide()
	restart_game.emit()
	


func _on_exit_button_pressed() -> void:
	get_tree().quit()
