extends Node2D

@onready var portal = $Portal
@onready var skull_portal = $SkullPortal
@onready var interface = $Interface
@onready var dialog_player = $DialoguePlayer

@export var win_state = 4

signal unlocked

const START_DIALOGUE = "res://dialogue/dialogue_data/start.json"
const VICTORY_DIALOGUE = "res://dialogue/dialogue_data/victory.json"

var pots_busted = 0
var player = null
var pots = null
var skeleton = preload("res://scenes/skeleton.tscn")
var already_hit = []
var skeleton_timer = null


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	pots = get_tree().get_nodes_in_group("pickups")

	for pot in pots:
		pot.hit.connect(_on_pot_busted)
	
	if player != null:
		player.global_position = portal.get_spawn_pos()
		# Disable player movement initially
		player.set_active(false)

	# Setup skeleton timer but don't start it yet
	skeleton_timer = Timer.new()
	skeleton_timer.wait_time = 5
	skeleton_timer.one_shot = false
	add_child(skeleton_timer)
	skeleton_timer.connect("timeout", _spawn_skeleton)
	
	# Start initial dialog
	show_intro_dialog()

func show_intro_dialog():
	dialog_player.dialogue_file = START_DIALOGUE
	interface.show_dialogue(player, dialog_player)
	var dialog = interface.dialogue_node
	dialog.dialogue_finished.connect(_on_intro_dialog_finished)
	

func _on_intro_dialog_finished():
	# Enable player movement and start skeleton spawning
	skeleton_timer.start()
	player.set_active(true)

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

func show_victory_dialog():
	dialog_player.dialogue_file = VICTORY_DIALOGUE
	interface.show_dialogue(player, dialog_player)
