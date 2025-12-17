extends Node3D

var player_score = 0

@onready var label := %Label
@onready var player := get_node_or_null("Player")

const LEVEL_UP_MENU = preload("res://ui/level_up_menu.tscn")
const PAUSE_MENU = preload("res://ui/PauseMenu.tscn")
const HUD_SCN = preload("res://ui/hud.tscn")

var hud: Node = null
var pause_menu_open := false
var level_menu_open := false


func _ready():
	update_hud()

	if player:

		if not player.leveled_up.is_connected(_on_player_leveled_up):
			player.leveled_up.connect(_on_player_leveled_up)

		hud = HUD_SCN.instantiate()
		hud.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(hud)

		if hud.has_method("bind_player"):
			hud.bind_player(player)
	else:
		push_error("No se encontró nodo Player dentro de Game")



func increase_score():
	player_score += 1
	update_hud()

func update_hud():
	label.text = "Score: %s" % str(player_score)

func _on_kill_plane_body_entered(_body):
	get_tree().reload_current_scene.call_deferred()

func _on_mob_spawner_3d_mob_spawned(mob):
	if not mob.has_signal("died"):
		push_error(" El mob no tiene signal 'died'")
		return

	mob.died.connect(func():
		increase_score()
		do_poof(mob.global_position)

		var xp_gain := 1
		if mob.get("xp_reward") != null:
			xp_gain = int(mob.xp_reward)

		if player:
			player.add_xp(xp_gain)
	)


func _on_player_leveled_up(_level: int):
	if level_menu_open:
		return

	level_menu_open = true
	get_tree().paused = true

	var menu = LEVEL_UP_MENU.instantiate()
	menu.process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	menu.set_player(player)
	add_child(menu)

	menu.tree_exited.connect(func():
		level_menu_open = false
	)


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if level_menu_open:
			return

		if pause_menu_open:
			_close_pause_menu()
		else:
			_open_pause_menu()

func _open_pause_menu():
	if pause_menu_open:
		return

	pause_menu_open = true
	get_tree().paused = true

	var menu = PAUSE_MENU.instantiate()
	menu.name = "PauseMenu"
	menu.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(menu)

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	menu.tree_exited.connect(func():
		pause_menu_open = false
	)

func _close_pause_menu():
	var menu = get_node_or_null("PauseMenu")
	if menu:
		menu.queue_free()

	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pause_menu_open = false

func do_poof(mob_position):
	const SMOKE_PUFF = preload("res://mob/smoke_puff/smoke_puff.tscn")
	var poof := SMOKE_PUFF.instantiate()
	add_child(poof)
	poof.global_position = mob_position
