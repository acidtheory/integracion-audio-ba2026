extends Node
class_name AudioManager

var music_playing := false
var distance_from_objective : float 
var radar_distance_threshold : float = 150
var radar_playing : bool = false

#var player_speed : float


#----------------------------------------------------------------------
func _ready() -> void:
	Wwise.register_game_obj(self, "AudioManager")
	Wwise.load_bank("Main")
	Wwise.add_default_listener(self)
	Wwise.set_state("pausa", "pausa_off")
	start_level_music()
	#Wwise.post_event("Play_Sfx_Nave", self)
	
	#esto stopea xq lo disparo con evento... 
	
	#Wwise.set_state("Player_Life", "PL_03")

func start_level_music():
	if music_playing:
		Wwise.set_state("Mx_Musica", "GamePlay")
		
	else: 
		Wwise.set_state("Mx_Musica", "GamePlay")
		Wwise.post_event("Play_Mx_Sw", self)
		music_playing = true
#		Wwise.set_rtpc_value("Vol_Mx", 100, self)
#		Wwise.set_rtpc_value("Vol_Sfx", 50, self)
		
		


func _process(_delta: float) -> void:
	check_radar_distance()
	update_radar_rtpc()
	#update_nave_rtpc(player_speed)

func check_radar_distance():
	if distance_from_objective <= radar_distance_threshold and not radar_playing:
		Wwise.post_event("Play_Sfx_Radar", self)
		radar_playing = true

func update_radar_rtpc():
	var max_distance = radar_distance_threshold
	var normalized = clamp(distance_from_objective / max_distance, 0.0, 1.0)
	var inverted = 1.0 - normalized
	var rtpc_value = inverted * 100.0
	Wwise.set_rtpc_value("Sfx_Radar_Vol", rtpc_value, self)

#func update_nave_rtpc(player_speed: float):
#	Wwise.set_rtpc_value("Sfx_Engine_Speed", player_speed, self)

#func stop_music():
#	Wwise.stop_all()
#	music_playing = false

#----------------------------------------------------------------------

# hola maxi, aca te dejo unas variables que se me ocurrieron para el juego,
# no hace falta que uses todas obvio, pero te queria dar unas cuantas opciones
# para que juegues con lo que se te vaya ocurriendo
# cualquier cosa mandame un mensaje!

# velocidad actual del jugador
#var player_speed : float

# distancia y direccion al meteorito mas cerca del jugador
var distance_from_meteor : float # distancia en metros hacia el meteoro mas cercano
var direction_to_meteor : Vector2 # un vector normalizado apuntando desde el jugador hacia el meteorito mas cercano

# lo mismo que arriba pero con los objetivos
# distancia y direccion al objetivo mas cerca del jugador
#var distance_from_objective : float # distancia en metros hacia el objetivo mas cercano
var direction_to_objective : Vector2 # un vector normalizado apuntando desde el jugador hacia el objetivo mas cercano

# cuantos objetivos le faltan al jugador
# por ahora hay 3 objetivos que el jugador debe encontrar,
# el numero se puede cambiar facilmente cualquier cosa
var objectives_left : int

# estos booleanos se activan si el jugador esta apretando el acelerador o freno
var player_is_accelerating : bool
var player_is_braking : bool

#-----------------------------------------------------------------------------------
#funciones se llaman cuando pasa algo en especifico, nombres autoexplicativos
func objective_reached():
	Wwise.post_event("Play_Sfx_Radar_Fin", self)
	radar_playing = false
	print("Objective reached")

func meteor_hit():
	Wwise.post_event("Play_Sfx_Boton_001", self)
	print("Meteor hit")

func died():
	Wwise.set_state("Mx_Musica", "Lose")
	Wwise.post_event("Play_Sfx_Radar_Fin", self)
	print("Died")

func win():
	Wwise.set_state("Mx_Musica", "Win")
	Wwise.post_event("Play_Sfx_Radar_Fin", self)
	print("Win")

func paused():
	Wwise.set_state("pausa", "pausa_on")
	Wwise.post_event("Play_Sfx_Radar_Fin", self)
	print("Paused")

func unpaused():
	Wwise.set_state("pausa", "pausa_off")
	Wwise.post_event("Play_Sfx_Radar", self)
	print("Unpaused")
# me imagine que te pareceria mas comodo pausar y despausar como eventos, pero
# si lo queres como un booleano, lo podes agarrar con
# get_tree().paused
