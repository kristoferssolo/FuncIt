extends Node2D

var time = 0


func _process(delta):
	time += delta
	if time > 17:
		queue_free()
