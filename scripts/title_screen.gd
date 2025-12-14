extends CenterContainer

@onready var buttons: VBoxContainer = $PanelContainer/VBoxContainer/Buttons

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter"):
		get_tree().change_scene_to_file("res://scenes/game.tscn")
