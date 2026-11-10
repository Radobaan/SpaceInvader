extends Node2D

@export var enemy_scene: PackedScene

@export var spawn_interval: float = 2.0
@export var spawn_margin: float = 30.0


func _ready() -> void:
	$Timer.wait_time = spawn_interval
	$Timer.timeout.connect(spawn_enemy)
	$Timer.start()


func spawn_enemy() -> void:
	print("spawn_enemy() TERPANGGIL!")

	if enemy_scene == null:
		print("ERROR: enemy_scene masih NULL!")
		return

	# Membuat instance Enemy
	var enemy = enemy_scene.instantiate()
	var main = get_tree().current_scene
	enemy.killed.connect(
	Callable(main, "_on_enemy_killed")
)

	# Mengambil ukuran layar
	var screen_size: Vector2 = get_viewport_rect().size

	# Menentukan posisi X secara acak
	var random_x: float = randf_range(
		spawn_margin,
		screen_size.x - spawn_margin
	)

	# Memasukkan Enemy ke container Enemies
	get_parent().get_node("Enemies").add_child(enemy)

	# Menentukan posisi spawn
	enemy.global_position = Vector2(random_x, -50.0)
