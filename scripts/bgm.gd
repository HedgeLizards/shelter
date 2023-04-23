extends Node3D

const STEALTH = "Music_Stealth"
const WALK = "Music_Walk"
const RUN = "Music_Run"
const COMBAT = "Music_Combat"
const JUMP = "Music_Jump"

var tracks = [STEALTH, WALK, RUN, COMBAT, JUMP]
var current_track = WALK
var tween

var atmosphere = AudioServer.get_bus_index("Atmosphere")
var atmosphere_low_pass_filter = AudioServer.get_bus_effect(atmosphere, 0)
var player_low_pass_filter = AudioServer.get_bus_effect(AudioServer.get_bus_index("Player"), 0)

func _ready():
	for track in tracks:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(track), 0 if track == current_track else -50)

func crossfade_buses(to_bus_name, duration, mute_atmosphere):
	if to_bus_name == current_track:
		return
	
	current_track = to_bus_name
	
	var fadeout_duration = duration * AudioServer.get_bus_volume_db(AudioServer.get_bus_index(current_track)) / -50
	var fadein_duration = fadeout_duration / 40
	
	if tween != null:
		tween.kill()
	
	tween = create_tween().set_parallel()
	
	for track in tracks:
		var index = AudioServer.get_bus_index(track)
		
		if track == current_track:
			tween.tween_method(func(value): AudioServer.set_bus_volume_db(index, value), AudioServer.get_bus_volume_db(index), 0, fadein_duration)
		else:
			tween.tween_method(func(value): AudioServer.set_bus_volume_db(index, value), AudioServer.get_bus_volume_db(index), -50.0, fadeout_duration)
	
	if mute_atmosphere:
		tween.tween_method(func(value): AudioServer.set_bus_volume_db(atmosphere, value), AudioServer.get_bus_volume_db(atmosphere), -20, fadeout_duration)
		
		tween.tween_property(atmosphere_low_pass_filter, "cutoff_hz", 1200, fadeout_duration)
		tween.tween_property(player_low_pass_filter, "cutoff_hz", 1200, fadeout_duration)
	else:
		tween.tween_method(func(value): AudioServer.set_bus_volume_db(atmosphere, value), AudioServer.get_bus_volume_db(atmosphere), -12, fadein_duration)
		
		tween.tween_property(atmosphere_low_pass_filter, "cutoff_hz", 20500, fadein_duration)
		tween.tween_property(player_low_pass_filter, "cutoff_hz", 20500, fadein_duration)
