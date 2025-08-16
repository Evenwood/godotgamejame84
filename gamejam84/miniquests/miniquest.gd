class_name Miniquest
extends RefCounted

var title: String
var is_completed: bool = false
var reward_points: int = 0
var critters_to_squish: int = 0 
var critters_squished: int = 0 
var critter_type_to_squish: String

func _init(quest_title: String = "", reward:int = 10):
	title = quest_title
	reward_points = reward

func set_critters_to_squish(critter_count:int, critter_type:String):
	critters_to_squish = critter_count
	critters_squished = 0
	critter_type_to_squish = critter_type
	
func get_objective() -> String:
	return "Squish %d %ss" % [critters_to_squish, critter_type_to_squish]
		
func get_progress() -> String:
	return "%d of %d %s squished" % \
		[critters_squished, critters_to_squish, critter_type_to_squish]

func squish_critter(critter_type: String) -> bool:
	if critter_type == critter_type_to_squish and critters_squished < critters_to_squish:
		critters_squished += 1
		if is_objective_met():
			is_completed = true
		return true  # Return whether this squish counted
	return false

func is_objective_met() -> bool:
	return critters_squished >= critters_to_squish

func get_reward_points() -> int:
	return reward_points
	
