extends Area3D

@onready var main_scene = get_node("/root/Main") # Ajustez selon le nom de votre scène
var player_in_area := false

signal player_entered_bench
signal player_exited_bench

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		print("E pressé près du banc !")
		if main_scene and main_scene.has_method("trigger_sleep"):
			main_scene.trigger_sleep()
			main_scene.hide_interact()

func _on_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		player_entered_bench.emit()
		if main_scene and main_scene.has_method("show_interact") and main_scene.can_sleep:
			main_scene.show_interact("Sleep")

func _on_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		player_exited_bench.emit()
		if main_scene and main_scene.has_method("hide_interact"):
			main_scene.hide_interact()
		print("Trop loin du banc")

func has_player() -> bool:
	return player_in_area
