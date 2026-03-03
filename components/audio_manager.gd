extends Node
class_name AudioManager

# hola maxi, aca te dejo unas variables que se me ocurrieron para el juego,
# no hace falta que uses todas obvio, pero te queria dar unas cuantas opciones
# para que juegues con lo que se te vaya ocurriendo
# cualquier cosa mandame un mensaje!

# velocidad actual del jugador
var player_speed : float

# distancia y direccion al meteorito mas cerca del jugador
var distance_from_meteor : float # distancia en metros hacia el meteoro mas cercano
var direction_to_meteor : Vector2 # un vector normalizado apuntando desde el jugador hacia el meteorito mas cercano

# lo mismo que arriba pero con los objetivos
# distancia y direccion al objetivo mas cerca del jugador
var distance_from_objective : float # distancia en metros hacia el objetivo mas cercano
var direction_to_objective : Vector2 # un vector normalizado apuntando desde el jugador hacia el objetivo mas cercano

# cuantos objetivos le faltan al jugador
# por ahora hay 3 objetivos que el jugador debe encontrar,
# el numero se puede cambiar facilmente cualquier cosa
var objectives_left : int

# estos booleanos se activan si el jugador esta apretando el acelerador o freno
var player_is_accelerating : bool
var player_is_braking : bool

#funciones se llaman cuando pasa algo en especifico, nombres autoexplicativos
func objective_reached():
	print("Objective reached")

func meteor_hit():
	print("Meteor hit")

func died():
	print("Died")

func win():
	print("Win")

func paused():
	print("Paused")

func unpaused():
	print("Unpaused")
# me imagine que te pareceria mas comodo pausar y despausar como eventos, pero
# si lo queres como un booleano, lo podes agarrar con
# get_tree().paused
