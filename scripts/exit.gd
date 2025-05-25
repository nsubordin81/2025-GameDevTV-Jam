extends StaticBody2D
@onready var spawn_pos = $SpawnPosition
@onready var animated_sprite = $ExitDoor


func _ready() -> void:
	animated_sprite.play("closed")
	var main = get_node("/root/main")
	main.unlocked.connect(_on_exit_unlocked)


func get_spawn_pos():
	return spawn_pos.global_position

func _on_exit_unlocked():
	animated_sprite.play("open")
