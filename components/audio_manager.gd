extends Node

# La música!!
#Gp
@onready var mx_gp_space_intro: AudioStreamPlayer = $Mx/Mx_GpSpace_Intro
@onready var mx_gp_space_base_l: AudioStreamPlayer = $Mx/Mx_GpSpace_Base_L
@onready var mx_gp_space_synth_1_l: AudioStreamPlayer = $Mx/Mx_GpSpace_Synth1_L
@onready var mx_gp_space_synth_2_l: AudioStreamPlayer = $Mx/Mx_GpSpace_Synth2_L
@onready var mx_gp_space_base_release: AudioStreamPlayer = $Mx/Mx_GpSpace_Base_Release
@onready var mx_gp_space_synth_1_release: AudioStreamPlayer = $Mx/Mx_GpSpace_Synth1_Release
@onready var mx_gp_space_synth_2_release: AudioStreamPlayer = $Mx/Mx_GpSpace_Synth2_Release

@onready var music_stinger: AudioStreamPlayer = $Mx/Stinger
#Win-Lose
@onready var music_win : AudioStreamPlayer = $Mx/WinSpace
@onready var music_lose : AudioStreamPlayer = $Mx/LoseSpace

# ---------------SFX!!-------------
#radar
@onready var sfx_radar: AudioStreamPlayer = $Sfx/SfxRadar
@onready var sfx_radar_fin: AudioStreamPlayer = $Sfx/SfxRadarFin
#lowFuel
@onready var sfx_low_fuel: AudioStreamPlayer = $Sfx/SfxLowFuel
#Hit
@onready var sfx_hit_boton: AudioStreamPlayer = $Sfx/Hit/SfxHitBoton
@onready var sfx_hit_crash_layer: AudioStreamPlayer = $Sfx/Hit/SfxHitCrashLayer
@onready var sfx_hit_glitch: Array[AudioStreamPlayer] = [
	$Sfx/Hit/SfxHitGlitch001,
	$Sfx/Hit/SfxHitGlitch002,
	$Sfx/Hit/SfxHitGlitch003,
	$Sfx/Hit/SfxHitGlitch004
]
#Nave
@onready var sfx_nave: AudioStreamPlayer = $Sfx/SfxNave

#var nave
var bus_nave_idx: int
var hp_filter: AudioEffectHighPassFilter
var lp_filter: AudioEffectLowPassFilter
var lp_filter_2: AudioEffectLowPassFilter
var tremolo_phase: float = 0.0
#--------
var initialized: bool = false
var loop_count: int = 0
var music_playing: bool = false
const MAX_FUEL: float = 200.0

# --- Variables Facu---
var distance_from_objective : float
var radar_distance_threshold : float = 150
var radar_playing : bool = false
var player_speed : float
var distance_from_meteor : float
var direction_to_meteor : Vector2
var direction_to_objective : Vector2
var lanafta : float
var objectives_left : int
var player_is_accelerating : bool
var player_is_braking : bool


#----------------------------------------------------------------------
func _ready() -> void:
	if not initialized:
		initialized = true
	bus_nave_idx = AudioServer.get_bus_index("Nave")
	hp_filter = AudioServer.get_bus_effect(bus_nave_idx, 0)
	lp_filter = AudioServer.get_bus_effect(bus_nave_idx, 1)
	lp_filter_2 = AudioServer.get_bus_effect(bus_nave_idx, 2)

func reset():
	music_playing = false
	loop_count = 0
	
	# Parar todo
	mx_gp_space_intro.stop()
	mx_gp_space_base_l.stop()
	mx_gp_space_synth_1_l.stop()
	mx_gp_space_synth_2_l.stop()
	mx_gp_space_base_release.stop()
	mx_gp_space_synth_1_release.stop()
	mx_gp_space_synth_2_release.stop()
	music_win.stop()
	music_lose.stop()
	sfx_radar.stop()
	
	# Resetear estados
	radar_playing = false
	
	# Reset Vol
	mx_gp_space_synth_1_l.volume_db = 0.0
	mx_gp_space_synth_2_l.volume_db = 0.0
	mx_gp_space_synth_1_release.volume_db = 0.0
	mx_gp_space_synth_2_release.volume_db = 0.0
	sfx_low_fuel.volume_db = -80.0
	sfx_low_fuel.play()
	
	#Reset Nave
	sfx_nave.stop()
	sfx_nave.play()
	
	start_level_sound()

func start_level_sound():
	music_playing = true
	mx_gp_space_intro.play()
	await mx_gp_space_intro.finished
	if music_playing:
		_play_loop()

func _play_loop():
	mx_gp_space_base_l.play()
	mx_gp_space_synth_1_l.play()
	mx_gp_space_synth_2_l.play()
	await mx_gp_space_base_l.finished
	if not music_playing:
		return
	loop_count += 1
	if loop_count == 1:
		mx_gp_space_base_release.play()
		mx_gp_space_synth_1_release.play()
		mx_gp_space_synth_2_release.play()
	_play_loop()

#----------------------------------------------------------------------

func _process(delta: float) -> void:
	check_radar_distance()
	update_radar_rtpc()
	update_nafta()
	update_nave(delta)

func check_radar_distance():
	if distance_from_objective <= radar_distance_threshold and not radar_playing:
		sfx_radar.play()
		radar_playing = true

func update_radar_rtpc():
	var normalized = clamp(distance_from_objective / radar_distance_threshold, 0.0, 1.0)
	var inverted = 1.0 - normalized
	sfx_radar.volume_db = linear_to_db(inverted)

func update_nafta():
	# Low fuel sube desde mitad de nafta
	var fuel_normalized = clamp(remap(lanafta, MAX_FUEL * 0.5, 0.0, 0.0, 1.0), 0.0, 1.0)
	sfx_low_fuel.volume_db = linear_to_db(fuel_normalized)
	
	# Mezcla vertical synth1 y synth2
	var mix_normalized = clamp(lanafta / MAX_FUEL, 0.0, 1.0)
	var target_db = lerp(-80.0, 0.0, mix_normalized)
	mx_gp_space_synth_1_l.volume_db = target_db
	mx_gp_space_synth_2_l.volume_db = target_db
	mx_gp_space_synth_1_release.volume_db = target_db
	mx_gp_space_synth_2_release.volume_db = target_db

#----------------------------------------------------------------------

func objective_reached():
	sfx_radar.stop()
	sfx_radar_fin.play()
	radar_playing = false
	print("Objective reached")

func meteor_hit():
	sfx_hit_boton.play()
	sfx_hit_crash_layer.play()
	sfx_hit_glitch[randi_range(0, 3)].play()
	print("Meteor hit")
	
#Func Nave _____________________________________________ 
func update_nave(delta: float) -> void:
	update_nave_filters()
	update_nave_tremolo(delta)

func update_nave_filters() -> void:
	# LP: 10hz en reposo, 1500hz a maxima velocidad
	lp_filter.cutoff_hz = remap(player_speed, 0.0, 512.0, 10.0, 1000.0)
	lp_filter.resonance = remap(player_speed, 0.0, 512.0, 1 , 2.0)
	# HP: 10hz en reposo, 200hz a maxima velocidad
	hp_filter.cutoff_hz = remap(player_speed, 0.0, 512.0, 10.0, 100.0)
	#LP2
	lp_filter_2.cutoff_hz = remap(player_speed, 0.0, 512.0, 10.0, 1000.0)
	lp_filter_2.resonance = remap(player_speed, 0.0, 512.0, 0.5, 2.0)
	
func update_nave_tremolo(delta: float) -> void:
	# Frec del tremolo
	var tremolo_freq: float
	if player_speed <= 450.0:
		tremolo_freq = remap(player_speed, 0.0, 450.0, 1.5, 3.7)
	else:
		tremolo_freq = remap(player_speed, 450.0, 512.0, 3.7, 26.0)
	
	# Depth 
	var tremolo_depth = remap(player_speed, 0.0, 512.0, 0.1, 0.8)
	
	tremolo_phase += delta * tremolo_freq * TAU
	if tremolo_phase > TAU:
		tremolo_phase -= TAU
	
	# Tremolo 
	var tremolo_value = (sin(tremolo_phase) * 0.5 + 0.5) * tremolo_depth
	sfx_nave.volume_db = linear_to_db(1.0 - tremolo_value)
	
	AudioServer.set_bus_volume_db(bus_nave_idx, remap(player_speed, 0.0, 512.0, -80.0, 0.0))
	
#_______________________________________________________

func died():
	music_playing = false
	var tween = create_tween()
	tween.tween_property(mx_gp_space_base_l, "volume_db", -80.0, 0.3)
	tween.parallel().tween_property(mx_gp_space_synth_1_l, "volume_db", -80.0, 0.3)
	tween.parallel().tween_property(mx_gp_space_synth_2_l, "volume_db", -80.0, 0.3)
	tween.parallel().tween_property(mx_gp_space_base_release, "volume_db", -80.0, 0.3)
	tween.parallel().tween_property(mx_gp_space_synth_1_release, "volume_db", -80.0, 0.3)
	tween.parallel().tween_property(mx_gp_space_synth_2_release, "volume_db", -80.0, 0.3)
	await tween.finished
	mx_gp_space_intro.stop()
	mx_gp_space_base_l.stop()
	mx_gp_space_synth_1_l.stop()
	mx_gp_space_synth_2_l.stop()
	mx_gp_space_base_release.stop()
	mx_gp_space_synth_1_release.stop()
	mx_gp_space_synth_2_release.stop()
	sfx_radar.stop()
	sfx_low_fuel.stop()
	music_lose.play()
	print("Died")

func win():
	music_playing = false
	mx_gp_space_intro.stop()
	mx_gp_space_base_l.stop()
	mx_gp_space_synth_1_l.stop()
	mx_gp_space_synth_2_l.stop()
	mx_gp_space_base_release.stop()
	mx_gp_space_synth_1_release.stop()
	mx_gp_space_synth_2_release.stop()
	sfx_radar.stop()
	sfx_low_fuel.stop()
	music_stinger.play()
	await music_stinger.finished
	music_win.play()
	print("Win")

func paused():
	var tween = create_tween()
	tween.tween_property(mx_gp_space_base_l, "volume_db", -80.0, 0.3)
	tween.parallel().tween_property(mx_gp_space_synth_1_l, "volume_db", -80.0, 0.3)
	tween.parallel().tween_property(mx_gp_space_synth_2_l, "volume_db", -80.0, 0.3)
	tween.parallel().tween_property(mx_gp_space_base_release, "volume_db", -80.0, 0.3)
	sfx_radar.volume_db = -80.0
	print("Paused")

func unpaused():
	var tween = create_tween()
	tween.tween_property(mx_gp_space_base_l, "volume_db", 0.0, 0.3)
	tween.parallel().tween_property(mx_gp_space_synth_1_l, "volume_db", 0.0, 0.3)
	tween.parallel().tween_property(mx_gp_space_synth_2_l, "volume_db", 0.0, 0.3)
	tween.parallel().tween_property(mx_gp_space_base_release, "volume_db", 0.0, 0.3)
	print("Unpaused")






#var music_playing := false
#var distance_from_objective : float 
#var radar_distance_threshold : float = 500
#var radar_playing : bool = false
#var bank_loaded := false  # Ya no necesita ser static
#var player_speed : float
#var lanafta : float
#
#func _ready() -> void:
	#if not bank_loaded:
		#Wwise.register_game_obj(self, "AudioManager")
		#Wwise.load_bank("Main")
		#Wwise.add_default_listener(self)
		#bank_loaded = true
	#
	#Wwise.set_state("pausa", "pausa_off")
	#radar_playing = false
	#Wwise.post_event("Stop_Mx_Sw", self)
	#Wwise.post_event("Stop_Sfx_Nave", self)
	#Wwise.post_event("Play_Sfx_Radar_Fin", self)
	#start_level_sound()
#
#func start_level_sound():
	#
	#Wwise.set_state("Mx_Musica", "GamePlay")
	#Wwise.post_event("Play_Mx_Sw", self)
	#Wwise.post_event("Play_Sfx_Nave", self)
		#
		#
#
#func reset():
	#radar_playing = false
	#Wwise.post_event("Stop_Mx_Sw", self)
	#Wwise.post_event("Stop_Sfx_Nave", self)
	#Wwise.post_event("Play_Sfx_Radar_Fin", self)
	#start_level_sound()
#
#func _process(_delta: float) -> void:
	#check_radar_distance()
	#update_radar_rtpc()
	#update_nave_rtpc()
	#update_nafta()
	#
	#
	#
	#
#func check_radar_distance():
	#if distance_from_objective <= radar_distance_threshold and not radar_playing:
		#Wwise.post_event("Play_Sfx_Radar", self)
		#radar_playing = true
#
#func update_radar_rtpc():
	#var max_distance = radar_distance_threshold
	#var normalized = clamp(distance_from_objective / max_distance, 0.0, 1.0)
	#var inverted = 1.0 - normalized
	#var rtpc_value = inverted * 100.0
	#Wwise.set_rtpc_value("Sfx_Radar_Vol", rtpc_value, self)
#
#func update_nave_rtpc():
	#Wwise.set_rtpc_value("Sfx_Nave", player_speed, self)
	#
#func update_nafta():
	#Wwise.set_rtpc_value("Mx_Vidas", lanafta, self)
	#pass
#
#
##----------------------------------------------------------------------
#
## hola maxi, aca te dejo unas variables que se me ocurrieron para el juego,
## no hace falta que uses todas obvio, pero te queria dar unas cuantas opciones
## para que juegues con lo que se te vaya ocurriendo
## cualquier cosa mandame un mensaje!
#
## velocidad actual del jugador
##var player_speed : float
#
## distancia y direccion al meteorito mas cerca del jugador
#var distance_from_meteor : float # distancia en metros hacia el meteoro mas cercano
#var direction_to_meteor : Vector2 # un vector normalizado apuntando desde el jugador hacia el meteorito mas cercano
#
## lo mismo que arriba pero con los objetivos
## distancia y direccion al objetivo mas cerca del jugador
##var distance_from_objective : float # distancia en metros hacia el objetivo mas cercano
#var direction_to_objective : Vector2 # un vector normalizado apuntando desde el jugador hacia el objetivo mas cercano
#
## cuantos objetivos le faltan al jugador
## por ahora hay 3 objetivos que el jugador debe encontrar,
## el numero se puede cambiar facilmente cualquier cosa
#var objectives_left : int
#
## estos booleanos se activan si el jugador esta apretando el acelerador o freno
#var player_is_accelerating : bool
#var player_is_braking : bool
#
##-----------------------------------------------------------------------------------
##funciones se llaman cuando pasa algo en especifico, nombres autoexplicativos
#func objective_reached():
	#Wwise.post_event("Play_Sfx_Radar_Fin", self)
	#radar_playing = false
	#print("Objective reached")
#
#func meteor_hit():
	#Wwise.post_event("Play_Sfx_Hit", self)
	#print("Meteor hit")
#
#func died():
	#Wwise.set_state("Mx_Musica", "Lose")
	#Wwise.post_event("Play_Sfx_Radar_Fin", self)
	#Wwise.post_event("Stop_Sfx_Nave", self)
	#print("Died")
#
#func win():
	#Wwise.set_state("Mx_Musica", "Win")
	#Wwise.post_event("Play_Sfx_Radar_Fin", self)
	#Wwise.post_event("Stop_Sfx_Nave", self)
	#print("Win")
#
#func paused():
	#Wwise.set_state("pausa", "pausa_on")
	#Wwise.post_event("Play_Sfx_Radar_Fin", self)
	#Wwise.set_rtpc_value("Sfx_Nave", 0, self)
	#print("Paused")
#
#func unpaused():
	#Wwise.set_state("pausa", "pausa_off")
	#Wwise.post_event("Play_Sfx_Radar", self)
	#
	#print("Unpaused")
