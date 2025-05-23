extends CharacterBody2D

# # Variables
# var health: int = 10
var direction: int = 1 # 1 for right, -1 for left
var walk_time: float = 0.0
var walk_timer: float = 0.0
var speed: float = 100.0
var gravity: float = 500.0 # Gravity value
var previous_velocity = velocity
var death_timer = 10.0 # Initialize death timer with a longer fuse (e.g., 10 seconds)
var dead = false


# Reference to the AnimatedSprite2D node
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time
func _ready():
	randomize_walk_time()

	animated_sprite.animation_finished.connect(_on_animation_finished)

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
	print("yo, the skeleton is dead")
	set_physics_process(false)
	dead = true

func _on_animation_finished():
	print("animation is done")
	if animated_sprite.animation == "death":
		print("and we are here")
		queue_free()

func update_animations():
	if dead:
		animated_sprite.play("death")
	elif is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("walk")
	else:
		animated_sprite.play("jump")
