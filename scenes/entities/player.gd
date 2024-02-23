extends Area2D

var tile_size = 64
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
	ray.target_position = inputs[dir] * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		position += inputs[dir] * tile_size

# Called when the node enters the scene tree for the first time.
func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
