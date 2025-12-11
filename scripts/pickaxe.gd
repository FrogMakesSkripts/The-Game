extends Area2D

func _on_body_entered(body: Node2D) -> void:
	queue_free()
	body.give_item("Basic Pickaxe ", 1)
	body.update_held_item("res://assets/items/Basic_Pickaxe.png")
