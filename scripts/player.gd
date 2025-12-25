extends CharacterBody2D

@onready var inventory = {
	"empty 1": 0,
	"empty 2": 0,
	"empty 3": 0,
	}

@export var direction = 0
@export var speed = 100
@export var jump = -200
@export var max_inertia = 30
@export var acceleration = 1.5
@export var deceleration = 0.7

@export var player_id: int
@export var is_interacting: bool = false

@onready var held_item: Node2D = $HeldItem
@onready var item_scene_cache: Dictionary = {}

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact_animation: AnimationPlayer = $InteractionAnimation
@onready var coyote_timer: Timer = $CoyoteTimer

@onready var player = animated_sprite.get_parent()
@onready var players = player.get_parent()
@onready var game = players.get_parent()

# PLAYER MOVEMENT

var inertia = 0
func _physics_process(delta: float) -> void:
	if game.input_run[player_id] == true:
		max_inertia = 45
		acceleration = 2
		if inertia > 5:
			animated_sprite.play("Run")
	elif is_on_floor():
		animated_sprite.play("Idle")
	if not is_on_floor():
		animated_sprite.play("Jump")
	direction = 0
	if game.input_move_right[player_id] == true:
		direction = 1
		inertia += acceleration
		if not is_on_floor():
			inertia += acceleration / 2.66
		animated_sprite.flip_h = false
	if game.input_move_left[player_id] == true:
		direction = -1
		inertia -= acceleration
		if not is_on_floor():
			inertia -= acceleration / 2.66
		animated_sprite.flip_h = true
	inertia = clamp(inertia, -max_inertia, max_inertia)
	if not game.input_move_right[player_id] == true and not game.input_move_left[player_id] == true:
		if animated_sprite.flip_h == false:
			if inertia >= deceleration:
				inertia -= deceleration
			if inertia < deceleration:
				inertia = 0
		if animated_sprite.flip_h == true:
			if inertia <= -deceleration:
				inertia += deceleration
			if inertia > -deceleration:
				inertia = 0
	if not is_on_floor():
		velocity += get_gravity() * delta
	if game.input_jump[player_id] and (is_on_floor() or not coyote_timer.is_stopped()):
		velocity.y = jump + (-coyote_timer.time_left * 2)
	var was_on_floor = is_on_floor()
	velocity.x = direction * speed + inertia
	move_and_slide()
	if was_on_floor and not is_on_floor():
		coyote_timer.start()

# TOOL FUNCTIONS

func get_non_digits(s: String) -> String:
	var text := ""
	for c in s:
		if not (c >= "0" and c <= "9"):
			text += c
	return text

func get_trailing_number(s: String) -> int:
	var digits := ""
	for i in range(s.length() - 1, -1, -1):
		var c: String = s[i]
		if c >= "0" and c <= "9":
			digits = c + digits
		else:
			break
	return int(digits)

# HELD ITEM INTERACTIONS

func _process(delta: float) -> void:
	is_interacting = game.input_interact[player_id]
	if animated_sprite.flip_h == false:
		held_item.scale.x = 1
		held_item.position.x = 10
		if is_interacting == true and interact_animation.current_animation != "MineRight":
			interact_animation.play("MineRight")
		if is_interacting == false and interact_animation.current_animation == "MineRight":
			interact_animation.stop()
	if animated_sprite.flip_h == true:
		held_item.scale.x = -1
		held_item.position.x = -10
		if is_interacting == true and interact_animation.current_animation != "MineLeft":
			interact_animation.play("MineLeft")
		if is_interacting == false and interact_animation.current_animation == "MineLeft":
			interact_animation.stop()

# INVENTORY

func update_held_item(item: String) -> void:
	var scene: PackedScene
	if item_scene_cache.has(item):
		scene = item_scene_cache[item]
	else:
		scene = load(item)
		if scene == null:
			push_error("Invalid item scene: " + item)
			return
		item_scene_cache[item] = scene
	var instance := scene.instantiate()
	var pickup_area = instance.find_child("PickupArea", true, false)
	pickup_area.disabled = true
	held_item.add_child(instance)

func update_inventory():
	pass

func give_item(give: String, amount: int):
	for item in inventory:
		var item_count = inventory[item]
		var exact_item = get_non_digits(item)
		print("preparing to give item " + str(exact_item))
		if str(exact_item) == give:
			inventory[item] = (item_count + amount)
			print("already had, your inventory is now: " + str(inventory))
			update_inventory() #CALL WITH PARAMETERS
			return
	for item in inventory:
		var item_count = inventory[item]
		if item_count == 0:
			inventory.erase(item)
			var slot_number = get_trailing_number(item)
			print("preparing to write to slot number " + str(slot_number))
			inventory[give + str(slot_number)] = amount
			print("did not have, your inventory is now: " + str(inventory))
			update_inventory() #CALL WITH PARAMETERS
