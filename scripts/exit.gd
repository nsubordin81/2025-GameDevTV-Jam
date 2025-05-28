extends StaticBody2D

@onready var spawn_pos = $SpawnPosition
@onready var animated_sprite = $ExitDoor
@onready var collision = $CollisionShape2D
@onready var interface = preload("res://dialogue/interface/interface.tscn")


func _ready() -> void:
	animated_sprite.play("closed")
	var main = get_node("/root/main")
	main.unlocked.connect(_on_exit_unlocked)


func get_spawn_pos():
	return spawn_pos.global_position

func _on_exit_unlocked():
	animated_sprite.play("open")
	
func _on_body_entered(body):
	# print("HEEEEEEEEYYYYYYYYYYYY")
	if body.is_in_group("player") and animated_sprite.animation == "open":
		var main = get_node("/root/main")
		body.set_active(false)
		main.show_victory_dialog()
