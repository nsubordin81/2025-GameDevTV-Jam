extends StaticBody2D

signal hit

@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
    animated_sprite.play("idle")

func combust():
    hit.emit()
    animated_sprite.play("crack")
    queue_free()
