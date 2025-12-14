extends Area2D

@onready var mine_area: CollisionShape2D = $PickaxePoint/MineArea
@onready var pickaxe: Area2D = $"."

func _on_body_entered(body: Node2D) -> void:
	if not body.has_node("HeldItem/Pickaxe"):
		queue_free()
		body.give_item("Basic Pickaxe ", 1)
		body.update_held_item("res://scenes/Pickaxe.tscn")

func break_tile(tilemap: TileMap, world_position: Vector2) -> void:
	var local_pos: Vector2 = tilemap.to_local(world_position)
	var cell: Vector2i = tilemap.local_to_map(local_pos)
	tilemap.erase_cell(0, cell)
	

func _on_pickaxe_point_body_entered(body: Node2D) -> void:
	if body is TileMap:
		var player = pickaxe.get_parent().get_parent()
		var interact_animation = player.find_child("InteractionAnimation", true, false)
		if interact_animation.is_playing() and player.is_interacting:
			break_tile(body, mine_area.global_position)
			player.is_interacting = false
			player.interact_animation.stop()
