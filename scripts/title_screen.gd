extends CenterContainer

@onready var buttons: VBoxContainer = $PanelContainer/VBoxContainer/Buttons

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up"):
		var buttonlist: Array = buttons.get_children()
		for button in buttonlist:
			var button_number = button.get_index() + 1
			print(str(button_number) + str(button))
		
		
