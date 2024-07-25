extends CharacterBody3D

class_name Player

@export var speed: float = 100.0



func _ready():
	# Add ourselves as an excluded object so we don't interfere with the spring arm
	($SpringArm3D as SpringArm3D).add_excluded_object(self)

func _physics_process(delta: float) -> void:

	# Get the vector from player movement input
	var movement := Input.get_vector("left", "right", "backward", "forward") * speed
	
	# Assign 2D vector to our 3D velocity
	velocity.x = movement.x
	velocity.z = - movement.y
	
	move_and_slide()
