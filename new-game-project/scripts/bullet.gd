
extends Area2D

@export var speed: float = 200.0
@export var damage: int = 1

var ammo_type: String = "normal"


func _ready() -> void:

	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	global_position.y -= speed * delta
	# Hapus peluru jika sudah keluar layar.
	if global_position.y < -50:
		queue_free()


func set_ammo_type(type: String) -> void:
	ammo_type = type


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		if area.has_method("take_damage"):
			area.take_damage(damage)

		queue_free()
