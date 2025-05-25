extends Node2D

@onready var portal = $Portal
@onready var skull_portal = $SkullPortal
# @onready var exit = $Exit

@export var win_state = 4

signal unlocked

var pots_busted = 0
var player = null
var pots = null
var skeleton = preload("res://scenes/skeleton.tscn")
var already_hit = []


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	pots = get_tree().get_nodes_in_group("pickups")

	for pot in pots:
		pot.hit.connect(_on_pot_busted)
	
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

func unlock_exit():
	unlocked.emit()

func _on_pot_busted(pot_id):
	if pot_id not in already_hit:
		pots_busted += 1
		print("another pot bites the dust")
		if pots_busted >= win_state:
			unlock_exit()
		already_hit.append(pot_id)
