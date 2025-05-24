extends Node2D

@onready var portal = $Portal
@onready var skull_portal = $SkullPortal
@onready var exit = $Exit

var player = null
var skeleton = preload("res://scenes/skeleton.tscn")

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	if player != null:
		player.global_position = portal.get_spawn_pos()

	var skeleton_timer = Timer.new()
	skeleton_timer.wait_time = 5
	skeleton_timer.one_shot = false
	add_child(skeleton_timer)
	skeleton_timer.start()
	
	skeleton_timer.connect("timeout", _spawn_skeleton)

func _spawn_skeleton() -> void:
	var new_skeleton = skeleton.instantiate()
	new_skeleton.global_position = skull_portal.get_skeleton_spawn_pos()
	add_child(new_skeleton)
