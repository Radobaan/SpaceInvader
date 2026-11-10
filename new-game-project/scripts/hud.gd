extends CanvasLayer

@onready var player = get_parent().get_node("Player")
@onready var hearts_container = $Hearts


func _ready() -> void:
	player.lives_changed.connect(_on_lives_changed)

	# Tampilkan jumlah nyawa awal.
	_on_lives_changed(player.lives)


func _on_lives_changed(current_lives: int) -> void:
	for i in range(hearts_container.get_child_count()):
		hearts_container.get_child(i).visible = i < current_lives
