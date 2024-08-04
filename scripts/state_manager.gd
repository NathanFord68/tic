class_name StateManager
extends Resource

var state = {
	"idle": true
}

func set_state(att: String, toggle: bool) -> void:
	state[att] = toggle
