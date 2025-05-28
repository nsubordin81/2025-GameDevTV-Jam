extends StaticBody2D

@export var pot_id = 0

signal hit(pot_id)

@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite.play("idle")
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	# print("pot cracked")
	if animated_sprite.animation == "crack":
		queue_free()

func combust():
	hit.emit(get_instance_id())
	animated_sprite.play("crack")

func _on_hit_box_body_entered(body: Node2D):
	if body.is_in_group("player"):
		combust()