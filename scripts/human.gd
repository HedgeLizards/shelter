extends RigidBody3D

@export var player: Node

var health = 3

const UNAWARE = 0
const SURPRISED = 1
const SHOOTING = 2
const RECOVERING = 3
const SEARCHING = 4
const STANDUP = 6


const min_aim_time = 1.5
const max_aim_time = 3.0
const hit_chance = 0.5

var state = UNAWARE

@onready var camera_3d = player.get_node("Head/Camera3D")
@onready var original_rotation_y = rotation.y
@onready var target_rotation_y = original_rotation_y


func rad_gt(a, b):
	var d = fposmod(a - b, 2*PI)
	return d < PI

func rad_lt(a, b):
	return rad_gt(b, a)

func rad_sub(a, b):
	var d = fposmod(a - b, 2*PI)
	if d > PI:
		d -= 2 * PI
	return d

func rad_abs(a):
	# var d = fposmod(a, 2*PI)
	return min(a, 2*PI - a)


func _ready():
	freeze = true
	$AITick.start(randf()) # give each enemy a random tick moment

func can_see_player():
	var dist = $RayCast3D.global_position.distance_to(player.global_position)
	if dist <= %Rifle/SpotLight3D.spot_range:
		if $RayCast3D.global_position.direction_to(player.global_position).dot(transform.basis.z) < -0.3:
			$RayCast3D.target_position = (player.global_position - $RayCast3D.global_position).rotated(Vector3.UP, -rotation.y)
			$RayCast3D.force_raycast_update()
			if $RayCast3D.get_collider() == player:
				return true
	return false


func can_shoot_player():
	var dist = $RayCast3D.global_position.distance_to(player.global_position)
	if dist <= %Rifle/SpotLight3D.spot_range:
		if $RayCast3D.global_position.direction_to(player.global_position).dot(transform.basis.z) < -0.6:
			$RayCast3D.target_position = (player.global_position - $RayCast3D.global_position).rotated(Vector3.UP, -rotation.y)
			$RayCast3D.force_raycast_update()
			if $RayCast3D.get_collider() == player:
				return true
	return false

func start_shooting():
	if $Aim.is_stopped():
		$Aim.start(randf_range(min_aim_time, max_aim_time))

func stop_shooting():
	$Aim.stop()

func _physics_process(delta):
	var dist = $RayCast3D.global_position.distance_to(player.global_position)
	if state != RECOVERING and state != STANDUP:
		linear_velocity.y = -1
		rotate_to_target(delta)
		move_and_collide(Vector3(0, -10, 0))
	elif state == STANDUP:
		position.y += 1
		move_and_collide(Vector3(0, -10, 0))
		if rotation.z == 0 and rotation.x == 0:
			state = SEARCHING
			return
		if rotation.x > 0:
			rotation.x = max(rotation.x - delta * PI/2, 0)
		if rotation.x < 0:
			rotation.x = min(rotation.x + delta * PI/2, 0)
		if rotation.z > 0:
			rotation.z = max(rotation.z - delta * PI/2, 0)
		if rotation.z < 0:
			rotation.z = min(rotation.z + delta * PI/2, 0)
	if state == UNAWARE:
		play_animation("hu_anims/idle")
		stop_shooting()
		if dist < 3:
			state = SHOOTING
			return
		if can_see_player():
			state = SURPRISED
			target_rotation_y = atan2($RayCast3D.global_position.x - player.global_position.x, $RayCast3D.global_position.z - player.global_position.z)
			$Surprise.start()
			return
	
	if state == SHOOTING:
		play_animation("hu_anims/crouch_aim")
		if dist > %Rifle/SpotLight3D.spot_range*1.5:
			state = SEARCHING
			$Searching.start()
			return
		target_rotation_y = atan2($RayCast3D.global_position.x - player.global_position.x, $RayCast3D.global_position.z - player.global_position.z)
		if can_shoot_player():
			start_shooting()
		else:
			stop_shooting()
			# target_rotation_y = original_rotation_y
	if state == SEARCHING:
		if dist < 3 or can_see_player():
			state = SHOOTING


func rotate_to_target(delta):
	var d = delta * 1.5
	var r = rad_sub(target_rotation_y, rotation.y)
	if abs(r) < d:
		return
	elif r > 0:
		rotation.y += d
	else:
		rotation.y -= d

func shoot():
	$SND_SHOOT.play()
	
	if randf() < hit_chance:
		# play gunshot sound and hurt player
		player.hit()
		camera_3d.shake(0.5)
	else:
		player.miss()


func hit():
	# play screaming sound and emit blood particles

	$GetUp.stop()
	
	health -= 1
	
	freeze = false
	# %Skeleton.physical_bones_start_simulation()
	
	var dir = player.position.direction_to(position)
	dir.y = 0.8
	linear_velocity = dir * 25
	angular_velocity = Vector3(2, randf()-.5, 0)
	state = RECOVERING

	stop_shooting()
	
	if health > 0:
		$GetUp.start()
	else:
		var hit_tween = create_tween()
		hit_tween.parallel().tween_property(%HumanModel, "transparency", 1, 2)
		hit_tween.tween_callback(queue_free)
		
		set_physics_process(false)
		remove_from_group("humans")



func _on_get_up_timeout():
	freeze = true
	# %Skeleton.physical_bones_stop_simulation()
	state = STANDUP


func _on_ai_tick_timeout():
	if state == UNAWARE:
		if randf() < 0.2:
			target_rotation_y += randf()-0.5
	if state == SURPRISED:
		target_rotation_y += (randf()-0.5)/2
	if state == SEARCHING:
		target_rotation_y += (randf()-0.5)*3


func _on_surprise_timeout():
	if state == SURPRISED:
		state = SHOOTING


func _on_searching_timeout():
	if state == SEARCHING:
		state = UNAWARE
		
		
func is_engaged():
	return state == SHOOTING or state == RECOVERING or state == STANDUP

func play_animation(name):
	$HumanAnimationPlayer.play(name, 1)
