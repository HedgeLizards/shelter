extends CharacterBody3D

func search_player(player):
	if $RayCast3D.global_position.distance_to(player.global_position) <= $Flashlight/SpotLight3D.spot_range:
		if $RayCast3D.global_position.direction_to(player.global_position).dot(transform.basis.z) < 0:
			$RayCast3D.target_position = player.global_position - $RayCast3D.global_position
			$RayCast3D.force_raycast_update()
			
			if $RayCast3D.get_collider() == player:
				# found
				
				return
	
	# not found
