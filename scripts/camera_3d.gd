extends Camera3D

var shake_duration

func _ready():
	set_process(false)

func shake(duration):
	shake_duration = duration
	
	set_process(true)

func _process(delta):
	if shake_duration <= 0:
		shake_duration = 0
		
		set_process(false)
	
	position.x = (randf() - 0.5) * shake_duration
	position.y = (randf() - 0.5) * shake_duration
	position.z = (randf() - 0.5) * shake_duration
	
	shake_duration -= delta
