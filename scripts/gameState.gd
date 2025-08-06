extends Node

var current_pnj: Node3D

func set_current_pnj(pnj):
	current_pnj = pnj
	
func do_crouch():
	if current_pnj:
		current_pnj.set("crouch", true)
