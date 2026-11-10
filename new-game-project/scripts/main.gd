extends Node2D

var score: int = 0

@onready var score_label = $HUD/Score
@onready var player = $Player
@onready var game_over_overlay = $HUD/GameoverOverlay


func _ready() -> void:
	game_over_overlay.hide()
	score_label.text = "SCORE: %d" % score
	player.game_over_triggered.connect(_on_player_game_over)

func _on_enemy_killed() -> void:
	score += 100

	score_label.text = "SCORE: %d" % score

	print("Score: ", score)

func _on_player_game_over() -> void:
	print("Main: Game Over Screen ditampilkan!")

	# Tampilkan layar Game Over.
	game_over_overlay.show()

	# Hentikan EnemySpawner.
	$EnemySpawner/Timer.stop()

	# Hentikan Player Auto Shoot.
	$Player/shootCooldown.stop()

	# Hentikan seluruh gameplay.
	get_tree().paused = true
