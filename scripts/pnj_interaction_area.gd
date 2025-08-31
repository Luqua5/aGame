extends Area3D

@onready var pnj_parent = get_parent()
@onready var main_scene = get_node("/root/Main")
var player_in_area := false

func _ready():
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _process(_delta):
    if player_in_area and Input.is_action_just_pressed("interact"):
        print("E pressé près du PNJ !")
        if pnj_parent and pnj_parent.has_method("start_dialogue"):
            pnj_parent.start_dialogue()

func _on_body_entered(body):
    if body.name == "Player":
        player_in_area = true
        if main_scene and main_scene.has_method("show_interact"):
            main_scene.show_interact("Talk")

func _on_body_exited(body):
    if body.name == "Player":
        player_in_area = false
        if main_scene and main_scene.has_method("hide_interact"):
            main_scene.hide_interact()