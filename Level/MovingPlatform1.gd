extends KinematicBody

# Chaotic kinematic platform.

var time = 0
var original_position = Vector3()

func _ready():
	original_position = translation

func _process(delta):
	time += delta
	var point = original_position
	point.y += 15*sin(time*3)
	point.x += 10*cos(time)
	point.z += 10*sin(time)
	var velocity = (point - translation)
	velocity = move_and_slide(velocity)