extends KinematicBody2D

var maxlife = 100
onready var life = maxlife

var velocity = Vector2.ZERO
var gravity = 20
var speed = 400
var dblJump = 1
var dblMaxJump = 2
var shieldQtd = 0
var onFloor = false
var isDead = false
	
func _process(delta):
	if isDead: return

	$bubble.set("visible", (shieldQtd > 0))

	# If press spacebar
	if bool(Input.is_action_just_pressed("ui_accept")):
		_jump()

func _input(event):
	# if touch screen
	if event is InputEventScreenTouch && event.position.y > 0:
		if event.is_pressed():
			_jump()

func _jump():
	if isDead:return
	# jump if you are on the floor and within the limit of jumps
	if (onFloor || dblJump <= dblMaxJump):
		onFloor = false
		$anim.play("jump")
		velocity.y = -speed
		dblJump += 1

func _physics_process(delta):
	if !isDead:
		# run
		velocity.x = velocity.normalized().x + speed
	# gravity
	velocity.y += gravity
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# if pass to ground limit without static ground
	if position.y > 1000:
		position.y = 1000
		velocity.y = 0
		onFloor = true
		dblJump = 1
		
	# if was jumping and is on floor
	if $anim.animation == "jump" && onFloor:
		$anim.play("run")

func _hit(power):

	# If the shield is over
	if shieldQtd == 0:
		life -= power
		life = clamp(life, 0, maxlife)
		
		_genBlood()
		
		# emit signal to reresh the lifebar
		get_parent().emit_signal("life", life)
		
		if life == 0:
			velocity.x = 0
			isDead = true
			$anim.play("dead")
			
			# if dead, kill all obstacles
			for o in get_tree().get_nodes_in_group("obstacles"):
				o.queue_free()

	# Decrease the shield
	shieldQtd -= 1
	if shieldQtd < 0:
		shieldQtd = 0
	
	get_parent().emit_signal("shield", shieldQtd)

func _regenerate():
	# regenerate player life
	life = maxlife
	
	if isDead:
		velocity.x = speed
		isDead = false
		$anim.play("run")
		
		# se is dead, reset the points
		get_parent().emit_signal("points", 0, true)
	
	get_parent().emit_signal("life", life)

func _genBlood():
	var blood = $blood.duplicate()
	blood.emitting = true
	add_child(blood)
	yield(get_tree().create_timer(1),"timeout")
	blood.queue_free()
