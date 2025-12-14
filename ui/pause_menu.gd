extends CanvasLayer

func _ready() -> void:
	# ✅ Igual que LevelUpMenu: procesar aunque el juego esté en pausa
	process_mode = Node.PROCESS_MODE_ALWAYS

	# ✅ Igual que LevelUpMenu: mouse visible para poder hacer clic
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# ✅ Igual que LevelUpMenu: evita que el click atraviese la UI
	$Panel.mouse_filter = Control.MOUSE_FILTER_STOP
	$Panel/VBoxContainer.mouse_filter = Control.MOUSE_FILTER_STOP
	$Panel/VBoxContainer/BtnResume.mouse_filter = Control.MOUSE_FILTER_STOP
	$Panel/VBoxContainer/BtnRestart.mouse_filter = Control.MOUSE_FILTER_STOP
	$Panel/VBoxContainer/BtnQuit.mouse_filter = Control.MOUSE_FILTER_STOP

	# ✅ Conexiones (igual que LevelUpMenu)
	$Panel/VBoxContainer/BtnResume.pressed.connect(_on_resume)
	$Panel/VBoxContainer/BtnRestart.pressed.connect(_on_restart)
	$Panel/VBoxContainer/BtnQuit.pressed.connect(_on_quit)

	# ✅ Foco inicial
	$Panel/VBoxContainer/BtnResume.grab_focus()

	print("✅ PauseMenu listo. paused=", get_tree().paused)

func _on_resume() -> void:
	print("▶ Resume")
	_close_pause()

func _on_restart() -> void:
	print("🔁 Restart")
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().reload_current_scene.call_deferred()

func _on_quit() -> void:
	print("❌ Quit")
	get_tree().quit()

func _close_pause() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	queue_free()
