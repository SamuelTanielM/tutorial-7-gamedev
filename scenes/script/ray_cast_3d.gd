extends RayCast3D

var current_collider
@onready var prompt = $Prompt

func _ready():
	pass

func _process(delta):
	prompt.text = ""
	var collider = get_collider()

	if is_colliding() and collider is Interactable:
		prompt.text = collider.get_prompt()
		if Input.is_action_just_pressed("interact"):
			collider.interact(owner)
