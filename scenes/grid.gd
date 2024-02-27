extends CanvasGroup

const TILE_SIZE = 35
const BOARD_BASE_POS = Vector2(12, 12) + Vector2(TILE_SIZE, TILE_SIZE) / 2
const INPUTS = {
	"Right": Vector2i.RIGHT,
	"Left": Vector2i.LEFT,
	"Up": Vector2i.UP,
	"Down": Vector2i.DOWN
}
const BOARD_SIZE = 7

const DebugBoardLine = preload("res://scenes/entities/debug_board_line.tscn")
const BoardLine = preload("res://scenes/entities/board_line.tscn")
const Gen = preload("res://scenes/logic/board_gen.gd")

var DebugLines = []
var Breadcrumbs = []

# TODO: Maybe move out to its own script?
var player_pos : Vector2i = Vector2i(0, 0)
var player_pos_list : Array[Vector2i] = [Vector2i(0, 0)]

func in_bounds(pos : Vector2i):
	return 0 <= min(pos.x, pos.y) and max(pos.x, pos.y) < BOARD_SIZE

func can_move(dir : Vector2i):
	var new_pos = player_pos + dir
	if in_bounds(new_pos):
		var idx = player_pos_list.find(new_pos)
		# Make sure player is not looping in on themselves
		if idx == -1:
			player_pos_list.push_back(new_pos)
			return true
		# Player can go backwards
		if idx == len(player_pos_list) - 2:
			player_pos_list.pop_back()
			return true
		return false
	return false

func update_player_position():
	$Player.position = BOARD_BASE_POS + TILE_SIZE * Vector2(player_pos)
	while Breadcrumbs.size() + 1 > player_pos_list.size():
		var last = Breadcrumbs.pop_back()
		last.queue_free()
	while Breadcrumbs.size() + 1 < player_pos_list.size():
		var idx = len(Breadcrumbs)
		var prev = player_pos_list[idx]
		var next = player_pos_list[idx+1]
		var delta = Vector2(next - prev)
		var line = BoardLine.instantiate()
		line.position = BOARD_BASE_POS + TILE_SIZE * Vector2(prev)
		line.rotation = delta.angle()
		Breadcrumbs.push_back(line)
		add_child(line)

func reset(new_board : Array[Vector2i]):
	for line in Breadcrumbs:
		line.queue_free()
	Breadcrumbs.clear()
	player_pos = new_board[0]
	player_pos_list = [new_board[0]]
	update_player_position()

func debug_generator():
	for line in DebugLines:
		line.queue_free()
	DebugLines.clear()
	var config = Gen.new().generate(7)
	for i in range(len(config) - 1):
		var prev = config[i]
		var next = config[i+1]
		var delta = Vector2(next - prev)
		var line = DebugBoardLine.instantiate()
		line.position = BOARD_BASE_POS + TILE_SIZE * Vector2(prev)
		line.rotation = delta.angle()
		DebugLines.push_back(line)
		add_child(line)
	reset(config)

# Called when the node enters the scene tree for the first time.
func _ready():
	debug_generator()
	update_player_position()

func _unhandled_input(event : InputEvent):
	# DEBUG: Regenerate random walk
	if event.is_action_pressed("ui_accept"):
		debug_generator()
	for k in INPUTS.keys():
		if event.is_action_pressed(k):
			var dir = INPUTS[k]
			if can_move(dir):
				player_pos += dir
				update_player_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
