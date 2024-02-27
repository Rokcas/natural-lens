extends Node

func is_adj(a : Vector2i, b : Vector2i) -> bool:
	return (a - b).length_squared() == 1

func generate_initial(size : int) -> Array[Vector2i]:
	var result : Array[Vector2i] = []
	for i in range(0, size, 2):
		for j in range(size):
			result.push_back(Vector2i(i, j))
		if i + 1 >= size:
			break
		for j in range(size):
			result.push_back(Vector2i(i+1, size-1-j))
	return result

func backbite(seq : Array[Vector2i]) -> Array[Vector2i]:
	var start : Vector2i = seq[0]
	var candidates : Array[int] = []
	for i : int in range(seq.size()):
		if is_adj(start, seq[i]):
			candidates.push_back(i)
	var new_start : int = candidates[randi_range(0, len(candidates) - 1)]
	return seq.slice(new_start-1, -seq.size() - 1, -1) \
		+ seq.slice(new_start, seq.size())

func generate(size : int) -> Array[Vector2i]:
	var board : Array[Vector2i] = generate_initial(size)
	for _i in range(size * size * 10):
		board = backbite(board)
	board.reverse()
	for _i in range(size * size * 10):
		board = backbite(board)
	for i in range(board.size() - 1):
		assert(is_adj(board[i], board[i+1]))
	return board

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
