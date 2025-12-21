extends Node2D

@onready var players: Node = $Players

const player_scene = preload("res://scenes/player.tscn")
const player_limit = 4
const player_spawnpoint = 24
const player_spacing = 16

@export var controllers: Array = Input.get_connected_joypads()
@export var deadzone: float = 0.5

var input_move_left := {0: false, 1: false, 2: false, 3: false}
var input_move_right := {0: false, 1: false, 2: false, 3: false}
var input_run := {0: false, 1: false, 2: false, 3: false}
var input_jump := {0: false, 1: false, 2: false, 3: false}
var input_interact := {0: false, 1: false, 2: false, 3: false}

# CONNECTION MANAGER

func _ready() -> void:
	print("Available Players: " + str(player_limit))
	for device_id in controllers:
		if device_id < player_limit:
			var device_name = Input.get_joy_name(device_id)
			print("Connected Controller: " + str(device_name) + ", with ID: " + str(device_id))
			var player = player_scene.instantiate()
			players.add_child(player)
			player.position.x = player_spawnpoint - (device_id * player_spacing)
			player.player_id = device_id
			print("Assigned Controller with ID: " + str(device_id) + ", to player: " + str(player.player_id))
			print(" ")
	if not controllers:
		print("No Controllers found, defaulting to keyboard.")
		var player = player_scene.instantiate()
		players.add_child(player)
		player.position.x = player_spawnpoint
		player.player_id = 0
		print("Assigned Keyboard to player: " + str(player.player_id))
		print(" ")

# INPUT HANDLER

func _input(event: InputEvent) -> void:
	var device_id := event.device
	if event is InputEventJoypadButton:
		if event.is_action("move_left"):
			input_move_left[device_id] = event.pressed
		if event.is_action("move_right"):
			input_move_right[device_id] = event.pressed
		if event.is_action("run"):
			input_run[device_id] = event.pressed
		if event.is_action("jump"):
			input_jump[device_id] = event.pressed
		if event.is_action("interact"):
			input_interact[device_id] = event.pressed
	elif event is InputEventJoypadMotion:
		if event.is_action("move_left"):
			input_move_left[device_id] = event.axis_value < -deadzone
		if event.is_action("move_right"):
			input_move_right[device_id] = event.axis_value > deadzone
	elif event is InputEventKey:
		if event.is_action("move_left"):
			input_move_left[device_id] = event.pressed
		if event.is_action("move_right"):
			input_move_right[device_id] = event.pressed
		if event.is_action("run"):
			input_run[device_id] = event.pressed
		if event.is_action("jump"):
			input_jump[device_id] = event.pressed
	elif event is InputEventMouse:
		if event.is_action("interact"):
			input_interact[device_id] = event.pressed
