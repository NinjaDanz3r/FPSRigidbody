extends KinematicBody

# Slower moving kinematic platform.

var original_position
var start_position
var end_position
var current_position = Vector3(0,0,0)

func _ready():
	original_position = translation
	end_position = original_position + Vector3(10,0,0)
	start_position = original_position + Vector3(-10,5,0)
	current_position = end_position

func _physics_process(delta):
	if translation.distance_to(end_position) < 1.0:
		current_position = start_position
	elif translation.distance_to(start_position) < 1.0:
		current_position = end_position
	var direction = current_position - translation
	direction = direction.normalized()
	move_and_slide(direction*5)