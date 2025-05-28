extends Control

@onready var progress_bar = $ProgressBar

func _ready():
    # Connect to player's signals
    var player = get_tree().get_first_node_in_group("player")
    if player:
        player.damaged.connect(_on_player_damaged)

func _on_player_damaged(current_health: float, max_health: float):
    # Update progress bar value
    progress_bar.value = (current_health / max_health) * 100