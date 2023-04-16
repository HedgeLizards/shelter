extends CharacterBody3D

const MOUSE_SENSITIVITY = 0.003
const speed = 8
const sprint_speed = 24
const gravity = 90

var v_speed = 0.0
var head_phase = 0
var hand_phase = 0
var tween
var low_pass_filter = AudioServer.get_bus_effect(1, 0)
var was_jumping = false
var health = 1.0

signal health_changed

func _ready():
	
	health_changed.emit(health)

func _physics_process(delta):
	#print(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music_Jump")))
	
	var input_movement = Input.get_vector("left", "right", "forwards", "backwards")
	var sprinting = Input.is_action_pressed("sprint")
	var s = speed if not sprinting else sprint_speed
	
	if is_on_floor():
		if v_speed < 0:
			$Head/Camera3D.shake(v_speed / -110)
			
			for body in $SmashArea.get_overlapping_bodies():
				body.hit()
			
			$SND_STEP.play()
			
			if was_jumping:
				$SND_LAND_YETI.play()
				$SND_LAND_IMPACT.play()
				was_jumping = false
#			if was_jumping:
#				$"../BGM".crossfade_buses("Music_Walk", 4)
		
		if Input.is_action_pressed("jump"):
#			$"../BGM".crossfade_buses("Music_Jump", 4)
			$SND_JUMP.play()
			was_jumping = true
			v_speed = 90
		else:
			v_speed = 0
		
	else:
		v_speed -= gravity * delta

	if Input.is_action_pressed("fly"):
		v_speed = 20
	
	velocity = Vector3(input_movement.x * s, v_speed, input_movement.y * s).rotated(Vector3.UP, rotation.y)
	
	move_and_slide()
	
	if (input_movement == Vector2.ZERO and is_on_floor()) or sign(sin(head_phase)) == sign(sin(head_phase + 2 * delta)):
		head_phase = fmod(head_phase + 2 * delta, TAU)
	else:
		head_phase = 0
	
	$Head.position.y = 1.2 + sin(head_phase) * 0.2
	
	if (input_movement != Vector2.ZERO and is_on_floor()) or sign(sin(hand_phase)) == sign(sin(hand_phase + s * delta)):
		if (hand_phase <= 0.5 * PI and hand_phase + s * delta >= 0.5 * PI) or (hand_phase <= 1.5 * PI and hand_phase + s * delta >= 1.5 * PI):
			$SND_STEP.play()
		
		hand_phase = fmod(hand_phase + s * delta, TAU)
	else:
		hand_phase = 0
	
	$Head/Camera3D/Hand1.position.y = -0.7 + sin(hand_phase) * 0.1
	$Head/Camera3D/Hand2.position.y = -0.7 - sin(hand_phase) * 0.1
	
	var distance = self.global_position.distance_to($"../Back of Cave".global_position)
	low_pass_filter.cutoff_hz = 2 ** distance
	low_pass_filter.cutoff_hz = clamp(low_pass_filter.cutoff_hz, 800, 20500)
	
	# When inside, fade out frozen overlay
	if ($Head/InsideTest.has_overlapping_areas()):
		$"../Overlay/Frozen".modulate.a -= .25 * delta
	
	# When outside, fade in the frozen overlay
	else:
		$"../Overlay/Frozen".modulate.a += .025 * delta
	
	$"../Overlay/Frozen".modulate.a = clamp($"../Overlay/Frozen".modulate.a, 0, .15)
	
#	if (Input.is_action_pressed("sprint")):
#		$"../BGM".crossfade_buses("Music_Run", 4)
#	elif (Input.is_action_pressed("sprint") and was_jumping):
#		$"../BGM".crossfade_buses("Music_Walk", 4)
	
	var engaged = false
	
	var nodes_in_group = get_tree().get_nodes_in_group("humans")
	for node in nodes_in_group:
		if node.is_engaged(): 
			engaged = true
			break
	
	var bgm = $"../BGM"
		
	if was_jumping and not is_on_floor() :
		bgm.crossfade_buses(bgm.JUMP,4)
	elif sprinting or engaged:
		bgm.crossfade_buses(bgm.RUN,4)
	else:
		bgm.crossfade_buses(bgm.WALK,4)
	
	if health < 1.0:
		health += delta / 10
		health_changed.emit(health)
	
	
func _input(event):
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			slash()
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		$Head.rotation.x = clamp($Head.rotation.x - event.relative.y * MOUSE_SENSITIVITY, -PI/2, PI/2)
		
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)

func slash():
	if tween != null and tween.is_running():
		return
	
	$SND_SLASH.play()
	
	tween = create_tween().set_parallel()
	
	tween.tween_property($Head/Camera3D/Hand1, "rotation:y", deg_to_rad(101.9 - 35), 0.1)
	tween.tween_property($Head/Camera3D/Hand1, "rotation:z", deg_to_rad(-122.6 - 80), 0.1)
	tween.tween_property($Head/Camera3D/Hand2, "rotation:y", deg_to_rad(78.1 + 35), 0.1)
	tween.tween_property($Head/Camera3D/Hand2, "rotation:z", deg_to_rad(57.4 - 80), 0.1)
	
	tween.chain().tween_property($Head/Camera3D/Hand1, "rotation:y", deg_to_rad(101.9), 0.2)
	tween.tween_property($Head/Camera3D/Hand1, "rotation:z", deg_to_rad(-122.6), 0.2)
	tween.tween_property($Head/Camera3D/Hand2, "rotation:y", deg_to_rad(78.1), 0.2)
	tween.tween_property($Head/Camera3D/Hand2, "rotation:z", deg_to_rad(57.4), 0.2)
	
	for body in $SlashArea.get_overlapping_bodies():
		body.hit()

func hit():
	if !$SND_HIT.playing:
		$SND_HIT.play()
	health -= 0.5;
	health_changed.emit(health)
	if health < -0.5:
		die()

func miss():
	if randf() < 0.5:
		$SND_MISS_LEFT.play()
	else:
		$SND_MISS_RIGHT.play()

func die():
	pass

