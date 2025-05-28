extends Node2D

@onready var portal = $Portal
@onready var skull_portal = $SkullPortal
@onready var interface = $CanvasLayer/Interface
@onready var dialog_player = $DialoguePlayer

@export var win_state = 4
@export var skeleton_spawn_rate = 2

signal unlocked

const START_DIALOGUE = "res://dialogue/dialogue_data/start.json"
const VICTORY_DIALOGUE = "res://dialogue/dialogue_data/victory.json"

var pots_busted = 0
var player = null
var pots = null
var skeleton = preload("res://scenes/skeleton.tscn")
var already_hit = []
var skeleton_timer = null
var initial_pot_data = []


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	pots = get_tree().get_nodes_in_group("pickups")

	# Store initial pot data
	for pot in pots:
		initial_pot_data.append({
			"scene": pot.scene_file_path,
			"position": pot.global_position
		})
		pot.hit.connect(_on_pot_busted)
	
	if player != null:
		player.global_position = portal.get_spawn_pos()
		player.set_active(false)
		# Connect to player's death signal
		player.death.connect(_on_player_died)

	# Setup skeleton timer but don't start it yet
	skeleton_timer = Timer.new()
	if skeleton_spawn_rate <= 0:
		skeleton_spawn_rate = 2.0 # Default to 2 seconds if invalid
	skeleton_timer.wait_time = skeleton_spawn_rate
	skeleton_timer.one_shot = false
	add_child(skeleton_timer)
	skeleton_timer.connect("timeout", _spawn_skeleton)
	print("Skeleton timer setup with rate: ", skeleton_spawn_rate)
	
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
	print("Attempting to spawn skeleton...")
	var spawn_pos = skull_portal.get_skeleton_spawn_pos()
	print("Spawn position: ", spawn_pos)
	
	var new_skeleton = skeleton.instantiate()
	new_skeleton.global_position = spawn_pos
	add_child(new_skeleton)
	print("Skeleton spawned at: ", new_skeleton.global_position)

func unlock_exit():
	unlocked.emit()

func _on_pot_busted(pot_id):
	if pot_id not in already_hit:
		pots_busted += 1
		# print("another pot bites the dust")
		if pots_busted >= win_state:
			unlock_exit()
		already_hit.append(pot_id)

func show_victory_dialog():
	dialog_player.dialogue_file = VICTORY_DIALOGUE
	interface.show_dialogue(player, dialog_player)
	var dialogue = interface.dialogue_node
	dialogue.dialogue_finished.connect(_on_game_end)

func _on_game_end():
	get_tree().quit()


func _on_player_died():
	# Stop skeleton spawning
	skeleton_timer.stop()
	
	# Clean up existing skeletons
	for npc in get_tree().get_nodes_in_group("skeletons"):
		npc.queue_free()
	
	# Reset player position and health
	player.health = player.TOTAL_HEALTH
	player.global_position = portal.get_spawn_pos()
	
	# Restore all pots
	restore_pots()
	
	# Reset pot counters
	pots_busted = 0
	already_hit.clear()
	
	# Restart skeleton spawning
	skeleton_timer.start()

func restore_pots():
	# Remove any remaining pots
	for pot in get_tree().get_nodes_in_group("pickups"):
		pot.queue_free()
	
	# Restore all original pots
	for data in initial_pot_data:
		var pot = load(data.scene).instantiate()
		pot.global_position = data.position
		add_child(pot)
		pot.hit.connect(_on_pot_busted)
