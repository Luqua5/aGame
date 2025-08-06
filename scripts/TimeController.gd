extends Node

@onready var sun : DirectionalLight3D = $"../SubViewportContainer/SubViewport/Sun"
@onready var env : WorldEnvironment = $"../SubViewportContainer/SubViewport/WorldEnvironment"
var current_step := 0
@export var max_steps: int = 5
@export var sun_color_gradient: Gradient = Gradient.new()
@export var ambient_gradient: Gradient   = Gradient.new()
var env_res : Environment

func _ready() -> void:
	env_res = env.environment
	update_time(0)

func next_step():
	current_step = clamp(current_step + 1, 0, max_steps)
	var t = float(current_step) / max_steps
	update_time(t)
	
func update_time(t):
	#explication : lerp fait interpoler une valeur entre son min à son max
	#lerp(min, max, 0.5) = min+max/2
	#lerp(min, max, 0.5) = min
	#sample(t) t doit etre entre 1 et 0, ça renvoit une couleur précise sur un gradient
	#0.5 sera la couleur au milieu du gadient, 0 sera le sebut et 1 la fin
	# 1) On oriente le soleil (DirectionalLight3D)
	var angle_deg = lerp(20.0, 110.0, t)
	sun.rotation_degrees.x = angle_deg

	# 2) On met à jour sa couleur et sa puissance
	sun.light_color  = sun_color_gradient.sample(t)
	sun.light_energy = lerp(1.5, 0.2, t)

	# 3) On ajuste la lumière ambiante
	env_res.ambient_light_color   = ambient_gradient.sample(t)
	env_res.ambient_light_energy  = lerp(0.8, 0.3, t)

	# 4) On récupère la ressource Sky et son material
	if env_res.background_mode == Environment.BG_SKY and env_res.sky is Sky:
		var sky_res : Sky = env_res.sky as Sky            # :contentReference[oaicite:0]{index=0}
		var mat = sky_res.sky_material as ProceduralSkyMaterial  # :contentReference[oaicite:1]{index=1}
		# Exemple : on fait varier le dégradé du ciel
		mat.sky_horizon_color = sun_color_gradient.sample(t)
		mat.sky_top_color     = ambient_gradient.sample(t)  # ou un autre gradient
