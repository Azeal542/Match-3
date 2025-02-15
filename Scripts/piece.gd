extends Node2D

@export var color:String ;

var move_tween;
var matched = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	move_tween = get_tree().create_tween();
	pass

func move(target):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target, .3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT);
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func dim():
	var sprite = get_node("Sprite2D")
	sprite.modulate = Color(1,1,1,.5);
func undim():
	var sprite = get_node("Sprite2D")
	sprite.modulate = Color(1,1,1,1)
