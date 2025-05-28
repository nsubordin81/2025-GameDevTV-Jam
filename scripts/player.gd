class_name PlayerCharacter extends CharacterBody2D

signal damaged(current_health: float, max_health: float)
signal death

const SPEED = 1000.0
const TOTAL_HEALTH = 100
const RECOVERY_TIME = 0.25 # Reduced from 1.0 to 0.5 seconds
const KNOCKBACK_FORCE = Vector2(200, -150) # Horizontal and upward force

@export var jump_force = 600.0
@export var gravity = 600.0
@export var speed = 350.0
@export var health = TOTAL_HEALTH
@export var damage = 10
@onready var animated_sprite = $AnimatedSprite2D

const SKELETON_NAME = "Skeleton"

var recovering = false
var active = true
var recoil = Vector2(-200, 0)
var hit_direction = 1 # 1 for right, -1 for left

func _physics_process(delta):
	# Handle visual feedback during recovery
	if recovering:
		animated_sprite.modulate.a = 0.5 if Engine.get_frames_drawn() % 2 == 0 else 1.0
	else:
		animated_sprite.modulate.a = 1.0

	# only need gravity if they are jumping or falling
	if is_on_floor() == false:
		velocity.y += gravity * delta

	# jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and active == true:
		jump(jump_force)

	var direction = 0
	if active == true:
		# terminal velocity
		if velocity.y > 500.0:
			velocity.y = 500.0

		# nice way to get horizontal input, takes care of normalization
		direction = Input.get_axis("move_left", "move_right")
	# if direction is 0, we are not moving so don't change flip_h 
	if direction != 0:
		# if direction is -1, we are moving left, so flip_h is true
		animated_sprite.flip_h = direction == -1
		hit_direction = direction # Store last movement direction

	# Apply horizontal movement only if not recovering from hit
	if !recovering:
		velocity.x = direction * speed
	else:
		# Gradually reduce knockback
		velocity.x = move_toward(velocity.x, 0, speed * delta * 2)
	
	move_and_slide()

	var hit_a_pot = null

	
	if hit_a_pot:
		hit_a_pot.combust()
		hit_a_pot = null
		

	update_animations(direction)

func jump(force: float):
	velocity.y = - force

func take_damage(attacker_pos: Vector2):
	if !recovering:
		# Determine knockback direction based on attacker position
		var knockback_dir = -1 if attacker_pos.x < global_position.x else 1
		
		# Apply knockback force
		velocity = Vector2(KNOCKBACK_FORCE.x * knockback_dir, KNOCKBACK_FORCE.y)

		health = health - damage
		if health <= 0:
			health = 0
			emit_signal("death")
		recovering = true
		start_recovering()
		# Emit the damaged signal with current health percentage
		emit_signal("damaged", health, TOTAL_HEALTH)
	

func start_recovering():
	var recovery_timer = Timer.new()
	recovery_timer.wait_time = RECOVERY_TIME
	recovery_timer.one_shot = true
	recovery_timer.connect("timeout", _on_recovery_timeout)
	add_child(recovery_timer)
	recovery_timer.start()

func _on_recovery_timeout():
	recovering = false

func update_animations(direction):
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("walk")
	else:
		animated_sprite.play("jump")

func set_active(value: bool) -> void:
	active = value