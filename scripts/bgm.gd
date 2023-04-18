extends Node3D

#var current_bus_index = AudioServer.get_bus_index("Music_Walk")
var new_bus_index

const STEALTH = "Music_Stealth"
const WALK = "Music_Walk"
const RUN = "Music_Run"
const COMBAT = "Music_Combat"
const JUMP = "Music_Jump"


var tracks = [STEALTH, WALK, RUN, COMBAT, JUMP]
var fadein_duration = 0.25
var fadeout_duration = 4
var current_track = WALK

var diff = 50

var atmosphere = AudioServer.get_bus_index("Atmosphere")
var atmosphere_muted = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for track in tracks:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(track), 0 if track == current_track else -50)

func _process(delta):
	for track in tracks:
		var index = AudioServer.get_bus_index(track)
		var volume = AudioServer.get_bus_volume_db(index)
		var new_volume = volume
		if track == current_track and volume < 0:
			new_volume = min(volume + delta / fadein_duration * diff, 0)
		elif track != current_track and volume > -50:
			new_volume = max(volume - delta / fadeout_duration * diff, -50)
		# print(("* " if track == current_track else "  ") + track + " " + str(index) +  " " + str(volume) + " " + str(new_volume))
		AudioServer.set_bus_volume_db(index, new_volume)
	# print("")
	
	# Change this code to be interpolating, right now it's instant
	if atmosphere_muted:
		AudioServer.set_bus_volume_db(atmosphere, -20)
		var low_pass_filter = AudioServer.get_bus_effect(atmosphere, 0)
		low_pass_filter.cutoff_hz = 1200
		low_pass_filter = AudioServer.get_bus_effect(AudioServer.get_bus_index("Player"), 0)
		low_pass_filter.cutoff_hz = 1200
	
	# Change this code to be interpolating, right now it's instant
	else: 
		AudioServer.set_bus_volume_db(atmosphere, -12)
		var low_pass_filter = AudioServer.get_bus_effect(atmosphere, 0)
		low_pass_filter.cutoff_hz = 20500
		low_pass_filter = AudioServer.get_bus_effect(AudioServer.get_bus_index("Player"), 0)
		low_pass_filter.cutoff_hz = 20500
	
	delta * rotation

func crossfade_buses(to_bus_name : String, duration: float):
	current_track = to_bus_name
	fadeout_duration = duration
	fadein_duration = duration / 40
	return
#	var tween = create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT)
#
#	new_bus_index = AudioServer.get_bus_index(to_bus_name)
#
#	print("Current Bus: " + AudioServer.get_bus_name(current_bus_index))
#	print("New Bus: " + AudioServer.get_bus_name(new_bus_index))
#
#	var from_bus = current_bus_index
#	var to_bus = new_bus_index
#	tween.tween_method(func(value): AudioServer.set_bus_volume_db(from_bus, value), AudioServer.get_bus_volume_db(from_bus), -50.0, duration)
#	tween.tween_method(func(value): AudioServer.set_bus_volume_db(to_bus, value), AudioServer.get_bus_volume_db(to_bus), 0.0, duration/40)
#
#	current_bus_index = new_bus_index
	
#func set_volume1(value):
#	AudioServer.set_bus_volume_db(current_bus_index, value)

#func set_volume2(value):
#	AudioServer.set_bus_volume_db(new_bus_index, value)

func mute_atmosphere(mute : bool):
	atmosphere_muted = mute
