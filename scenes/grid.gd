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
var Items = []

var points = 0

# TODO: Maybe move out to its own script?
var player_pos : Vector2i = Vector2i(0, 0)
var player_pos_list : Array[Vector2i] = [Vector2i(0, 0)]
var item_pos_list : Array[Vector2i] = [Vector2i(BOARD_SIZE-1, BOARD_SIZE-1)]

func in_bounds(pos : Vector2i):
	return 0 <= min(pos.x, pos.y) and max(pos.x, pos.y) < BOARD_SIZE

func is_protected(pos : Vector2i) -> bool:
	# Items cannot be collected out of order
	var next_ind = -1
	for i in range(len(item_pos_list)):
		if item_pos_list[i] not in player_pos_list:
			next_ind = i
			break
	var loc = item_pos_list.find(pos)
	if loc <= next_ind:
		return false
	return true

func do_move(dir : Vector2i) -> bool:
	var new_pos = player_pos + dir
	if in_bounds(new_pos):
		if is_protected(new_pos):
			return false
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

func puzzle_completed() -> bool:
	if player_pos != item_pos_list[-1]:
		return false
	for item_pos in item_pos_list:
		if item_pos not in player_pos_list:
			return false
	return true

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
	if puzzle_completed():
		points += player_pos_list.size()
		print("Points:", points)
		debug_generator()

func reset(new_board : Array[Vector2i], new_items : Array[Vector2i]):
	for line in Breadcrumbs:
		line.queue_free()
	Breadcrumbs.clear()
	player_pos = new_board[0]
	player_pos_list = [new_board[0]]
	item_pos_list = new_items
	update_player_position()

func debug_generator():
	for line in DebugLines:
		line.queue_free()
	DebugLines.clear()
	for item in Items:
		item.queue_free()
	Items.clear()
	var gen = Gen.new()
	var config = gen.generate(7)
	#for i in range(len(config) - 1):
	#	var prev = config[i]
	#	var next = config[i+1]
	#	var delta = Vector2(next - prev)
	#	var line = DebugBoardLine.instantiate()
	#	line.position = BOARD_BASE_POS + TILE_SIZE * Vector2(prev)
	#	line.rotation = delta.angle()
	#	DebugLines.push_back(line)
	#	add_child(line)
	var items = gen.get_items(config, 5)
	var new_items : Array[Vector2i] = []
	for loc in items.keys():
		items[loc].position = BOARD_BASE_POS + TILE_SIZE * Vector2(loc)
		new_items.push_back(loc)
		add_child(items[loc])
		Items.push_back(items[loc])
	reset(config, new_items)

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
			if do_move(dir):
				player_pos += dir
				update_player_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
