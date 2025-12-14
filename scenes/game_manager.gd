extends Node2D

@onready var player1: CharacterBody2D = $Player1
@onready var player2: CharacterBody2D = $Player2

func _ready() -> void:
	var joypads = Input.get_connected_joypads()
	player1.player_id = joypads[0]
	player2.player_id = joypads[1]
	print("Controller Connected: " + str(player1.player_id))
	print("Controller Connected: " + str(player2.player_id))
