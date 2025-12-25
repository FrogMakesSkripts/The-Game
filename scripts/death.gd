extends Area2D

@onready var timer: Timer = $Timer
@onready var game: Node2D = get_tree().current_scene

func _on_body_entered(body: Node2D) -> void:
	game.enable_input = false
	Engine.time_scale = 0.25
	body.get_node("CollisionShape2D").queue_free()
	timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
