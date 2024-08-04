class_name Controller
extends Resource

@export var speed: float = 10.0
@export var yaw_rot_speed: float = 5
@export var pitch_rot_speed: float = 2

var owner: CharacterBody3D
var yaw_gyro: Node3D
var spring_arm: SpringArm3D

func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_camera(event.relative.clamp(Vector2(-1, -1), Vector2(1, 1)))

func handle_process(delta: float) -> void:
	# Capture Input
	var movement := Input.get_vector("left", "right", "forward", "backward") * speed
	var controller_rotation := Input.get_vector("camera_pitch_down", "camera_pitch_up", "camera_yaw_left", "camera_yaw_right")
	
	# If we are using a controller, call the rotate camera for the controller rotation
	if (not controller_rotation.is_zero_approx()):
		rotate_camera(controller_rotation)

	var direction = (yaw_gyro.basis * Vector3(movement.x, 0, movement.y)).normalized()
	if direction:
		owner.velocity.x = direction.x * speed
		owner.velocity.z = direction.z * speed
	else:
		owner.velocity.x = move_toward(owner.velocity.x, 0, speed)
		owner.velocity.z = move_toward(owner.velocity.z, 0, speed)
	
	# If we are moving, do movement things
	if not movement.is_zero_approx():
		owner.rotate_y(atan2(owner.velocity.x, owner.velocity.z) - owner.global_rotation.y + PI)

	owner.move_and_slide()

func rotate_camera(rot: Vector2) -> void:
	# rotate the gyro
	yaw_gyro.rotate_y( rot.x * yaw_rot_speed * owner.get_physics_process_delta_time() )

	# rotate the springarm
	if not (spring_arm.rotation.x >= 0 and rot.y >= 0) and not (spring_arm.rotation.x <= deg_to_rad(-90) and rot.y <= 0):
		spring_arm.rotate_x( rot.y * pitch_rot_speed * owner.get_physics_process_delta_time() )
