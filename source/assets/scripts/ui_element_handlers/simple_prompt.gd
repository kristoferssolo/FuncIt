extends Control


func _on_ok_pressed():
	get_tree().change_scene("res://source/scenes/GUI/main_menu.tscn")


func set_text(text) -> void:
	$Label.text = text