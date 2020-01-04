extends Spatial

# Simple scene script

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	if(Input.is_action_just_pressed("ui_cancel")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if(Input.is_action_just_pressed("restart")):
		get_tree().reload_current_scene()