extends Control

var dragging = false
var speedScroll = 5
var velocity = Vector2.ZERO
var posini = Vector2.ZERO
var posend = Vector2.ZERO
onready var grid = $grid

func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			if _checkMouseArea():
				posini = get_global_mouse_position()
		else:
			dragging = false
			velocity = Vector2.ZERO
	
	if event is InputEventScreenDrag && _checkMouseArea():
		dragging = true
		posend = get_global_mouse_position()

func _process(delta):
	if grid.rect_size.y < 300: return
	
	var dir = Vector2.ZERO
	if dragging:
		dir = (posend - posini)

	grid.rect_position.y += sign(dir.y) * ((dir.length() * speedScroll) * delta)
	grid.rect_position.y = clamp(grid.rect_position.y, -(grid.rect_size.y) , 0)

func _checkMouseArea() -> bool:
	var gmouse = get_global_mouse_position()
	return (gmouse.y >= self.rect_global_position.y && gmouse.y <= self.rect_global_position.y + self.rect_size.y )
