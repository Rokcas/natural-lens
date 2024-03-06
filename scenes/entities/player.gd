extends Area2D

var shouldPlayAlt : bool = false

func play_anim_for_dir(dir : String) -> void:
	if shouldPlayAlt:
		dir = dir + "Alt"
	$AnimatedSprite2D.play(dir)
	shouldPlayAlt = not shouldPlayAlt
