class_name HurtBox
extends Area3D

func ready() -> void:
	body_entered.connect(handle_body_entered)

func handle_body_entered(body: Node3D) -> void:
	print_debug(body.name)
