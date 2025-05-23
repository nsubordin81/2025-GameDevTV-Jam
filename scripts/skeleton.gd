extends CharacterBody2D

# Variables
var health: int = 10
var direction: int = 1 # 1 for right, -1 for left
var walk_time: float = 0.0
var walk_timer: float = 0.0
var speed: float = 100.0
var gravity: float = 500.0 # Gravity value
var previous_velocity = velocity


# Reference to the AnimatedSprite2D node
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time
func _ready():
    randomize_walk_time()

# Called every frame
func _physics_process(delta: float):
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
