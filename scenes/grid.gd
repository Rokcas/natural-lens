extends CanvasGroup

const TILE_SIZE = 35
const BOARD_BASE_POS = Vector2(12, 12) + Vector2(TILE_SIZE, TILE_SIZE) / 2
const inputs = {
	"Right": Vector2i.RIGHT,
	"Left": Vector2i.LEFT,
	"Up": Vector2i.UP,
	"Down": Vector2i.DOWN
}

const BOARD_SIZE = 7

# TODO: Maybe move out to its own script?
var player_pos : Vector2i = Vector2i(0, 0)

func in_bounds(pos : Vector2i):
	return 0 <= min(pos.x, pos.y) and max(pos.x, pos.y) < BOARD_SIZE

func move(dir : Vector2i):
	var new_pos = player_pos + dir
	if in_bounds(new_pos):
		player_pos = new_pos
		update_player_position()

func update_player_position():
	$Player.position = BOARD_BASE_POS + TILE_SIZE * Vector2(player_pos)

# Called when the node enters the scene tree for the first time.
func _ready():
	update_player_position()

func _unhandled_input(event : InputEvent):
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			move(inputs[dir])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
