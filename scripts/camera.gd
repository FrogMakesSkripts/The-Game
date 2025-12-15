extends Camera2D

var min_zoom: float = 1.0
var max_zoom: float = 3.5
var zoom_padding: float = 200.0
var zoom_divisor: float = 1200.0
var zoom_speed: float = 3.0
var max_player_distance: float = 2000.0
var zoom_change_rate: float = 1

func _process(delta):
	var players := get_tree().get_nodes_in_group("players")
	if players.is_empty():
		return
	var center := Vector2.ZERO
	for p in players:
		center += p.global_position
	center /= players.size()
	global_position = center.snapped(Vector2(1, 1))
	var min_pos: Vector2 = players[0].global_position
	var max_pos: Vector2 = players[0].global_position
	for p in players:
		min_pos = min_pos.min(p.global_position)
		max_pos = max_pos.max(p.global_position)
	var distance: float = max(max_pos.x - min_pos.x, max_pos.y - min_pos.y)
	if distance > max_player_distance:
		distance = max_player_distance
	var current_zoom: Vector2 = zoom
	var t: float = clamp(distance / max_player_distance, 0.0, 1.0)
	var target_zoom: float = lerp(max_zoom, min_zoom, t)
	var target_zoom_vec: Vector2 = Vector2.ONE * target_zoom
	zoom = zoom.lerp(Vector2.ONE * target_zoom, delta * zoom_speed)
	zoom = current_zoom.move_toward(target_zoom_vec, zoom_change_rate * delta)
