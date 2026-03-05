extends CharacterBody2D
class_name Player

const MAX_SPEED = 256*2
const ACCELERATION = 64.0*2

var expected_rotation : float = 0
var expected_speed : float = 0
var speed : float = 0
var real_rotation : float = 0

const MAX_FUEL = 256
var fuel = MAX_FUEL

@onready var indicators: Node2D = $Indicators
@export var objectives : Node2D
const OBJECTIVE_INDICATOR = preload("uid://cf6uccwvc4u3a")

@export var audio_manager : AudioManager

var died : bool = false

func _ready() -> void:
	await get_tree().process_frame
	for objective in objectives.get_children():
		var new_indicator = OBJECTIVE_INDICATOR.instantiate()
		indicators.add_child(new_indicator)

func _physics_process(delta: float) -> void:
	
	# rotacion de la nave
	if Input.is_action_pressed("ui_left"):
		expected_rotation -= delta
		fuel -= delta * 0.5	
	if Input.is_action_pressed("ui_right"):
		expected_rotation += delta
		fuel -= delta * 0.5
	real_rotation = move_toward(real_rotation,expected_rotation,delta * 2 * abs(real_rotation-expected_rotation))
	rotation = real_rotation
	
	# velocidad de la nave
	if Input.is_action_pressed("ui_up"):
		expected_speed += delta * ACCELERATION
		fuel -= delta
	elif Input.is_action_pressed("ui_down"):
		expected_speed -= delta * 2.0 * ACCELERATION
		fuel -= delta * 0.75
	else: expected_speed -= delta * 0.75 * ACCELERATION
	expected_speed = clamp(expected_speed,0,MAX_SPEED)
	speed = move_toward(speed,expected_speed, delta * 0.75 * abs(speed-expected_speed))
	velocity = Vector2(0,-1).rotated(rotation) * speed
	move_and_slide()
	#agregué esto xq no me llegaba el player speed al AudioM.
	audio_manager.player_speed = speed
	
	# medidor de combustible
	fuel -= delta
	$Meters/FuelMeter.material.set_shader_parameter("progress",remap(fuel,0,MAX_FUEL,0,1))
	if fuel <= 0 and not died:
		audio_manager.died()
		visible = false
		died = true
	
	# indicador de objetivos
	for indicator : Node2D in indicators.get_children():
		var index = indicator.get_index()
		indicator.look_at(objectives.get_child(index).position)
