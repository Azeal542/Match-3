extends Node2D

enum {wait, move};
var state;

@export var width:int;
@export var height:int;
@export var x_start:int;
@export var y_start:int;
@export var offset:int;
@export var y_offset:int;
@export var initial_offset:int;

var possible_pieces = [
preload("res://Scenes/blue_piece.tscn"),
preload("res://Scenes/green_piece.tscn"),
preload("res://Scenes/light_green_piece.tscn"),
preload("res://Scenes/orange_piece.tscn"),
preload("res://Scenes/pink_piece.tscn"),
preload("res://Scenes/yellow_piece.tscn")
]

var all_pieces = [];

var first_touch = Vector2(0,0);
var final_touch = Vector2(0,0);
var controlling = false;

var score = 0;
var mult = 0;

var timer_started = false

# Called when the node enters the scene tree for the first time.
func _ready():
	state = move;
	randomize();
	all_pieces = make_2d_array();
	spawn_pieces();
	get_parent().get_node("Score").text= str(score)

	

func make_2d_array():
	var array = [];
	for i in width: 
		array.append([]);
		for j in height:
			array[i].append(null);
	return array;

func spawn_pieces():
	for i in width:
		for j in height:
			var rand = floor(randf_range(0, possible_pieces.size()));
			var piece = possible_pieces[rand].instantiate();
			var loops = 0;
			while(match_at(i, j, piece.color) && loops < 100):
				rand = floor(randf_range(0, possible_pieces.size()));
				loops += 1;
				piece = possible_pieces[rand].instantiate();
			add_child(piece);
			piece.position = grid_to_pixel(i, j - initial_offset);
			piece.move(grid_to_pixel(i,j));
			all_pieces[i][j] = piece;
			
func match_at(i, j, color):
	if i > 1:
		if all_pieces[i-1][j] != null && all_pieces[i-2][j] != null:
			if all_pieces[i-1][j].color == color && all_pieces[i-2][j].color == color:
				return true;
	if j > 1:
		if all_pieces[i][j-1] != null && all_pieces[i][j-2] != null:
			if all_pieces[i][j-1].color == color && all_pieces[i][j-2].color == color:
				return true;
	pass;

func grid_to_pixel(column, row):
	var new_x = x_start + offset * column;
	var new_y = y_start + -offset * row;
	return Vector2(new_x, new_y)

func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset);
	var new_y = round((pixel_y - y_start) / -offset);
	return Vector2(new_x, new_y);
	
func is_in_grid(grid_position):
	if grid_position.x >= 0 && grid_position.x < width:
		if grid_position.y >=0 && grid_position.y < height:
			return true;
	return false;
	
func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		if pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y):
			first_touch = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y);
			controlling = true;
			all_pieces[first_touch.x][first_touch.y].dim();
	if Input.is_action_just_released("ui_touch"):
		if pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y) && controlling:
			final_touch = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y);
			touch_difference(first_touch, final_touch);
			controlling = false;
			all_pieces[first_touch.x][first_touch.y].undim();
		all_pieces[first_touch.x][first_touch.y].undim();

func swap_pieces(column, row, direction):
	var first_piece = all_pieces[column][row];
	var other_piece = all_pieces[column + direction.x][row+direction.y];
	if first_piece != null && other_piece != null:
		state = wait;
		all_pieces[column][row] = other_piece;
		all_pieces[column + direction.x][row + direction.y] = first_piece;
		first_piece.move(grid_to_pixel(column + direction.x, row + direction.y));
		other_piece.move(grid_to_pixel(column, row));
		find_matches();
		get_parent().get_node("Score").text= str(score)

func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1,0));
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1,0));
		else: 
			pass
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0,1));
		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0,-1));
		else: 
			pass

func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_color = all_pieces[i][j].color;
				if i > 0 && i < width - 1:
					if all_pieces[i-1][j] != null && all_pieces[i+1][j] != null:
						if all_pieces [i-1][j].color == current_color && all_pieces[i+1][j].color == current_color:
							all_pieces[i-1][j].matched = true;
							all_pieces[i-1][j].dim();
							all_pieces[i][j].matched = true;
							all_pieces[i][j].dim();
							all_pieces[i+1][j].matched = true;
							all_pieces[i+1][j].dim();
							get_parent().get_node("Destroy_timer").start();
				if j > 0 && j < height - 1:
					if all_pieces[i][j-1] != null && all_pieces[i][j+1] != null:
						if all_pieces [i][j-1].color == current_color && all_pieces[i][j+1].color == current_color:
							all_pieces[i][j-1].matched = true;
							all_pieces[i][j-1].dim();
							all_pieces[i][j].matched = true;
							all_pieces[i][j].dim();
							all_pieces[i][j+1].matched = true;
							all_pieces[i][j+1].dim();
							get_parent().get_node("Destroy_timer").start();
		state = move;

func destroy_matched():
	get_parent().get_node("Mult_timer").start();
	timer_started = true;
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					all_pieces[i][j].queue_free();
					score = score + (1 * mult);
					mult +=1;
					get_parent().get_node("Score").text= str(score);
					get_parent().get_node("Crunch").pitch_scale=(randf_range(.5,1.5))
					get_parent().get_node("Crunch").play(0);
					all_pieces[i][j]
	get_parent().get_node("Collapse_timer").start();


func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				for k in range(j+1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i,j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	get_parent().get_node("Refill_timer").start();

func refill_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				var rand = floor(randf_range(0, possible_pieces.size()));
				var piece = possible_pieces[rand].instantiate();
				var loops = 0;
				while(match_at(i, j, piece.color) && loops < 100):
					rand = floor(randf_range(0, possible_pieces.size()));
					loops += 1;
					piece = possible_pieces[rand].instantiate();
				add_child(piece);
				piece.position = grid_to_pixel(i, j - y_offset);
				piece.move(grid_to_pixel(i,j));
				all_pieces[i][j] = piece;
	after_refill()

func after_refill():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if match_at(i,j,all_pieces[i][j].color):
					find_matches()
					get_parent().get_node("Destroy_timer").start()
					return
	state = move;
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state == move:
		touch_input();
	get_parent().get_node("Timer").text = str(get_parent().get_node("Mult_timer").get_time_left());


func _on_destroy_timer_timeout():
	destroy_matched();


func _on_collapse_timer_timeout():
	collapse_columns();

func _on_refill_timer_timeout():
	refill_columns();


func _on_mult_timer_timeout():
		mult = 0;


func _on_audio_stream_player_2d_finished():
	get_parent().get_node("AudioStreamPlayer2D").play();
