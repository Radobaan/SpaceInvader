extends CharacterBody2D

# Movement
@export var speed: float = 400.0
@export var screen_margin: float = 30.0

# Shooting
@export var bullet_scene: PackedScene
@export var fire_interval: float = 1

# Player stats
@export var max_lives: int = 3
var lives: int = 3

# Ammo type
# Nilai awal: "normal"
var current_ammo_type: String = "normal"

# Temporary power-up duration
@export var powerup_duration: float = 10.0
var powerup_time_left: float = 0.0

# Panic button
@export var max_panic_charges: int = 3
var panic_charges: int = 3

var is_game_over: bool = false

signal lives_changed(current_lives: int)
signal game_over_triggered


func _ready() -> void:
	lives = max_lives
	print("Player HP: ", lives)
	panic_charges = max_panic_charges

	# Hubungkan Timer untuk auto shooting.
	$shootCooldown.wait_time = fire_interval
	$shootCooldown.timeout.connect(_on_shoot_cooldown_timeout)
	$shootCooldown.start()



func _physics_process(delta: float) -> void:
	if is_game_over:
		return

	var direction: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
        "move_down"
	)

	velocity = direction * speed
	move_and_slide()

	# Batas layar
	var screen_size := get_viewport_rect().size
	var collision_shape := $CollisionShape2D

	if collision_shape.shape is RectangleShape2D:
		var half_size: Vector2 = (
			collision_shape.shape.size
			* collision_shape.global_scale.abs()
			/ 2.0
		)

		global_position.x = clampf(
			global_position.x,
			half_size.x,
			screen_size.x - half_size.x
		)

		global_position.y = clampf(
			global_position.y,
			half_size.y,
			screen_size.y - half_size.y
		)


	# Hitung mundur durasi ammo power-up.
	if powerup_time_left > 0.0:
		powerup_time_left -= delta

		if powerup_time_left <= 0.0:
			reset_ammo_type()



func _on_shoot_cooldown_timeout() -> void:
	if is_game_over:
		return

	shoot()
	$shootCooldown.start()


func shoot() -> void:
	if bullet_scene == null:
		push_warning("Bullet Scene belum diatur di Inspector!")
		return

	var bullet = bullet_scene.instantiate()

	# Main akan menjadi parent bullet jika tersedia.
	var main = get_tree().current_scene
	var bullet_container = main.get_node_or_null("Bullets")

	if bullet_container != null:
		bullet_container.add_child(bullet)
	else:
		main.add_child(bullet)

	# Posisi awal peluru di atas player.
	bullet.global_position = global_position + Vector2(0, -30)

	# Beri tahu peluru jenis ammo yang sedang aktif.
	if bullet.has_method("set_ammo_type"):
		bullet.set_ammo_type(current_ammo_type)


func take_damage(amount: int = 1) -> void:
	if is_game_over:
		return

	lives = maxi(lives - amount, 0)
	print("Lives: ", lives)

	lives_changed.emit(lives)

	if lives <= 0:
		game_over()


func add_panic_charge(amount: int = 1) -> void:
	panic_charges = mini(
		panic_charges + amount,
		max_panic_charges
	)
	print("Panic charges: ", panic_charges)


func use_panic_button() -> void:
	if is_game_over or panic_charges <= 0:
		return

	panic_charges -= 1
	print("Panic activated! Remaining: ", panic_charges)

	# Penghapusan seluruh musuh akan ditangani Main.
	var main = get_tree().current_scene

	if main.has_method("wipe_all_enemies"):
		main.wipe_all_enemies()


func activate_ammo_powerup(ammo_type: String) -> void:
	current_ammo_type = ammo_type
	powerup_time_left = powerup_duration

	print("Ammo power-up: ", current_ammo_type)


func reset_ammo_type() -> void:
	current_ammo_type = "normal"
	powerup_time_left = 0.0
	print("Ammo kembali normal.")


func game_over() -> void:
	is_game_over = true
	$shootCooldown.stop()
	velocity = Vector2.ZERO
	game_over_triggered.emit()
	print("GAME OVER")
