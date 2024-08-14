class_name PlayerController
extends Controller

var yaw_gyro: Node3D
var spring_arm: SpringArm3D

func handle_input(event: InputEvent) -> void:
	# CAMERA ROTATION
	if event is InputEventMouseMotion:
		rotate_camera(event.relative.clamp(Vector2(-1, -1), Vector2(1, 1)))
		
func handle_process(delta: float) -> void:
	# Call the parent handle_process
	super.handle_process(delta)
	
	# CAMERA ROTATION
	var controller_rotation := Vector2(-Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
	if (not controller_rotation.is_zero_approx()):
		rotate_camera(controller_rotation)
	
	# MOVEMENT
	var movement = Input.get_vector("left", "right", "forward", "backward")
	var direction := (yaw_gyro.basis * Vector3(movement.x, 0, movement.y)).normalized()
	handle_movement(delta, direction)

	# JUMP
	if Input.is_action_just_pressed("jump"):
		jump_state = Enums.jump_state.start

	# LIGHT ATTACK
	if Input.is_action_just_pressed("light_attack"):
		add_next_action("light_attack")

func rotate_camera(rot: Vector2) -> void:
	# rotate the gyro
	yaw_gyro.rotate_y( rot.x * yaw_rot_speed * owner.get_physics_process_delta_time() )

	# rotate the springarm
	if not (spring_arm.rotation.x >= 0 and rot.y >= 0) and not (spring_arm.rotation.x <= deg_to_rad(-90) and rot.y <= 0):
		spring_arm.rotate_x( rot.y * pitch_rot_speed * owner.get_physics_process_delta_time() )

