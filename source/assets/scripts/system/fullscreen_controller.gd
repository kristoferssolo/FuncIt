extends Node

func _process(_delta):
	if Input.is_action_just_pressed("fullscreen_toggle"):
		OS.window_fullscreen = !OS.window_fullscreen
	pass
