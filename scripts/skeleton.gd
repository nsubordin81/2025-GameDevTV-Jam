extends CharacterBody2D

# # Variables
# var health: int = 10
var direction: int = 1 # 1 for right, -1 for left
var walk_time: float = 0.0
var walk_timer: float = 0.0
var speed: float = 300.0
var gravity: float = 400.0 # Gravity value
var previous_velocity = velocity
var death_timer = 10.0 # Initialize death timer with a longer fuse (e.g., 10 seconds)
var dead = false

var jump_time: float = 0.0
var jump_timer: float = 0.0
const JUMP_FORCE: float = 500.0
const MIN_JUMP_INTERVAL: float = 2.0
const MAX_JUMP_INTERVAL: float = 6.0

# Reference to the AnimatedSprite2D node
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurt_box = $HurtBox

# Called when the node enters the scene tree for the first time
func _ready():
	randomize_walk_time()
	randomize_jump_time()

	animated_sprite.animation_finished.connect(_on_animation_finished)
	add_to_group("skeletons")

# Called every frame
func _physics_process(delta: float):
	# Decrease the death timer and check if it has run out
	self.death_timer -= delta
	if self.death_timer <= 0:
		death()

	walk_timer -= delta
	if walk_timer <= 0:
		change_direction()
	
	# Apply gravity
	velocity.y += gravity * delta
	
	# Set horizontal velocity
	velocity.x = speed * direction

	# Add jump timer check
	if is_on_floor():
		jump_timer -= delta
		if jump_timer <= 0:
			perform_jump()
			randomize_jump_time()
	
	# if velocity != previous_velocity:
		# print("Velocity: ", velocity)
	previous_velocity = velocity
	
	# Move the skeleton
	move_and_slide()

	update_animations()

# Randomize the walk time
func randomize_walk_time():
	walk_time = round(randf_range(0.0, 5.0)) # Random time between 1 and 5 seconds, rounded to a whole number
	walk_timer = walk_time
	# print("Walk timer set to: ", walk_timer)

# Change direction and flip sprite
func change_direction():
	direction *= -1
	animated_sprite.flip_h = direction == -1
	randomize_walk_time()

# Spawn the skeleton at a specific location
func spawn(location: Vector2):
	global_position = location

func death():
	# print("yo, the skeleton is dead")
	set_physics_process(false)
	dead = true

func _on_animation_finished():
	# print("animation is done")
	if animated_sprite.animation == "death":
		# print("and we are here")
		queue_free()

func randomize_jump_time():
	jump_time = randf_range(MIN_JUMP_INTERVAL, MAX_JUMP_INTERVAL)
	jump_timer = jump_time

func perform_jump():
	if is_on_floor():
		velocity.y = - JUMP_FORCE

func update_animations():
	if dead:
		animated_sprite.play("death")
	elif !is_on_floor():
		animated_sprite.play("jump") # Add a jump animation if you have one
	elif direction == 0:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("walk")

func _on_hurt_box_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.take_damage(global_position)
