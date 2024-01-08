extends Area2D

const PRICE_LABEL_PATH := "UI/TowerPopup/Background/Panel/Towers/%s/Label"

@onready var tower_popup := $UI/TowerPopup as CanvasLayer
@onready var tower_actions := $UI/TowerActions as VBoxContainer
@onready var repair_cost := $UI/TowerActions/Repair/Cost as Label
@onready var upgrade_cost := $UI/TowerActions/Upgrade/Cost as Label
@onready var exchange_cost := $UI/TowerActions/Exchange/Cost as Label
@onready var sell_cost := $UI/TowerActions/Sell/Cost as Label

var _towers_to_build := {
	"gatling": preload("res://entities/towers/gatling_tower.tscn"),
	"cannon": preload("res://entities/towers/cannon_tower.tscn"),
	"missile": preload("res://entities/towers/missile_tower.tscn")
}
var tower: Tower

func _ready():
	for tower_name in Global.tower_costs.keys():
		var price_label := get_node(PRICE_LABEL_PATH % [tower_name.capitalize()]) as Label
		price_label.text = str(Global.tower_costs[tower_name])

func _process(_dt: float) -> void:
	if tower:
		repair_cost.text = str(get_repair_cost())
		upgrade_cost.text = str(get_upgrade_cost())
		exchange_cost.text = str(get_sell_price())
		sell_cost.text = str(get_sell_price())

func get_sell_price() -> int:
	var tower_cost: int = tower.cost
	var remaining_health_pct: float = float(tower.health) / tower.max_health
	return floor(tower_cost * remaining_health_pct)

func get_repair_cost() -> int:
	var tower_cost: int =  Global.tower_costs[tower.tower_type]
	var missing_health_pct: float = float(tower.max_health - tower.health) / tower.max_health
	return floor(tower_cost * missing_health_pct)

func get_upgrade_cost() -> int:
	var base_tower_cost = Global.tower_costs[tower.tower_type]
	return base_tower_cost * tower.current_upgrade_multiplier

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and \
			event.button_index == MOUSE_BUTTON_LEFT:
		if tower:
			tower_actions.visible = !tower_actions.visible
		else:
			tower_popup.show()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and \
			event.button_index == MOUSE_BUTTON_LEFT and tower_actions.visible:
		tower_actions.visible = false


func _flash_ui(node: Node, color_hex: String):
	var tween := create_tween().set_trans(Tween.TRANS_BACK).\
			set_ease(Tween.EASE_IN_OUT)
	node.modulate = Color(color_hex)
	tween.tween_property(node, "modulate", Color("fff"), 0.25)


func _on_tower_popup_tower_requested(type: String):
	if Global.tower_costs[type] <= Global.money:
		tower = _towers_to_build[type].instantiate()
		tower.tower_type = type
		add_child(tower, true)
		tower_popup.hide()
		tower.tower_destroyed.connect(_on_tower_destroyed)

		var tower_cost = Global.tower_costs[type]
		Global.money -= tower_cost
		tower.cost = tower_cost
	else:
		var price_label := get_node(PRICE_LABEL_PATH % [type.capitalize()]) as Label
		_flash_ui(price_label, "ff383f")

func _reset_upgrades():
	tower.upgrade(1 / tower.current_upgrade_multiplier) # good enough to bring back the original values

func _on_tower_destroyed():
	_reset_upgrades()
	tower = null
	tower_actions.visible = false

func _on_repair_pressed():
	var cost = get_repair_cost()
	if cost <= Global.money:
		tower.repair()
		Global.money -= cost
		tower_actions.visible = false
	else:
		var repair_btn := tower_actions.get_node("Repair") as Button
		_flash_ui(repair_btn, "ff383f")

func _on_exchange_pressed():
	_on_sell_pressed()
	tower_popup.show()

func _on_sell_pressed():
	var tower_value = get_sell_price()
	Global.money += tower_value
	_reset_upgrades()
	tower.queue_free()
	tower_actions.visible = false
	tower = null

func _on_upgrade_pressed():
	var cost = get_upgrade_cost()
	if cost <= Global.money:
		tower.upgrade(tower.base_upgrade_multiplier)
		tower.cost += cost
		Global.money -= cost
		tower_actions.visible = false
	else:
		var btn := tower_actions.get_node("Upgrade") as Button
		_flash_ui(btn, "ff383f")
