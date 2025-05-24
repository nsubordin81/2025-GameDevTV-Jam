extends Node2D

@onready var portal = $Portal
@onready var skeleton_spawn_position = $SkeletonSpawnPosition
@onready var exit = $Exit

var player = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	if player != null:
		player.global_position = portal.get_spawn_pos()