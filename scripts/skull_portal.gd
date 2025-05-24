extends StaticBody2D

@onready var skeleton_spawn_pos = $SkeletonSpawnPosition

func get_skeleton_spawn_pos():
    return skeleton_spawn_pos.global_position
