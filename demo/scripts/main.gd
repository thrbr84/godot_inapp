extends Node2D

enum productTypes {PURCHASE, CONSUME}
onready var controlItem = preload("res://scenes/item.tscn")
onready var iap = $IAP
onready var productsGrid = $ui/productsControl/grid
onready var minigame = $ui/minigame/ViewportContainer/Viewport/minigame
var item_clicked = null
var totalPoints = 0

func _ready():
	_iap_init()

	# mini game
	minigame.connect("life", self, "_on_life_change")
	minigame.connect("shield", self, "_on_shield_change")
	minigame.connect("points", self, "_on_points_change")

"""
# IAP functions
# ----------------------------------------------------
"""
func _iap_init():
	iap.set_auto_consume(false)
	
	# load products info
	#"android.test.purchased"
	#"android.test.canceled"
	#"android.test.item_unavailable"
	
	_loadProducts([
		"android.test.purchased"
		#"extra_life", 
		#"diamonds1",
		#"diamonds3",
		#"diamonds5"
	])

func _loadProducts(products):
	# kill all products instancied
	for p in productsGrid.get_children():
		p.queue_free()
	
	# Load product info from Google Play
	iap.sku_details_query(products)

func _on_btnItem_pressed(item):
	$ui/debug.text = str("Product: ", item.product_id, "...")
	item_clicked = item
	
	if int(item.type) == item.types.PURCHASE:
		# purchase product
		iap.purchase(str(item.product_id))
		
	elif int(item.type) == item.types.CONSUME:
		# consume product
		iap.consume(str(item.product_id))



"""
# IAP signals
# ----------------------------------------------------
"""
func _on_IAP_consume_fail():
	$ui/debug.text = "Consume fail"

func _on_IAP_purchase_cancel():
	$ui/debug.text = str("Purchase cancelled")

func _on_IAP_purchase_fail():
	$ui/debug.text = str("Purchase fail")
	
func _on_IAP_consume_not_required():
	$ui/debug.text = "Consume not required"

func _on_IAP_consume_success(product_id):
	$ui/debug.text = str("Consume success: ", product_id)
	_mark_checked(product_id, false)
	
	# change button to purchase action
	_set_details(product_id, {
		"type": productTypes.PURCHASE
	}, false)
	
	# action after consume
	match product_id:
		"extra_life": 
			_regeneratePlayer()
		"diamonds1": 
			_playersShield(1)
		"diamonds3": 
			_playersShield(3)
		"diamonds5": 
			_playersShield(5)

func _on_IAP_has_purchased(product_id):
	if product_id != null:
		$ui/debug.text = str("Purchased: ", product_id)
		
		# if has purchased product, change to consume
		_set_details(product_id, {
			"type": productTypes.CONSUME
		}, true)

# only if I have two buttons, one to purchase and other to consume
# this signal is emitting in purchased item
#func _on_IAP_purchase_owned(product_id):
#	$ui/debug.text = str("Purchase owned! ", product_id)
#	_set_details(product_id, {
#		"type": productTypes.CONSUME
#	}, true)

func _on_IAP_purchase_success(product_id):
	$ui/debug.text = str("Purchase success: ", product_id)
	_set_details(product_id, {
		"type": productTypes.CONSUME
	}, true)

func _on_IAP_sku_details_complete(result):
	
	# list products by google play info
	for k in result.keys():
		var prod = result[k]
		_set_details(prod['product_id'], prod, false)
	
	# get purchased info
	iap.request_purchased()
	
	if result.keys().size() > 0:
		$ui/title.show()
		$ui/noitems.hide()
	else:
		$ui/title.hide()
		$ui/noitems.show()
	
	$ui/debug.text = str("Products loaded!")

func _on_IAP_sku_details_error(error_message):
	$ui/debug.text = str("Error getting product details: ", error_message)

func _mark_checked(product_id, state = true):
	for n in get_tree().get_nodes_in_group("item"):
		if str(n['product_id']) == str(product_id) && n['type'] == productTypes.PURCHASE:
			n.type = productTypes.CONSUME
			n.set_check(state)
			break

func _set_details(product_id, detail: Dictionary = {}, hasitem = false):
	var foundItem = null
	# search item in grid
	for n in productsGrid.get_children():
		if str(n['product_id']) == str(product_id):
			foundItem = n
			break

	# update exist item
	if weakref(foundItem).get_ref():
		# update some keys
		for k in detail.keys():
			foundItem[k] = detail[k]
		
		# set button status
		foundItem.set_check(hasitem)

	else:
		# item not exists, create
		var prod = controlItem.instance()
		prod.product_id = product_id
		prod.type = productTypes.PURCHASE
		prod.price = detail['price'] if detail.has("price") else ""
		prod.title = detail['title'] if detail.has("title") else ""
		prod.description = detail['description'] if detail.has("description") else ""
		prod.icon = load(str("res://assets/products/",product_id,".png"))
		prod.set_check(hasitem)
		prod.connect("pressed", self, "_on_btnItem_pressed")
		productsGrid.call_deferred("add_child", prod)



"""
# MINI Game
# ----------------------------------------------------
"""
func _on_life_change(life):
	$ui/minigame/bar.value = life

func _on_points_change(points, restart=false):
	totalPoints += points
	
	if restart:
		totalPoints = points
	
	$ui/minigame/points.text = str(totalPoints)

func _on_shield_change(qtd):
	$ui/minigame/shield.text = str(qtd)

func _regeneratePlayer():
	minigame.get_node("player")._regenerate()
	
func _playersShield(qtd):
	minigame.get_node("player").shieldQtd += qtd
	_on_shield_change(minigame.get_node("player").shieldQtd) 
