extends Node


const TIME_LIMIT = 60
const MAIN_MESSAGE = "Squish the Critters!!!"
const TITLE = "CREEPY CRITTER SQUISHER"

const MOB_SPAWN_RATE = 0.5

# Point Values
const CRITTER_SQUISH_POINTS = 1
const COLLECT_POWER_UP_POINTS = 3

# Tracked Parameters
var critters_squished = 0
var power_ups_collected = 0
var num_swats = 0
var successful_swats = 0
var time_elapsed = 0

# Scaling Parameters
var level = 1
const TIMER_INCREMENT = 0.05

func calculate_score() -> int:
	var score = 0
	score += CRITTER_SQUISH_POINTS * critters_squished
	score += COLLECT_POWER_UP_POINTS * power_ups_collected
	return score

func reset_state() -> void:
	critters_squished = 0
	power_ups_collected = 0
	num_swats = 0
	successful_swats = 0
	time_elapsed = 0
	level = 1
