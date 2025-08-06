extends Node3D

@export var path_points: Array[Node3D]
@export var walk_speed := 1.5
var current_point := 0
var walking := false
var crouch := false
var discuss := false
@export var sad := false
@export var old := false

@export var bus_path: NodePath
var bus: Node3D
var bus_offset: Vector3
var following_bus := true

var player: Node3D
var distance_interaction = 3
var camera: Node3D
@export var resource: DialogueResource

var walk_animation_name : StringName = "walk"
var idle_animation_name : StringName = "idle"

@onready var head := $Skeleton3D/BoneAttachment3D/Head
@onready var skeleton := $Skeleton3D

signal dialogue_started

var start := false

var camera_original_transform : Transform3D

@onready var spawnPNJ := $"../bus/spawnPNJ"



#var playback : AnimationNodeStateMachinePlayback
#$AnimationTree.set("parameters/playback/travel", "Idle")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#resource = load("res://dialogues/dialogue.dialogue")
	bus = get_node(bus_path)
	bus.bus_arrived.connect(on_bus_arrived)
	player = get_tree().get_nodes_in_group("Player")[0]
	camera = get_tree().get_nodes_in_group("Camera")[0]
	DialogueManager.dialogue_ended.connect(on_dialogue_ended)
	$AnimationTree.active = true
	#playback = $AnimationTree.get("parameters/playback")
	if sad:
		walk_animation_name = "sad_walk"
		idle_animation_name = "sad_idle"
	#playback.travel(idle_animation_name)
	#$AnimationPlayer.play(idle_animation_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if start :
		if following_bus:
			global_transform.origin = bus.to_global(bus_offset)
		
		if walking and current_point < path_points.size():
			var target_pos = path_points[current_point].global_transform.origin
			var to_target = target_pos - global_transform.origin
			var dist = to_target.length()
			if dist > 0.1:
				var dir = to_target.normalized()
				# Oriente sur l’axe Y vers la direction de marche
				var direction = (target_pos - global_transform.origin)
				direction.y = 0  # On ignore la différence de hauteur
				direction = direction.normalized()
				look_at(global_transform.origin + direction, Vector3.UP)
				rotate_y(PI)
				# Avance
				global_transform.origin += dir * walk_speed * delta
				# Lance la marche en boucle si pas déjà lancée
				#if $AnimationPlayer.current_animation != walk_animation_name:
					#$AnimationPlayer.play(walk_animation_name)
				#if playback.get_current_node() != walk_animation_name:
					#playback.travel(walk_animation_name)
				
			if global_transform.origin.distance_to(target_pos) < 0.1:
				current_point += 1
				if current_point == 1:
					walking = false
					discuss = true
				if current_point >= path_points.size():
					walking = false
					queue_free()
					#playback.travel(idle_animation_name)
					#$AnimationPlayer.play(idle_animation_name) #si j'amais j'ai un idle
					#$AnimationPlayer.stop()

		if discuss:
			#playback.travel(idle_animation_name)
			check_player_interaction()
				

func on_bus_arrived():
	if start :
		walking = true
		following_bus = false
		#playback.travel(walk_animation_name)
	
func check_player_interaction():
	var npc_pos = global_transform.origin
	var player_pos = player.global_transform.origin
	var to_npc = (npc_pos - player_pos).normalized()
	var forward = -player.global_transform.basis.z.normalized()
	var dist = npc_pos.distance_to(player_pos)
	var facing_dot = forward.dot(to_npc)
	if dist <= distance_interaction:
		$Interact.visible = true
		#look_at_player()
		if Input.is_action_just_pressed("interact"):
			discuss = false
			$Interact.visible = false
			camera_original_transform = camera.global_transform
			dialogue_started.emit()
			DialogueManager.show_dialogue_balloon(resource, "start")	
			var camera_player = player.get_node("Head/Camera3D")
			look_at(player.global_transform.origin,Vector3.UP)
			rotate_y(PI)
	else:
		$Interact.visible = false

func on_dialogue_ended(res: DialogueResource):
	if res == resource:
		camera.global_transform = camera_original_transform
		crouch = false
		walking = true
		$Interact.visible = false
		

func do_crouch():
	crouch = true

func look_at_player():
	var head_bone = skeleton.find_bone("mixamorig_Head")
	
	if(head_bone == -1):
		return
	
	var bone_global_pos = skeleton.get_bone_global_pose(head_bone).origin
	var player_pos = player.global_transform.origin
	
	var to_player = (player_pos - bone_global_pos).normalized()
	
	var desired_basis = Basis().looking_at(to_player, Vector3.UP)
	
	var current_transform = skeleton.get_bone_global_pose(head_bone)
	
	var blended_basis = current_transform.basis.slerp(desired_basis, 0.1)
	var new_transform = Transform3D(blended_basis, current_transform.origin)
	
	skeleton.set_bone_global_pose_override(head_bone, new_transform, 1.0, true)
	
	#pour clear l'override sur l'animation
	#$Skeleton3D.clear_bone_pose_override(head_bone)

func do_start():
	global_transform.origin = spawnPNJ.global_transform.origin
	bus_offset = bus.to_local(global_transform.origin)
	start = true
