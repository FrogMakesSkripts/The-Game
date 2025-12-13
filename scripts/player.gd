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

@export var is_interacting: bool = false

@onready var player: CharacterBody2D = $"."
@onready var held_item: Node2D = $HeldItem
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact_animation: AnimationPlayer = $InteractionAnimation
@onready var coyote_timer: Timer = $CoyoteTimer

# MOVEMENT
var inertia = 0

func _physics_process(delta: float) -> void:
# RUN
	if Input.is_action_pressed("run"):
		max_inertia = 45
		acceleration = 2
# ANIMATION
		if inertia > 5:
			animated_sprite.play("Run")
	elif is_on_floor():
		animated_sprite.play("Idle")
	if not is_on_floor():
		animated_sprite.play("Jump")
# DIRECTION
	direction = 0
	if Input.is_action_pressed("move_right"):
		direction = 1
		inertia += acceleration
		if not is_on_floor():
			inertia += acceleration / 2.66
		animated_sprite.flip_h = false
	if Input.is_action_pressed("move_left"):
		direction = -1
		inertia -= acceleration
		if not is_on_floor():
			inertia -= acceleration / 2.66
		animated_sprite.flip_h = true
	if animated_sprite.flip_h == false:
		held_item.scale.x = 1
		held_item.position.x = 10
	if animated_sprite.flip_h == true:
		held_item.scale.x = -1
		held_item.position.x = -10
# DIRECTION SYNCHRONIZATION MANAGER
	var current_interaction_animation = interact_animation.current_animation
	if direction == 1 and not current_interaction_animation == "MineRight":
		if Input.is_action_pressed("interact"):
			interact_animation.play("MineRight")
	if direction == -1 and not current_interaction_animation == "MineLeft":
		if Input.is_action_pressed("interact"):
			interact_animation.play("MineLeft")
# INERTIA
	inertia = clamp(inertia, -max_inertia, max_inertia)
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		pass
	if not Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
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
# GRAVITY
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_pressed("jump") and (is_on_floor() or not coyote_timer.is_stopped()):
		velocity.y = jump + (-coyote_timer.time_left * 2)
# TRANSFORM
	var was_on_floor = is_on_floor()
	velocity.x = direction * speed + inertia
	move_and_slide()
	if was_on_floor and not is_on_floor():
		coyote_timer.start()

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

# make a hold button and attach it to interact

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("interact"):
		is_interacting = true
	else:
		is_interacting = false
		interact_animation.stop()

func update_held_item(item: String):
	var item_scene = load(item)
	var instance = item_scene.instantiate()
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
