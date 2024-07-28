extends CharacterBody3D

class_name Player

@export var speed: float = 10.0
@export var yaw_rot_speed: float = 5
@export var pitch_rot_speed: float = 2

@onready var spring_arm: SpringArm3D = $Gyro/SpringArm3D
@onready var yaw_gyro: Node3D = $Gyro

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_camera(event.relative.clamp(Vector2(-1, -1), Vector2(1, 1)))

func _ready() -> void:
	# Add ourselves as an excluded object so we don't interfere with the spring arm
	spring_arm.add_excluded_object(self)
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:

	# Capture Input
	var movement := Input.get_vector("left", "right", "forward", "backward") * speed
	var controller_rotation := Input.get_vector("camera_yaw_right", "camera_yaw_left", "camera_pitch_down", "camera_pitch_up")
	
	# If we are using a controller, call the rotate camera for the controller rotation
	if (not controller_rotation.is_zero_approx()):
		rotate_camera(controller_rotation)

	var direction = (yaw_gyro.basis * Vector3(movement.x, 0, movement.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	# If we are moving, do movement things
	if not movement.is_zero_approx():
		rotate_y(atan2(velocity.x, velocity.z) - global_rotation.y + PI)

	move_and_slide()

func rotate_camera(rot: Vector2) -> void:
	# rotate the gyro
	yaw_gyro.rotate_y( rot.x * yaw_rot_speed * get_physics_process_delta_time() )

	# rotate the springarm
	if not (spring_arm.rotation.x >= 0 and rot.y >= 0) and not (spring_arm.rotation.x <= deg_to_rad(-90) and rot.y <= 0):
		spring_arm.rotate_x( rot.y * pitch_rot_speed * get_physics_process_delta_time() )
		
