extends StaticBody2D

signal hit

@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite.play("idle")
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	print("pot cracked")
	if animated_sprite.animation == "crack":
		queue_free()

func combust():
	hit.emit()
	animated_sprite.play("crack")
