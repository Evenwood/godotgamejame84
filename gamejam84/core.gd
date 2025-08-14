extends Node


const TIME_LIMIT = 60
const MAIN_MESSAGE = "Squish the Critters!!!"
const TITLE = "CREEPY CRITTER SQUISHER"

const MOB_SPAWN_RATE = 0.5

# Point Values
const FORWARDER_SQUISH_POINTS = 1
const ZIGZAGGER_SQUISH_POINTS = 2
const SPIRALER_SQUISH_POINTS = 2
const FAKER_SQUISH_POINTS = 2
const CHASER_SQUISH_POINTS = 3
const COLLECT_POWER_UP_POINTS = 3

# Stat Values
const REG_CRITTER_HP = 1
const TOUGH_CRITTER_HP = 2
const PLAYER_BASE_DAMAGE = 1
var damage_increase = 0

# Tracked Parameters
var critters_squished = 0
var critter_bonus_points = 0
var forwarders = 0
var zigzaggers = 0
var spiralers = 0
var fakers = 0
var chasers = 0
var power_ups_collected = 0
var num_swats = 0
var successful_swats = 0
var time_elapsed = 0

# Scaling Parameters
var level = 0
const TIMER_INCREMENT = 0.05
const VELOCITY_INCREMENT = 20.0

func calculate_score() -> int:
	var score = 0
	score += FORWARDER_SQUISH_POINTS * forwarders
	score += ZIGZAGGER_SQUISH_POINTS * zigzaggers
	score += SPIRALER_SQUISH_POINTS * spiralers
	score += FAKER_SQUISH_POINTS * fakers
	score += CHASER_SQUISH_POINTS * chasers
	score += critter_bonus_points
	score += COLLECT_POWER_UP_POINTS * power_ups_collected
	return score

func reset_state() -> void:
	critters_squished = 0
	forwarders = 0
	zigzaggers = 0
	spiralers = 0
	fakers = 0
	chasers = 0
	critter_bonus_points = 0
	power_ups_collected = 0
	num_swats = 0
	successful_swats = 0
	time_elapsed = 0
	level = 0
	damage_increase = 0
