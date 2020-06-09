extends Node2D

onready var obstacles = preload("res://scenes/minigame/obstacles.tscn")
var genObstacles = true
var rnd = RandomNumberGenerator.new()

signal life(qtd)
signal shield(qtd)
signal points(qtd, restart)

func _ready():
	# local randomize
	rnd.randomize()
	self.connect("life", self, "_on_life_change")
	
func _on_life_change(qtd):
	genObstacles = (qtd > 0)

func _on_timerObstacles_timeout():
	if genObstacles:
		# generate obstacles
		var o = obstacles.instance()
		o.position = Vector2($player.position.x + 1500, 985)
		call_deferred("add_child", o)
	
	# randomize obstacles timer
	yield(get_tree().create_timer(rnd.randf_range(.2, 3.5)), "timeout")
	$timerObstacles.start()
