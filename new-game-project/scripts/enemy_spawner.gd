extends Node2D

@export var enemy_scene: PackedScene

#mengatur jarak pixel antar unit/entitas musuh + waktu interval spawn
@export var spawn_interval: float = 2.0
@export var spawn_margin: float = 30.0

# Progressive Difficulty configuration
#sbg variable divider utk menaikkan difficulty ke stage selanjutnya
@export var difficulty_step_seconds: float = 10.0
#variable yg mengatur stat musuh
@export var base_enemy_speed: float = 150.0
@export var enemy_speed_increase: float = 30.0
@export var max_enemy_speed: float = 3000.0

#multiplier utk mengurangi waktu jeda spawn tiap musuh
@export var spawn_interval_decrease: float = 0.5
#batas minimum jeda spawn supaya spawn interval tidak terlalu kecil
@export var min_spawn_interval: float = 0.0

# Runtime variables
var elapsed_time: float = 0.0
#fase tingkat kesulitan berdasarkan waktu yg telah berlalu pada saat ini
var difficulty_level: int = 0
#speed musuh skrg
var current_enemy_speed: float = 150.0
#interval atau jeda spawn musuh saat ini
var current_spawn_interval: float = 2.0

func _ready() -> void:
	current_enemy_speed = base_enemy_speed
	current_spawn_interval = spawn_interval
	
	$Timer.wait_time = current_spawn_interval
	print("Difficulty Level: ", difficulty_level)
	print("Enemy Speed: ", current_enemy_speed)
	print("Spawn Interval: ", current_spawn_interval)
	$Timer.timeout.connect(spawn_enemy)
	$Timer.start()

func _process(delta: float) -> void:
	elapsed_time += delta
	update_difficulty()

	
func update_difficulty() -> void:
# Menghitung difficulty berdasarkan waktu bermain.
	var new_level: int = int(elapsed_time / difficulty_step_seconds)
	
	#jika perhitungan waktu berlalu dibagi dengan diff spike/sconds == level skrg-> ga usah ngapa-ngapain LOL
	if difficulty_level == new_level:
		return
	else:
		#naikkan level skrg berdasarkan perhitungan waktu berlalu/diff spike per sconds
		difficulty_level = new_level
		print("difficulty level naik jadi: ", difficulty_level)

	# Menghitung kecepatan Enemy terbaru
	# minf utk mencari nilai terkecil di antara dua angka bertipe float
	# minf dilakukan supaya kenaikan speed musuh nggak melebihi masx_enemy_speed
	current_enemy_speed = minf(
		base_enemy_speed + difficulty_level * enemy_speed_increase,
		max_enemy_speed
	)

	# Menghitung spawn interval terbaru
	current_spawn_interval = maxf(
		spawn_interval - difficulty_level * spawn_interval_decrease,
		min_spawn_interval
	)
	print("Elapsed Time ", elapsed_time)
	print("Spawn Interval ", current_spawn_interval)
	print("Enemy Speed ", current_enemy_speed)

func spawn_enemy() -> void:
	#print("spawn_enemy() TERPANGGIL!")

	# safety check supaya isi enemy_scene tidak kosong
	if enemy_scene == null:
		print("ERROR: enemy_scene masih NULL!")
		return

	# Membuat instance Enemy
	var enemy = enemy_scene.instantiate()
	
	# Memasukkan node teratas/root dari scene yang sedang aktif di layar
	var main = get_tree().current_scene
	# Saat sinyal killed milik enemy berbunyi/emit, jalankan func _on_enemy_killed yang ada di main.gd
	enemy.killed.connect(
	Callable(main, "_on_enemy_killed")
)

	# Memberikan kecepatan sesuai difficulty saat ini.
	enemy.speed = current_enemy_speed

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
