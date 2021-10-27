extends KinematicBody2D

# Instance of data handlers
var userInputInstance = preload("res://source/assets/scripts/handlers/system/input/user_input_handler.gd").new()
var vectoralDirectionPresetInstance = preload("res://source/assets/scripts/handlers/system/vectoralPresets/vectoral_direction_preset_handler.gd").new()

# Instance of data processors
var VDIRprocessorInstance = preload("res://source/assets/scripts/processors/VDIR/vectoral_direction_processor.gd").new()
var CRprocessorInstance = preload("res://source/assets/scripts/processors/CR/client_rotation_processor.gd").new()

# Instance of game controllers
var canvasManagerInstance = preload("res://source/assets/scripts/controllers/managers/canvas_manager.gd").new()
var physicsManagerInstance = preload("res://source/assets/scripts/controllers/managers/physics_manager.gd").new()

func _process(delta):
	# Update data-handler returned states
	# Send the returned states through processors
	# Give the resulting data to game controllers
	pass
