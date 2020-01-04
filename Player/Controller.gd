extends Spatial

enum CONTROL_METHOD {mouse, gamepad}
export (CONTROL_METHOD) var control = CONTROL_METHOD.mouse

export var forward_input: String = "move_forward"
export var backward_input: String = "move_backward"
export var right_input: String = "move_right"
export var left_input: String = "move_left"
export var jump_input: String = "move_jump"

var mouse_sensitivity = 0.3
var camera_angle = 0.0
var active_control_method

var forward = 0.0
var backward = 0.0
var right = 0.0
var left = 0.0
var jump = false

func _ready():
	if control == CONTROL_METHOD.mouse:
		active_control_method = funcref(self, "mouse_input")
	elif control == CONTROL_METHOD.gamepad:
		active_control_method = funcref(self, "gamepad_input")

func _input(event):
	active_control_method.call_func(event)
	update_directions()

func mouse_input(var event: InputEvent):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x) * mouse_sensitivity)
		var change = -event.relative.y * mouse_sensitivity
		if change + camera_angle < 90 && change + camera_angle > -90:
			$Camera.rotate_x(deg2rad(change))
			camera_angle += change

func gamepad_input(var event: InputEvent):
	push_error("Not yet implemented!")

func update_directions():
	forward = Input.get_action_strength(forward_input)
	backward = Input.get_action_strength(backward_input)
	left = Input.get_action_strength(left_input)
	right = Input.get_action_strength(right_input)
	jump = Input.is_action_pressed(jump_input)