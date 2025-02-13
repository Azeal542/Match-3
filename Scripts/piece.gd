extends Node2D

@export var color:String ;

var move_tween;


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
