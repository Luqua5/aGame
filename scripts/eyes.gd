extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func close_eyes():
	$AnimationPlayer.play("close")
	
func open_eyes():
	$AnimationPlayer.play("close", 0.0, -1.0, true)
