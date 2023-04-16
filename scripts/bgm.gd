extends Node3D

var bus1_index
var bus2_index

# Called when the node enters the scene tree for the first time.
func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music_Walk"), 0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music_Run"), -50)

func crossfade_buses(bus_name1 : String, bus_name2 : String, duration: float):
	var tween = create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT)
	
	bus1_index = AudioServer.get_bus_index(bus_name1)
	bus2_index = AudioServer.get_bus_index(bus_name2)
	
	tween.tween_method(set_volume1, AudioServer.get_bus_volume_db(bus1_index), -50.0, duration)
	tween.tween_method(set_volume2, AudioServer.get_bus_volume_db(bus2_index), 0.0, duration/40)

func set_volume1(value):
	AudioServer.set_bus_volume_db(bus1_index, value)

func set_volume2(value):
	AudioServer.set_bus_volume_db(bus2_index, value)
