class_name Controller
extends Resource

var owner: CharacterBody3D

@export var speed: float = 10.0
@export var yaw_rot_speed: float = 5
@export var pitch_rot_speed: float = 2
@export var gravity: float = 9.8
@export var jump_force: float = 6

# State variables
@export var jump_state: Enums.jump_state = Enums.jump_state.none
@export var current_action: String = ""
@export var next_action: String = ""
@export var is_action_anim_finished = true

func handle_process(delta: float) -> void:
	#print_debug("current: {} -- next: {}".format([current_action, next_action], "{}"))
	
	handle_jump(delta)
	
	handle_action()
	owner.move_and_slide()

func handle_movement(delta: float, direction: Vector3) -> void:
	if not can_handle_movement():
		return
		
	# Assign velocity
	if direction:
		owner.velocity.x = direction.x * speed
		owner.velocity.z = direction.z * speed
	else:
		owner.velocity.x = move_toward(owner.velocity.x, 0, speed)
		owner.velocity.z = move_toward(owner.velocity.z, 0, speed)

	if not owner.is_on_floor():
		owner.velocity.y -= gravity * delta
	
	# If we are moving, do movement things
	if not direction.is_zero_approx():
		owner.rotate_y(atan2(owner.velocity.x, owner.velocity.z) - owner.global_rotation.y + PI)

func can_handle_movement() -> bool:
	if jump_state != Enums.jump_state.none:
		return false
	
	return true

func handle_jump(delta: float) -> void:
		
	# Return if we are not jumping
	if jump_state == Enums.jump_state.none:
		return
	
	# Apply the jump
	if jump_state == Enums.jump_state.start and owner.is_on_floor():
		owner.velocity.y = jump_force
		var ap : AnimationPlayer = owner.get_node("AnimationPlayer")
		owner.get_tree().create_tween().tween_property(owner, "controller:jump_state", Enums.jump_state.idle, ap.get_animation("Jump_Start").length * .9)
		return
	
	# Apply the fall
	if not owner.is_on_floor() and jump_state == Enums.jump_state.idle:
		owner.velocity.y -= gravity * delta

	# Apply the land
	if owner.is_on_floor() and jump_state == Enums.jump_state.idle:
		jump_state = Enums.jump_state.end
		return
	
	# Turn off the jump state
	if owner.is_on_floor() and jump_state == Enums.jump_state.end:
		jump_state = Enums.jump_state.none
		return

func add_next_action(action: String) -> void:
	if next_action == "":
		next_action = action

func handle_action() -> void:
	if not can_handle_action():
		return
	
	if current_action == "":
		current_action = next_action
		next_action = ""
	
	is_action_anim_finished = false

func can_handle_action() -> bool:
	if not is_action_anim_finished:
		return false
	
	if current_action == "" and next_action == "":
		return false
	return true

func _set_end_animation_variables() -> void:
	is_action_anim_finished = true
	current_action = ""
