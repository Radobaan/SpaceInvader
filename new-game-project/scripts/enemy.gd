extends Area2D
@export var maxHP: int = 3
var currentHP: int = 3

@export var speed: float = 150

signal killed



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentHP = maxHP # Replace with function body.
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(1)

		queue_free()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position.y += speed * delta
	var screenHeight = get_viewport_rect().size.y
	if global_position.y > screenHeight +50:
		queue_free()
		

func take_damage(amount: int = 1) -> void:
	currentHP -= amount

	print("Enemy HP: ", currentHP)

	if currentHP <= 0:
		die()


func die() -> void:
	killed.emit()
	queue_free()
