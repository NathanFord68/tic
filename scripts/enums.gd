extends Node

enum jump_state { 
	none = 0, 
	start = 1, 
	idle = 2,
	end = 3 
}

enum attack_state { 
	none = 0, 
	cooldown = 1, 
	combo_one = 2, 
	combo_two = 3, 
	combo_three = 4 
}
