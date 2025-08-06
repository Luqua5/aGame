extends Node3D

@export var point_a: Vector3
@export var point_b: Vector3
@export var point_c: Vector3
@export var drive_duration := 3.0
@export var wheels: Array[Node3D]
@export var wheel_spin_speed := 5.0
@export var door_left: Node3D
@export var door_right: Node3D

var driving := false
var timer := 0.0
var start: Vector3
var end: Vector3
var door_open := false
var door_working := false
var left_open_angle := deg_to_rad(0)
var right_open_angle := deg_to_rad(179)
var door_close_angle := deg_to_rad(89.3)
var door_speed := 1.5 

signal bus_arrived


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if driving:
		timer += delta
		var t: float = clamp(timer / drive_duration, 0.0, 1.0)
		global_transform.origin = start.lerp(end, t)

		# Faire tourner les roues
		for wheel in wheels:
			wheel.rotate_x(wheel_spin_speed * delta)

		if t >= 1.0:
			driving = false
			timer = 0.0

	if door_working:
		var left_y = door_left.rotation.y
		var right_y = door_right.rotation.y

		if door_open:
			# Ouverture
			if left_y > left_open_angle:
				door_left.rotate_y(-door_speed * delta)
			if right_y < right_open_angle:
				door_right.rotate_y(door_speed * delta)

			# Fin d'ouverture
			if left_y <= left_open_angle and right_y >= right_open_angle:
				door_working = false

		else:
			# Fermeture
			if left_y < door_close_angle:
				door_left.rotate_y(door_speed * delta)
			if right_y > door_close_angle:
				door_right.rotate_y(-door_speed * delta)

			# Fin de fermeture
			if left_y >= door_close_angle and right_y <= door_close_angle:
				door_working = false

func start_drive_a_b():
	driving = true
	timer = 0.0
	start = point_a
	end = point_b
	
func start_drive_b_c():
	driving = true
	timer = 0.0
	start = point_b
	end = point_c
	
func open_close_door():
	if(!door_open):
		bus_arrived.emit()
	door_open = !door_open
	door_working = true
	$door_sound.play()
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_P:
			print("P pressé, je tente de jouer le son")
			$bus_sound.play()

func reset():
	print('bus')
	start_drive_a_b()
	await get_tree().create_timer(10.0).timeout
	open_close_door()
	await get_tree().create_timer(4.0).timeout
	open_close_door()
	start_drive_b_c()
	await get_tree().create_timer(10.0).timeout
	global_transform.origin = $"../busMarkerWait".global_transform.origin


func start_bus():
	reset()
