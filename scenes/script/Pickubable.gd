extends Interactable

@export var item: Node3D 

func _ready():
	# If the item is not manually assigned in the Inspector, default to $".."
	if item == null:
		item = $"."


func interact(body):
	var check = Inventory.add_to_state(prompt_message, 1)  # Pass item.name as the key
	if check:  # If inventory is not full
		item.queue_free()


func _on_interacted(body):
	var check = Inventory.add_to_state(prompt_message, 1)  # Pass item.name as the key
	if check:  # If inventory is not full
		item.queue_free()
