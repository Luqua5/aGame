extends Node3D

var current_phase := 0
var phase_timer := 0.0
var waiting := true
var phase_durations := [5.0, 30.0, 30.0, 300.0, 300.0, 300.0] # en secondes
@export var pnj1 : Node3D
@export var pnj2 : Node3D
@export var pnj3 : Node3D
@export var pnj4 : Node3D
@export var pnj5 : Node3D
@export var pnj6 : Node3D
var pnj_list : Array

var video1 := "res://ressources/videos/video1.ogv"
var video_list: Array

@onready var main_menu := $mainMenu
@onready var start_button := $mainMenu/VBoxContainer/StartButton
@onready var quit_button := $mainMenu/VBoxContainer/QuitButton

@onready var player := $SubViewportContainer/SubViewport/Player
@onready var bus := $SubViewportContainer/SubViewport/bus

@onready var ambiance_sound:= $ambiance

var game_start := false

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if waiting && game_start:
		phase_timer += delta
		#print(phase_timer)
		#evenement aléatoire, faire passer un bus etc
		if phase_timer >= phase_durations[current_phase]:
			waiting = false
			
			start_sleep.emit()
			await get_tree().create_timer(5.0).timeout
			var tw = get_tree().create_tween()
			tw.tween_property(ambiance_sound, "volume_db", -80.0, 4)
			var new_stream = ResourceLoader.load(video_list[current_phase])
			$media/video.stream = new_stream
			$media/video.visible = true
			$media/video.play()
			await $media/video.finished
			$media/video.visible = false
			$media/video.stop()
			wake_up.emit()
			tw.tween_property(ambiance_sound, "volume_db", -23.0, 4)
			await get_tree().create_timer(5.0).timeout

			next_step()


func start_timer():
	phase_timer = 0
	current_phase += 1
	waiting = true

func on_dialogue_end(res: DialogueResource):
	start_timer()
	
func next_step():
	print("next step")
	#fonction qui réactive le bus et prépare mon pnj
	bus.reset()
	pnj_list[current_phase].do_start()
	GameState.set_current_pnj(pnj_list[current_phase])
	$TimeController.next_step()
	
	
func _on_start_pressed():
	main_menu.visible = false
	$SubViewportContainer/SubViewport/mainMenuCamera.current = false
	$SubViewportContainer/SubViewport/Player/Head/Camera3D.current = true
	player.can_move = true
	game_start = true
	pnj1.do_start()
	$TimeController.update_time(0)

func _on_quit_pressed():
	get_tree().quit()
