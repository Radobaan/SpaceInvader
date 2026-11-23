extends Node2D

var score: int = 0

@onready var score_label = $HUD/Score
@onready var player = $Player
@onready var game_over_overlay = $HUD/GameoverOverlay
@onready var restart_button: Button = $HUD/GameoverOverlay/RestartButton
@onready var main_menu_button: Button = $HUD/GameoverOverlay/MainMenuButton

func _ready() -> void:
	game_over_overlay.hide()
	score_label.text = "SCORE: %d" % score
	player.game_over_triggered.connect(_on_player_game_over)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
#tiap musuh mati, skor +=100, dan ganti teks Skor
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

func _on_restart_pressed() -> void:
	print("Restart Ditekan")
	
	#Aktifkan kembali gameplay
	get_tree().paused = false
	
	# Muat ulang Main.tscn dari awal
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	print("MainMenu Ditekan!")
	
	# Aktifkan kembali Scene Tree.
	get_tree().paused = false
	
	# Kembali ke Main Menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
