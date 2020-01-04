extends RigidBody

export var forward_input: String = "move_forward"
export var backward_input: String = "move_backward"
export var right_input: String = "move_right"
export var left_input: String = "move_left"
export var jump_input: String = "move_jump"

export var walk_max_speed = 16.0
export var walk_acceleration = 32.0
export var walk_deacceleration = 64.0
export var air_acceleration = 4.0
export var air_deacceleration = 16.0
export var jump_speed = 10.0
export var stop_jump_force = 8.0
export var max_floor_airborne_time = 0.50

var airborne_time = 1e20
var jumping = false
var stopping_jump = false
var floor_velocity = Vector3.ZERO

func _integrate_forces(state):
	var aim = $Controller/Camera.get_global_transform().basis
	var direction = Vector3(0, 0, 0)
	direction -= aim.z*$Controller.forward
	direction += aim.z*$Controller.backward
	direction -= aim.x*$Controller.left
	direction += aim.x*$Controller.right
	
	var velocity = state.get_linear_velocity()
	velocity -= floor_velocity
	floor_velocity = Vector3.ZERO
	
	var found_floor = false
	var floor_index = -1
	var contact_normal = Vector3.UP
	for contact_index in range(state.get_contact_count()):
		contact_normal += state.get_contact_local_normal(contact_index)
		if contact_normal.dot(Vector3.UP) > 0.6:
			found_floor = true
			floor_index = contact_index
	contact_normal = contact_normal.normalized()
	
	direction -= direction.dot(contact_normal)*contact_normal
	if direction.length() > 1.0:
		direction = direction.normalized()
	
	var step = state.get_step()
	if found_floor:
		airborne_time = 0.0
	else:
		airborne_time += step
	
	var jump = $Controller.jump
	if jumping:
		if velocity.y < 0:
			jumping = false
		elif not jump:
			stopping_jump = true
		if stopping_jump:
			velocity.y -= stop_jump_force * step
	
	var on_floor = airborne_time < max_floor_airborne_time
	
	if on_floor:
		var state_transform = state.get_transform()
		var space = state.get_space_state()
		var origin = state_transform.origin
		var result = space.intersect_ray(origin, origin + Vector3.DOWN*1.5, [self])
		if result:
			if not jumping and abs(result.position.y - origin.y) > 1.0:
				state_transform.origin.y = result.position.y + 0.95
				state.set_transform(state_transform)
		
		if direction.length() > 0 and velocity.length() < walk_max_speed:
			velocity += direction*walk_acceleration*step
		else:
			var walk_friction = velocity.length()
			walk_friction -= walk_deacceleration*step
			if walk_friction < 0:
				walk_friction = 0
			velocity -= walk_friction*velocity.normalized()*step
		if not jumping and jump:
			velocity += jump_speed*contact_normal
			jumping = true
			stopping_jump = false
	else:
		if direction.length() > 0 and velocity.length() < walk_max_speed:
			velocity += air_acceleration*step*direction
		else:
			var velocity_in_plane = velocity
			velocity_in_plane.y = 0.0
			var air_friction = air_deacceleration*step*velocity_in_plane.normalized()
			velocity -= air_friction
	
	if found_floor and floor_index != -1:
		floor_velocity = state.get_contact_collider_velocity_at_position(floor_index)
		floor_velocity.y = 0
		velocity += floor_velocity
	
	state.set_linear_velocity(velocity)