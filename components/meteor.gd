extends Node2D

@onready var speed : float = randf_range(0,10)
@onready var direction : Vector2 = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
