extends Node


const TIME_LIMIT = 60
const MAIN_MESSAGE = "Squish the Critters!!!"
const TITLE = "CREEPY CRITTER SQUISHER"

const MOB_SPAWN_RATE = 0.5
const POWER_UP_SPAWN_RATE = 10.0
const MAX_POWER_UPS = 3
const STAT_SCREEN_TIME_INTERVAL = 1.0

# Intro Dialogue
const INTRO_DIALOGUE_ONE = "I know, I know, you’re looking at your phone and sayin"
const INTRO_DIALOGUE_TWO = "Really? That’s all you’re giving me? but come on, hear me out."
const INTRO_DIALOGUE_THREE = "When I saw this house, when I sold this house, it was spotless."
const INTRO_DIALOGUE_FOUR = "Shining even. Clean, cool, everything. Then these things came."
const INTRO_DIALOGUE_FIVE = "I had a family of four laying money on my desk til’ they saw the things"
const INTRO_DIALOGUE_SIX = "...red, blue, green, with wings, quick..."
const INTRO_DIALOGUE_SEVEN = "whatever abomination crawled in from the foundation..."
const INTRO_DIALOGUE_EIGHT = "...caused them to leave in minutes."
const INTRO_DIALOGUE_NINE = "And I don’t blame ‘em."
const INTRO_DIALOGUE_TEN = "I’m just the real estate agent, and to be real?"
const INTRO_DIALOGUE_ELEVEN = "I hate bugs too."
const INTRO_DIALOGUE_TWELVE = "So, like, do your job?"
const INTRO_DIALOGUE_THIRTEEN = "Keep killin’ ‘em and I’ll pay you more."
const INTRO_DIALOGUE_FOURTEEN = "But you aren’t gettin’ any money "
const INTRO_DIALOGUE_FIFTEEN = "‘til I see some bug guts on the floor"
const INTRO_DIALOGUE_SIXTEEN = "(Yes, I’m expecting you to clean it up too.)"
const INTRO_DIALOGUE_SEVENTEEN = "Get to Work, "
const INTRO_DIALOGUE_EIGHTEEN = " The guy who’s paying you."

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
const PLAYER_BASE_SCALE = Vector2(1.0, 1.0)
var damage_increase = 0
var size_increase = 0
var luck_increase = 0

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
const VELOCITY_INCREMENT = 5.0
const SCALE_INCREMENT = Vector2(0.1, 0.1)
const LUCK_INCREMENT: float = 0.2

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
	size_increase = 0
	luck_increase = 0
