extends Control


func _process(_delta) -> void:
	if Input.is_action_just_pressed("esc") and is_visible_in_tree():
		queue_free()


func _on_return_to_game_pressed():
	queue_free()


func _on_return_to_main_menu_pressed():
	Network._server_leave()
	get_tree().change_scene("res://source/scenes/GUI/main_menu.tscn")


func _on_exit_game_pressed():
	get_tree().quit()
