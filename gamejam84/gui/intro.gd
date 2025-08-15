extends CanvasLayer

@onready var one = $IntroTextOne
@onready var two = $IntroTextTwo

@onready var diag = $DialogueTimer
@onready var next = $NextPageTimer

var tween: Tween

var length = 0

func _ready() -> void:
	one.visible_characters = 0
	two.visible_characters = 0
	one.text = Core.INTRO_DIALOGUE_ONE
	two.text = Core.INTRO_DIALOGUE_TWO
	run_intro()

func run_intro() -> void:
	var tween_length = 0
	for n in 9:
		match n:
			0:
				one.text = Core.INTRO_DIALOGUE_ONE
				two.text = Core.INTRO_DIALOGUE_TWO
			1:
				one.text = Core.INTRO_DIALOGUE_THREE
				two.text = Core.INTRO_DIALOGUE_FOUR
			2:
				one.text = Core.INTRO_DIALOGUE_FIVE
				two.text = Core.INTRO_DIALOGUE_SIX
			3:
				one.text = Core.INTRO_DIALOGUE_SEVEN
				two.text = Core.INTRO_DIALOGUE_EIGHT
			4:
				one.text = Core.INTRO_DIALOGUE_NINE
				two.text = Core.INTRO_DIALOGUE_TEN
			5:
				one.text = Core.INTRO_DIALOGUE_ELEVEN
				two.text = Core.INTRO_DIALOGUE_TWELVE
			6:
				one.text = Core.INTRO_DIALOGUE_THIRTEEN
				two.text = Core.INTRO_DIALOGUE_FOURTEEN
			7:
				one.text = Core.INTRO_DIALOGUE_FIFTEEN
				two.text = Core.INTRO_DIALOGUE_SIXTEEN
			8:
				one.text = Core.INTRO_DIALOGUE_SEVENTEEN
				two.text = Core.INTRO_DIALOGUE_EIGHTEEN
			_:
				one.text = Core.INTRO_DIALOGUE_ONE
				two.text = Core.INTRO_DIALOGUE_TWO
		length = one.text.length()
		if(length < 25):
			tween_length = 2
		else:
			tween_length = 4
		tween = get_tree().create_tween()
		tween.tween_property(one, "visible_characters", length, tween_length)
		await tween.finished
		length = two.text.length()
		if(length < 25):
			tween_length = 2
		else:
			tween_length = 4
		diag.start()
		await diag.timeout
		diag.stop()
		tween = get_tree().create_tween()
		tween.tween_property(two, "visible_characters", length, tween_length)
		await tween.finished
		next.start()
		await next.timeout
		next.stop()
		one.visible_characters = 0
		two.visible_characters = 0
	$SkipButton.hide()
	$StartButton.show()


func start_game() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")


func _on_skip_button_pressed() -> void:
	start_game()


func _on_start_button_pressed() -> void:
	start_game()
