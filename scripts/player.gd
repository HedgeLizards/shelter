extends CharacterBody3D

const MOUSE_SENSITIVITY = 0.003
const speed = 3
const sprint_speed = 100

func _physics_process(_delta):
	var input_movement = Input.get_vector("left", "right", "forwards", "backwards")
	var s = speed if not Input.is_action_pressed("sprint") else sprint_speed
	var movement = (Vector3(input_movement.x, 0, input_movement.y) * s).rotated(Vector3(0, 1, 0), self.rotation.y)
	movement.y = s * (float(Input.is_action_pressed("up")) - float(Input.is_action_pressed("down")))
	velocity = movement
	
	move_and_slide()

func _input(event):
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$Head.rotation.x = clamp($Head.rotation.x - event.relative.y * MOUSE_SENSITIVITY, -PI/2, PI/2)
		
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
