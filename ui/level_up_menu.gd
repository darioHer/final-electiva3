extends CanvasLayer

var player_ref: Node = null

func set_player(p: Node) -> void:
	player_ref = p
	print("✅ Menu recibió player:", player_ref)

func _ready() -> void:
	# ✅ Asegura que procese aun en pausa
	process_mode = Node.PROCESS_MODE_ALWAYS

	# ✅ Mouse visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# ✅ Evita que el click “pase” al juego (captura el mouse)
	$Panel.mouse_filter = Control.MOUSE_FILTER_STOP
	$Panel/VBoxContainer.mouse_filter = Control.MOUSE_FILTER_STOP
	$Panel/VBoxContainer/BtnFireRate.mouse_filter = Control.MOUSE_FILTER_STOP
	$Panel/VBoxContainer/BtnRange.mouse_filter = Control.MOUSE_FILTER_STOP
	$Panel/VBoxContainer/BtnClose.mouse_filter = Control.MOUSE_FILTER_STOP

	# ✅ Conexiones
	$Panel/VBoxContainer/BtnFireRate.pressed.connect(_on_fire_rate)
	$Panel/VBoxContainer/BtnRange.pressed.connect(_on_range)
	$Panel/VBoxContainer/BtnClose.pressed.connect(_on_close)

	# ✅ Foco por teclado también
	$Panel/VBoxContainer/BtnFireRate.grab_focus()

	print("✅ Menu listo. paused=", get_tree().paused)

func _on_fire_rate() -> void:
	print("🟦 Click FireRate")
	if player_ref == null:
		print("❌ player_ref es null")
		return
	if not player_ref.has_method("upgrade_fire_rate"):
		print("❌ Player NO tiene upgrade_fire_rate()")
		return
	player_ref.upgrade_fire_rate()
	_close_menu()

func _on_range() -> void:
	print("🟩 Click Range")
	if player_ref == null:
		print("❌ player_ref es null")
		return
	if not player_ref.has_method("upgrade_range"):
		print("❌ Player NO tiene upgrade_range()")
		return
	player_ref.upgrade_range()
	_close_menu()

func _on_close() -> void:
	print("⬜ Click Close")
	_close_menu()

func _close_menu() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	queue_free()
