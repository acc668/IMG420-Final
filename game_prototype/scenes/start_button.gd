extends Button

func _ready():
	self.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/topdown_game.tscn")
