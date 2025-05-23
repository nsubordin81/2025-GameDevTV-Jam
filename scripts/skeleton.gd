extends CharacterBody2D


# Variables
var health: int = 10
var direction: int = 1 # 1 for right, -1 for left
var walk_time: float = 0.0
var walk_timer: float = 0.0
var speed: float = 100.0

# Called when the node enters the scene tree for the first time
func _ready():
    randomize_walk_time()

# Called every frame
func _process(delta: float):
    walk_timer -= delta
    if walk_timer <= 0:
        change_direction()
    velocity.x = speed * direction
    move_and_slide()


# Randomize the walk time
func randomize_walk_time():
    walk_time = randf_range(1.0, 3.0) # Random time between 1 and 3 seconds
    walk_timer = walk_time

# Change direction and flip sprite
func change_direction():
    direction *= -1
    $Sprite.scale.x *= -1 # Flip the sprite horizontally

# Spawn the skeleton at a specific location
func spawn(location: Vector2):
    global_position = location
