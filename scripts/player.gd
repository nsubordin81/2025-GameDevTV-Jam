class_name Player extends CharacterBody2D
# this is important when we are trying to use the 'is' keyword for pattern matching

const SPEED = 300.0

@export var jump_force = 200.0
@export var gravity = 400.0
@export var speed = 125.0
@onready var animated_sprite = $AnimatedSprite2D

var active = true

func _physics_process(delta):
	# only need gravity if they are jumping or falling
	if is_on_floor() == false:
		velocity.y += gravity * delta

	# jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump(jump_force)

	var direction = 0
	if active==true:
		# terminal velocity
		if velocity.y > 500.0:
			velocity.y = 500.0

		# nice way to get horizontal input, takes care of normalization
		direction = Input.get_axis("move_left", "move_right")
	# if direction is 0, we are not moving so don't change flip_h 
	if direction != 0:
		# if direction is -1, we are moving left, so flip_h is true
		animated_sprite.flip_h = direction == -1

	# mega man constant speed and 100% acceleration, easiest to do
	velocity.x = direction * speed

	# this is twhat actually moves the CharacterBody2D
	move_and_slide()

	update_animations(direction)

func jump(force: float):
	velocity.y = -force

func update_animations(direction):
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("walk")
	else:
		animated_sprite.play("jump")

