extends CharacterBody3D

@export var player: Node

var shooting = false
var tween

@onready var camera_3d = player.get_node("Head/Camera3D")
@onready var original_rotation_y = rotation.y
@onready var target_rotation_y = original_rotation_y

func search_player():
	if $RayCast3D.global_position.distance_to(player.global_position) <= $Flashlight/SpotLight3D.spot_range:
		if $RayCast3D.global_position.direction_to(player.global_position).dot(transform.basis.z) < -0.3:
			$RayCast3D.target_position = (player.global_position - $RayCast3D.global_position).rotated(Vector3.UP, -rotation.y)
			$RayCast3D.force_raycast_update()
			
			if $RayCast3D.get_collider() == player:
				if not shooting:
					shooting = true
					
					if tween != null:
						tween.kill()
					
					tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
					
					tween.tween_property($Gun, "rotation:x", -0.5 * PI, 2 - $Gun.rotation.x / (-0.25 * PI))
					tween.tween_callback(shoot).set_delay(0.5)
				
				target_rotation_y = atan2($RayCast3D.global_position.x - player.global_position.x, $RayCast3D.global_position.z - player.global_position.z)
				
				return
	
	if shooting:
		shooting = false
		
		if tween != null:
			tween.kill()
		
		tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		
		tween.tween_property($Gun, "rotation:x", 0, $Gun.rotation.x / (-0.25 * PI))
		
		target_rotation_y = original_rotation_y

func _physics_process(delta):
	if (target_rotation_y > rotation.y and target_rotation_y - rotation.y < PI) or (target_rotation_y < rotation.y and target_rotation_y - rotation.y < -PI):
		rotation.y = min(rotation.y + delta, target_rotation_y)
		
		if rotation.y > PI:
			rotation.y -= TAU
	else:
		rotation.y = max(rotation.y - delta, target_rotation_y)
		
		if rotation.y <= -PI:
			rotation.y += TAU

func shoot():
	# play gunshot sound and hurt player
	
	camera_3d.shake(0.4)
	
	tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	
	tween.tween_property($Gun, "rotation:x", -0.25 * PI, 0.1)
	tween.tween_callback(shoot_again).set_delay(2)

func shoot_again():
	tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	
	tween.tween_property($Gun, "rotation:x", -0.5 * PI, 1)
	tween.tween_callback(shoot).set_delay(0.5)
