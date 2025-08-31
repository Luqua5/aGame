extends Node3D

var current_phase := 0
var phase_timer := 0.0
var waiting := true
@export var pnj1 : Node3D
@export var pnj2 : Node3D
@export var pnj3 : Node3D
@export var pnj4 : Node3D
@export var pnj5 : Node3D
@export var pnj6 : Node3D
var pnj_list : Array

var video1 := "res://ressources/videos/video1.ogv"
var video_list: Array

# Phases du jeu correspondant aux moments de la journée
var phase_names := ["Afternoon", "Evening", "Night"]

@onready var sleep_label := $SubViewportContainer/SubViewport/sleep_canva/sleep_label
@onready var sleep_canva := $SubViewportContainer/SubViewport/sleep_canva
@onready var interact_label := $SubViewportContainer/SubViewport/interact_label  # Label pour afficher "E"

@onready var main_menu := $mainMenu
@onready var start_button := $mainMenu/VBoxContainer/StartButton
@onready var quit_button := $mainMenu/VBoxContainer/QuitButton

@onready var player := $SubViewportContainer/SubViewport/Player
@onready var bus := $SubViewportContainer/SubViewport/bus

@onready var ambiance_sound:= $ambiance

var game_start := false
var can_sleep := false  # Pour contrôler quand le joueur peut dormir

signal start_sleep
signal wake_up

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TimeController.update_time(0.9)
	player.can_move = false
	GameState.set_current_pnj(pnj1)
	DialogueManager.dialogue_ended.connect(on_dialogue_end)
	pnj_list = [pnj1, pnj2, pnj3, pnj4, pnj5, pnj6]
	video_list = [video1]
	
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Cacher les labels d'interface au début
	if interact_label:
		interact_label.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_dialogue_end(res: DialogueResource):
	# Après un dialogue, permettre au joueur de dormir
	can_sleep = true
	
func next_step():
	print("next step")
	phase_beginning()
	$TimeController.next_step()

func trigger_sleep():
	if not can_sleep:
		return
		
	print("Le joueur s'endort...")
	can_sleep = false
	start_sleep.emit()  # Le player ferme les yeux
	
	# Attendre que les yeux se ferment complètement
	await get_tree().create_timer(2.0).timeout
	
	# Fade out de l'ambiance sonore
	var tw = get_tree().create_tween()
	tw.tween_property(ambiance_sound, "volume_db", -80.0, 1.5)
	
	# Afficher le moment de la journée avec effet typewriter
	var phase_text = phase_names[current_phase]
	await _typewriter_effect(phase_text, 0.15)
	
	# Avancer à la phase suivante
	current_phase += 1
	next_step()
	
	# Réveil du joueur
	wake_up.emit()
	
	# Fade in de l'ambiance sonore
	tw = get_tree().create_tween()
	tw.tween_property(ambiance_sound, "volume_db", -23.0, 1.5)
	
	
func _on_start_pressed():
	main_menu.visible = false
	$SubViewportContainer/SubViewport/mainMenuCamera.current = false
	$SubViewportContainer/SubViewport/Player/Head/Camera3D.current = true
	player.can_move = true
	game_start = true
	phase_beginning()
	$TimeController.update_time(0.9)

func _on_quit_pressed():
	get_tree().quit()

# Fonctions pour contrôler l'indicateur d'interaction
func show_interact(message: String = "E"):
	if interact_label:
		interact_label.text = message
		interact_label.visible = true

func hide_interact():
	if interact_label:
		interact_label.visible = false

func _typewriter_effect(target_text: String, delay: float = 0.1):
	if not sleep_label:
		print("Erreur : sleep_label non trouvé !")
		return

	sleep_label.text = ""
	sleep_canva.visible = true
	sleep_label.modulate.a = 1.0
	
	for i in range(target_text.length()):
		sleep_label.text = target_text.substr(0, i + 1)
		await get_tree().create_timer(delay).timeout
	
	# Attendre un peu avant de faire disparaître
	await get_tree().create_timer(1.5).timeout

	# Faire disparaître
	var tween = get_tree().create_tween()
	tween.tween_property(sleep_label, "modulate:a", 0.0, 0.8)
	await tween.finished

	sleep_canva.visible = false

func phase_beginning():
	bus.reset()
	pnj_list[current_phase].do_start()
	GameState.set_current_pnj(pnj_list[current_phase])
