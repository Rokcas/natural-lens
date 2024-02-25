extends Area2D

# Approx. size of tiles. Right now it's slightly misaligned
const BOARD_BASE_POS = Vector2(16, 16)
const TILE_SIZE = 35

var inputs = {
	"Right": Vector2.RIGHT,
	"Left": Vector2.LEFT,
	"Up": Vector2.UP,
	"Down": Vector2.DOWN
}
@onready var ray = $RayCast2D

func _unhandled_input(event):
	for dir in inputs.keys():	
		if event.is_action_pressed(dir):
			move(dir)

func move(dir):
	ray.target_position = inputs[dir] * TILE_SIZE
	ray.force_raycast_update()
	if !ray.is_colliding():
		position += inputs[dir] * TILE_SIZE

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
