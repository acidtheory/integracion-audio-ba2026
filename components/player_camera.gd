extends Camera2D



@onready var player: Player = $".."
@export var noise : FastNoiseLite

func _process(_delta: float) -> void:
	zoom = Vector2(1,1) * remap(player.speed,0,player.MAX_SPEED,1,0.75)
	var pos : Vector2 = player.global_position
	
	offset = Vector2(noise.get_noise_2d(pos.x,pos.y),noise.get_noise_2d(pos.y,pos.x)) * remap(player.speed,0,player.MAX_SPEED,0,3)
