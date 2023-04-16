extends Node3D

var current_bus_index = AudioServer.get_bus_index("Music_Walk")
var new_bus_index

# Called when the node enters the scene tree for the first time.
func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music_Walk"), 0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music_Run"), -50)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music_Jump"), -50)

func crossfade_buses(to_bus_name : String, duration: float):
	var tween = create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT)
	
	new_bus_index = AudioServer.get_bus_index(to_bus_name)
	
	print("Current Bus: " + AudioServer.get_bus_name(current_bus_index))
	print("New Bus: " + AudioServer.get_bus_name(new_bus_index))
	
	var from_bus = current_bus_index
	var to_bus = new_bus_index
	tween.tween_method(func(value): AudioServer.set_bus_volume_db(from_bus, value), AudioServer.get_bus_volume_db(current_bus_index), -50.0, duration)
	tween.tween_method(func(value): AudioServer.set_bus_volume_db(to_bus, value), AudioServer.get_bus_volume_db(new_bus_index), 0.0, duration/40)

	current_bus_index = new_bus_index
	
#func set_volume1(value):
#	AudioServer.set_bus_volume_db(current_bus_index, value)

#func set_volume2(value):
#	AudioServer.set_bus_volume_db(new_bus_index, value)
