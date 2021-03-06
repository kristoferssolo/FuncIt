extends Node

const DEFAULT_PORT = 28414
const MAX_CLIENTS = 4

var server = null
var client = null

var ip_address = ""
var current_player_username = ""

var client_connected_to_server = false

var networked_object_name_index = 0 setget networked_object_name_index_set
puppet var puppet_networked_object_name_index = 0 setget puppet_networked_object_name_index_set

onready var client_connection_timeout_timer = Timer.new()


func _ready() -> void:
	add_child(client_connection_timeout_timer)
	client_connection_timeout_timer.wait_time = 600 # 10 min
	client_connection_timeout_timer.one_shot = true
	
	client_connection_timeout_timer.connect("timeout", self, "_client_connection_timeout")
	
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") and not ip.ends_with(".1"):
			ip_address = ip
	
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_to_server")
# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connection_failed")


func create_server() -> void:
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)
# warning-ignore:return_value_discarded
	Global.instance_node(load("res://source/scenes/GUI/server_handlers/server_advertiser.tscn"), get_tree().current_scene)


func join_server() -> void:
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	client_connection_timeout_timer.start()


func reset_network_connection() -> void:
	if get_tree().has_network_peer():
		get_tree().network_peer = null


func _connected_to_server() -> void:
	print("Successfully connected to the server")


func _server_disconnected() -> void:
	print("Disconnected from the server")
	
	for child in PersistentNodes.get_children():
		if child.is_in_group("Net"):
			child.queue_free()
	reset_network_connection()
	
	if Global.ui != null:
		var prompt = Global.instance_node(load("res://source/scenes/OVERLAY/elements/simple_prompt.tscn"), Global.ui)
		prompt.set_text("Disconnected from server")


func _server_leave() -> void:
	print("Left the server")
	
	for child in PersistentNodes.get_children():
		if child.is_in_group("Net"):
			child.queue_free()
	reset_network_connection()


func _client_connection_timeout():
	if client_connected_to_server == false:
		print("Client has been timed out")
		
		for child in PersistentNodes.get_children():
			if child.is_in_group("Net"):
				child.queue_free()
		reset_network_connection()
		
		var connection_timeout_prompt = Global.instance_node(load("res://source/scenes/OVERLAY/elements/simple_prompt.tscn"), get_tree().current_scene)
		connection_timeout_prompt.set_text("Connection timed out")


func _connection_failed():
	for child in PersistentNodes.get_children():
		if child.is_in_group("Net"):
			child.queue_free()
	reset_network_connection()
	
	if Global.ui != null:
		var prompt = Global.instance_node(load("res://source/scenes/OVERLAY/elements/simple_prompt.tscn"), Global.ui)
		prompt.set_text("Connection failed")


func puppet_networked_object_name_index_set(new_value):
	networked_object_name_index = new_value


func networked_object_name_index_set(new_value):
	networked_object_name_index = new_value
	
	if get_tree().is_network_server():
		rset("puppet_networked_object_name_index", networked_object_name_index)
