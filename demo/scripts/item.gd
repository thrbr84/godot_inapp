tool
extends Control

enum types {PURCHASE, CONSUME}

export var product_id = ""
export var title = ""
export var description = ""
export(types) var type = types.PURCHASE
export var price = "" setget _setPrice
export(Texture) var icon setget _setIcon
var dragging = false

signal pressed(item)

func _setIcon(newValue):
	icon = newValue
	if icon:
		$item.texture = icon
		$item/icon.texture = icon

func _setPrice(newValue):
	price = newValue
	$price.text = price

func _ready():
	add_to_group("item")

func _on_touch_pressed():
	yield(get_tree().create_timer(.3), "timeout")
	if !dragging:
		emit_signal("pressed", self)

func set_check(state):
	$check.set("visible", state)
	$price.set("visible", !state)
	
func get_check() -> bool:
	return $check.get("visible")

func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			dragging = true
		else:
			dragging = false
