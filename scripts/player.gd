extends CharacterBody3D

class_name Player

@export var controller: PlayerController

func _ready() -> void:
	# Setup the controller
	controller.owner = self
	controller.yaw_gyro = $Gyro
	controller.spring_arm = $Gyro/SpringArm3D
	$Gyro/SpringArm3D.add_excluded_object(self)
	
	# Establish mouse mode
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event: InputEvent) -> void:
	controller.handle_input(event)

func _physics_process(delta: float) -> void:
	controller.handle_process(delta)
