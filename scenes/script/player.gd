extends CharacterBody3D

@export var speed: float = 10.0
@export var sprint_speed: float = 15.0
@export var crouch_speed: float = 5.0
@export var acceleration: float = 5.0
@export var gravity: float = 9.8
@export var jump_power: float = 5.0
@export var mouse_sensitivity: float = 0.3
@export var sprint_double_tap_time: float = 0.3
@export var fov_default: float = 75.0
@export var fov_sprint: float = 100.0
@export var fov_crouch: float = 50.0
@export var fov_smoothness: float = 5.0

var camera_x_rotation: float = 0.0
var last_forward_press_time: float = 0.0
var is_sprinting: bool = false
var is_crouching: bool = false

@onready var camera: Camera3D = $Head/Camera3D
@onready var head: Node3D = $Head

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		var x_delta = event.relative.y * mouse_sensitivity
		camera_x_rotation = clamp(camera_x_rotation + x_delta, -90.0, 90.0)
		camera.rotation_degrees.x = -camera_x_rotation

func _physics_process(delta):
	var movement_vector = Vector3.ZERO
	var target_speed = speed
	var target_fov = fov_default  

	# Handle Sprinting (Double Tap Forward)
	if Input.is_action_just_pressed("movement_forward"):
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_forward_press_time < sprint_double_tap_time:
			is_sprinting = true
		else:
			is_sprinting = false
		last_forward_press_time = current_time

	if !Input.is_action_pressed("movement_forward"):
		is_sprinting = false  

	# Handle Crouching
	if Input.is_action_pressed("Shift"):  
		is_crouching = true
		is_sprinting = false  
	else:
		is_crouching = false

	# Determine movement speed and target FOV
	if is_sprinting:
		target_speed = sprint_speed
		target_fov = fov_sprint
	elif is_crouching:
		target_speed = crouch_speed
		target_fov = fov_crouch

	# Smoothly interpolate FOV change
	camera.fov = lerp(camera.fov, target_fov, fov_smoothness * delta)

	# **CHECK EDGE BEFORE MOVING** (Prevent Falling)
	if is_crouching and check_near_edge():
		velocity.x = 0  # Stop left/right movement
		velocity.z = 0  # Stop forward/backward movement
		if not is_on_floor():
			velocity.y -= gravity * delta  # Ensure gravity applies if in air
	else:
		# Movement input
		if Input.is_action_pressed("movement_forward"):
			movement_vector -= head.basis.z
		if Input.is_action_pressed("movement_backward"):
			movement_vector += head.basis.z
		if Input.is_action_pressed("movement_left"):
			movement_vector -= head.basis.x
		if Input.is_action_pressed("movement_right"):
			movement_vector += head.basis.x

		movement_vector = movement_vector.normalized()

		velocity.x = lerp(velocity.x, movement_vector.x * target_speed, acceleration * delta)
		velocity.z = lerp(velocity.z, movement_vector.z * target_speed, acceleration * delta)

		# Apply gravity
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Jumping
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_power

	move_and_slide()

	
func spawn_item(item_name):
	var item_path = find_item_scene(item_name)
	
	if item_path != "":
		var item_scene = load(item_path)
		var item_instance = item_scene.instantiate()

		# Get player's camera node
		var camera = $Head/Camera3D  # Change this to your actual camera path

		if camera:
			# Get forward direction from the camera
			var forward = -camera.global_transform.basis.z.normalized()

			# Set item position in front of the player (adjust the distance as needed)
			item_instance.global_transform.origin = camera.global_transform.origin + (forward * 2.0) + Vector3(0, -0.5, 0)

			# Add item to the scene
			get_parent().add_child(item_instance)
		else:
			print("Error: Camera3D not found!")
	else:
		print("Error: Could not find item:", item_name)


func find_item_scene(item_name) -> String:
	var base_path = "res://scenes/3D Assets/Object/"
	var directories = get_directories_recursive(base_path)

	for dir in directories:
		var item_path = dir + "/" + item_name + ".tscn"
		if ResourceLoader.exists(item_path):
			return item_path  # Found the item, return path

	print("Item not found:", item_name)
	return ""  # Return empty string if not found

func get_directories_recursive(path: String) -> Array:
	var dir = DirAccess.open(path)
	var directories = [path]  # Start with the base path

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			var full_path = path + file_name
			if dir.current_is_dir():
				directories.append_array(get_directories_recursive(full_path))  # Recursive call
			file_name = dir.get_next()

		dir.list_dir_end()
	else:
		print("Error: Could not open directory", path)

	return directories


func check_near_edge() -> bool:
	# Cast a ray slightly in front to check if there’s ground ahead
	var space_state = get_world_3d().direct_space_state
	
	# Define ray starting position (player's feet)
	var start_pos = global_transform.origin + Vector3(0, -1, 0)  

	# Check in four directions: Forward, Backward, Left, Right
	var directions = [
		head.global_transform.basis.z.normalized() * -1.0,  # Forward
		head.global_transform.basis.z.normalized(),        # Backward
		head.global_transform.basis.x.normalized() * -1.0, # Left
		head.global_transform.basis.x.normalized()         # Right
	]
	
	for direction in directions:
		var end_pos = start_pos + (direction * 0.7) + Vector3(0, -1, 0)
		var query = PhysicsRayQueryParameters3D.create(start_pos, end_pos)
		query.collide_with_areas = false
		query.collide_with_bodies = true

		var result = space_state.intersect_ray(query)
		
		# If ray **doesn't hit** anything, there's no ground = **Near an edge**
		if result.is_empty():
			return true
	
	return false  # Player is safe
