extends CharacterBody3D

const MOUSE_SENSITIVITY = 0.003
const speed = 3
const sprint_speed = 100
const gravity = 15

var v_speed = 0

func _physics_process(delta):
	var input_movement = Input.get_vector("left", "right", "forwards", "backwards")
	var s = speed if not Input.is_action_pressed("sprint") else sprint_speed
	
	if is_on_floor():
		v_speed = 8 if Input.is_action_pressed("jump") else 0
	else:
		v_speed -= gravity * delta
	
	velocity = Vector3(input_movement.x * s, v_speed, input_movement.y * s).rotated(Vector3(0, 1, 0), self.rotation.y)
	
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
