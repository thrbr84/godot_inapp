extends Area2D

var entered = false
var bounce = 0
var bnum = 1
var maxTop
var maxTopIni
var maxTopEnd
var collided = false
var numBlade = 1
var rnd = RandomNumberGenerator.new()
onready var posini = position

func _ready():
	# local randomize
	rnd.randomize()
	
	maxTop = rnd.randi() % 200
	maxTopIni = rnd.randf_range(0,10.5)
	maxTopEnd = rnd.randf_range(0,10.5)
	
	numBlade = (rnd.randi() % 3) + 1
	
	#load random blade
	$blade.texture = load(str("res://assets/traps/blade_",numBlade,".png"))

func _physics_process(delta):
	if weakref($blade).get_ref():
		$blade.rotation -= 5 * delta
	
	if bounce >= maxTop:
		bnum = -maxTopIni
	elif bounce <= 0:
		bnum = maxTopEnd
	
	position.y = lerp(position.y, posini.y - (bounce), 1.5)
	bounce += bnum

func _on_area_body_entered(body):
	if body.is_in_group("player"):
		# 10, 20 or 30 points, depends on the blade num
		body._hit(10 * numBlade)
		if body.shieldQtd == 0:
			$blade.self_modulate = Color.red
			collided = true

func _on_visibilityNotifier_screen_entered():
	if !entered:
		entered = true

func _on_visibilityNotifier_screen_exited():
	if entered:
		if !collided:
			# 1, 2 or 3 points, depends on the blade num
			get_parent().emit_signal("points", 1 * numBlade, false)
		queue_free()
