extends Interactable

@export var light : NodePath
@export var on_by_default = true
@export var energy_when_on = 10
@export var energy_when_off = 3

@onready var light_node : Light3D = get_node(light)
@onready var Switch = $".."

var on = on_by_default

func _ready():
	light_node.light_energy = energy_when_on if on else energy_when_off

func interact(body):
	on = !on	
	if(on): 
		Switch.scale = Vector3(1,1,1)
	else:
		Switch.scale = Vector3(1,1,0.6)
	light_node.light_energy = energy_when_on if on else energy_when_off


func _on_knife_interacted(body):
	pass # Replace with function body.
