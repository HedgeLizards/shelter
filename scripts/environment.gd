extends WorldEnvironment


# Called when the node enters the scene tree for the first time.
func _ready():
	var moon_position = %Moon.quaternion * Vector3(0,0,1)
	environment.sky.sky_material.set_shader_parameter("moon_position", moon_position)
	%Frozen.modulate.a = 0
