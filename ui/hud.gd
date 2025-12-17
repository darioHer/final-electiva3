extends CanvasLayer

@onready var xp_bar: ProgressBar = $MarginContainer/VBoxContainer/XPBar
@onready var level_label: Label = $MarginContainer/VBoxContainer/LabelLevel

func bind_player(player: Node) -> void:


	if player.has_signal("xp_changed"):
		player.xp_changed.connect(_on_xp_changed)
	if player.has_signal("leveled_up"):
		player.leveled_up.connect(_on_leveled_up)



	if player.has_method("get_xp_state"):
		var s = player.get_xp_state()
		_on_xp_changed(s.xp, s.xp_to_next, s.level)

func _on_xp_changed(xp: int, xp_to_next: int, level: int) -> void:
	level_label.text = "Lv %d" % level
	xp_bar.max_value = xp_to_next
	xp_bar.value = xp

func _on_leveled_up(level: int) -> void:
	level_label.text = "Lv %d" % level
