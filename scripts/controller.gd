class_name Controller
extends Resource

@export var speed: float = 10.0
@export var yaw_rot_speed: float = 5
@export var pitch_rot_speed: float = 2
@export var gravity: float = 9.8
@export var jump_force: float = 6

var owner: CharacterBody3D
var yaw_gyro: Node3D
var spring_arm: SpringArm3D
var jump_state: Enums.jump_state = Enums.jump_state.none

signal send_state

func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_camera(event.relative.clamp(Vector2(-1, -1), Vector2(1, 1)))

func handle_process(delta: float) -> void:
	
	# If we are using a controller, call the rotate camera for the controller rotation
	var controller_rotation := Vector2(-Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
	if (not controller_rotation.is_zero_approx()):
		rotate_camera(controller_rotation)

	handle_movement(delta)
	handle_jump(delta)


	owner.move_and_slide()

func rotate_camera(rot: Vector2) -> void:
	# rotate the gyro
	yaw_gyro.rotate_y( rot.x * yaw_rot_speed * owner.get_physics_process_delta_time() )

	# rotate the springarm
	if not (spring_arm.rotation.x >= 0 and rot.y >= 0) and not (spring_arm.rotation.x <= deg_to_rad(-90) and rot.y <= 0):
		spring_arm.rotate_x( rot.y * pitch_rot_speed * owner.get_physics_process_delta_time() )

func handle_movement(delta: float) -> void:
	if not can_handle_movement():
		return
	
	# Capture input
	var movement := Input.get_vector("left", "right", "forward", "backward") * speed
	
	# Get the direction of that movement
	var direction = (yaw_gyro.basis * Vector3(movement.x, 0, movement.y)).normalized()
	
	# Assign velocity
	if direction:
		owner.velocity.x = direction.x * speed
		owner.velocity.z = direction.z * speed
	else:
		owner.velocity.x = move_toward(owner.velocity.x, 0, speed)
		owner.velocity.z = move_toward(owner.velocity.z, 0, speed)

	# If we are moving, do movement things
	if not movement.is_zero_approx():
		owner.rotate_y(atan2(owner.velocity.x, owner.velocity.z) - owner.global_rotation.y + PI)

func can_handle_movement() -> bool:
	if jump_state != Enums.jump_state.none:
		return false
	
	return true

func handle_jump(delta: float) -> void:
		# Apply the jump
	if Input.is_action_just_pressed("jump") and owner.is_on_floor():
		owner.velocity.y = jump_force
		jump_state = Enums.jump_state.start
		return
		
	# Add gravity, if owner is falling we must accelerate until they are on the floor
	# Put player in the falling state if they are not starting the jump
	if not owner.is_on_floor():
		owner.velocity.y -= gravity * delta
		return

	# If the owner is on the floor and their jump state is still falling then they are done
	# Falling and we should put them in a landing state aka end
	if owner.is_on_floor() and jump_state == Enums.jump_state.start:
		jump_state = Enums.jump_state.end
		return
	
	# If the owner is on the floor and the jump state is end then they are done falling
	# and we set the jump state to none
	if owner.is_on_floor() and jump_state == Enums.jump_state.end:
		jump_state = Enums.jump_state.none
		return


func perform_light_attack() -> void:
	pass
