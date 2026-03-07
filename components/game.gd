extends Node

@onready var meteors: Node2D = $Meteors
@onready var player: Player = $Player

const METEOR_LARGE = preload("uid://tdtpovc1vn35")
const METEOR_SMALL = preload("uid://bq23rs5apnv81")

const OBJECTIVES_AMOUNT = 3
const OBJECTIVE = preload("uid://7aogf4kwibk8")
@onready var objectives: Node2D = $Objectives

@onready var max_meteor_distance : float = max(get_viewport().size.x, get_viewport().size.y) * 1.5
@onready var min_meteor_spawn_distance : float = max(get_viewport().size.x, get_viewport().size.y)

@export var max_meteor_amount : float = 256

var won : bool = false

func _ready() -> void:
	#region spawn inicial
	
	#spawnea objetivos
	for i in range(OBJECTIVES_AMOUNT):
		var new_objective = OBJECTIVE.instantiate()
		objectives.add_child(new_objective)
		new_objective.global_position = player.global_position + (Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * randf_range(max_meteor_distance,max_meteor_distance*2))
	
	# spawnea meteoros
	for i in range(max_meteor_amount):
		var new_meteor : Node2D
		
		# mayor chance de meteoros chicos que grande (1 en 3)
		if randi_range(0,2) == 1:
			new_meteor = METEOR_LARGE.instantiate()
		else:
			new_meteor = METEOR_SMALL.instantiate()
		meteors.add_child(new_meteor)
		
		# cambia su posicion cerca del jugador
		new_meteor.global_position = player.global_position + (Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * randf_range(256,max_meteor_distance))
	
	#endregion

func _physics_process(_delta: float) -> void:
	
	#region meteoros
	
	# despawnea meteoro si esta muy lejos del jugador
	for meteor : Node2D in meteors.get_children():
		if meteor.global_position.distance_to(player.global_position) > max_meteor_distance:
			meteor.queue_free()
	
	#spawnea meteoros cerca del jugador
	if meteors.get_children().size() < max_meteor_amount:
		var new_meteor : Node2D
		
		# mayor chance de meteoros chicos que grande (1 en 3)
		if randi_range(0,2) == 1:
			new_meteor = METEOR_LARGE.instantiate()
		else:
			new_meteor = METEOR_SMALL.instantiate()
		meteors.add_child(new_meteor)
		
		# cambia su posicion cerca del jugador
		new_meteor.global_position = player.global_position + (Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * randf_range(min_meteor_spawn_distance,max_meteor_distance))
	
	#endregion
	
	# mover las estrellas con el jugador
	$BG/Stars.material.set_shader_parameter("offset", player.global_position)
	
	# enviar meteoro y objetivo mas cerca al audio manager:
	var distance_to_player : float = INF
	var direction_to_player : Vector2
	
	for meteor : Node2D in meteors.get_children():
		var distance = meteor.global_position.distance_to(player.position)
		if distance < distance_to_player:
			distance_to_player = distance
			direction_to_player = player.global_position.direction_to(meteor.global_position)
	player.audio_manager.distance_from_meteor = distance_to_player/10
	player.audio_manager.direction_to_meteor = direction_to_player
	
	distance_to_player = INF
	for objective : Node2D in objectives.get_children():
		var distance = objective.global_position.distance_to(player.position)
		if distance < distance_to_player:
			distance_to_player = distance
			direction_to_player = player.global_position.direction_to(objective.global_position)
	player.audio_manager.distance_from_objective = distance_to_player/10
	player.audio_manager.direction_to_objective = direction_to_player
	
	$Debug/DebugLabel.text = "Distancia a meteoro mas cercano: " + str(player.audio_manager.distance_from_meteor) + "\n" + "Distancia a objetivo mas cercano: " + str(player.audio_manager.distance_from_objective) + "\n" + "Objetivos restantes: " + str(player.audio_manager.objectives_left)

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		player.audio_manager.player_is_accelerating = true
	else:
		player.audio_manager.player_is_accelerating = false
	if Input.is_action_pressed("ui_down"):
		player.audio_manager.player_is_braking = true
	else:
		player.audio_manager.player_is_braking = false
	if objectives.get_children().is_empty() and not won:
		won = true
		player.get_node("Victoria").win()
		player.audio_manager.win()
		player.process_mode = Node.PROCESS_MODE_DISABLED
		create_tween().tween_property(player.get_node("Ship"),"modulate",Color.TRANSPARENT,0.1)
		player.get_node("Explode").emitting = true
	player.audio_manager.objectives_left = objectives.get_child_count()
