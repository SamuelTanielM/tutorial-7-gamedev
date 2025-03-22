extends Control  # Ensure it's a UI node like Control or Panel

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Show cursor when win screen loads
