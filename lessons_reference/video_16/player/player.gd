extends CharacterBody3D

signal leveled_up(level: int)
signal xp_changed(xp: int, xp_to_next: int, level: int)

const BULLET_3D := preload("bullet_3d.tscn")

@export var move_speed: float = 5.5
@export var auto_fire_enabled: bool = true
@export var shoot_distance: float = 50.0

# --- XP 
var xp: int = 0
var level: int = 1
var xp_to_next: int = 5

@onready var cam := get_node_or_null("Camera3D")
@onready var aim_ray := get_node_or_null("Camera3D/AimRay")
@onready var marker := get_node_or_null("Camera3D/Marker3D")
@onready var shot_timer := get_node_or_null("Timer")
@onready var shoot_audio := get_node_or_null("AudioStreamPlayer")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if aim_ray:
		aim_ray.enabled = true
		aim_ray.target_position = Vector3(0, 0, -shoot_distance)
	else:
		push_error("No se encontró AimRay en Camera3D/AimRay")


	emit_signal("xp_changed", xp, xp_to_next, level)


func _unhandled_input(event):
	if event is InputEventMouseMotion and cam:
		rotation_degrees.y -= event.relative.x * 0.5
		cam.rotation_degrees.x -= event.relative.y * 0.2
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -60.0, 60.0)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta):
	# --- Movimiento ---
	var input_dir_2d = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var input_dir_3d = Vector3(input_dir_2d.x, 0, input_dir_2d.y)
	var dir = transform.basis * input_dir_3d

	velocity.x = dir.x * move_speed
	velocity.z = dir.z * move_speed

	velocity.y -= 20.0 * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 10.0
	elif Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y = 0.0

	move_and_slide()

	# --- Disparo automático (si hay mob en la mira) ---
	if auto_fire_enabled and shot_timer and shot_timer.is_stopped():
		if is_mob_in_crosshair():
			shoot_bullet()


func is_mob_in_crosshair() -> bool:
	if aim_ray == null:
		return false

	aim_ray.target_position = Vector3(0, 0, -shoot_distance)
	aim_ray.force_raycast_update()

	if not aim_ray.is_colliding():
		return false

	var collider = aim_ray.get_collider()
	if collider == null:
		return false

	if collider.has_method("take_damage"):
		return true

	var p = collider.get_parent()
	return p != null and p.has_method("take_damage")


func shoot_bullet():
	if marker == null:
		return

	var bullet = BULLET_3D.instantiate()
	marker.add_child(bullet)
	bullet.global_transform = marker.global_transform

	if shot_timer:
		shot_timer.start()
	if shoot_audio:
		shoot_audio.play()


func add_xp(amount: int) -> void:
	xp += amount

	#  actualizar HUD inmediatamente
	emit_signal("xp_changed", xp, xp_to_next, level)

	while xp >= xp_to_next:
		xp -= xp_to_next
		level += 1
		xp_to_next = int(ceil(float(xp_to_next) * 1.6))

		print("Subiste a nivel:", level, " | siguiente:", xp_to_next)

		emit_signal("leveled_up", level)
		emit_signal("xp_changed", xp, xp_to_next, level)


func get_xp_state() -> Dictionary:
	return {
		"xp": xp,
		"xp_to_next": xp_to_next,
		"level": level
	}



func upgrade_fire_rate() -> void:
	if shot_timer:
		shot_timer.wait_time = max(0.05, shot_timer.wait_time * 0.85)
		print("FireRate upgrade. Nuevo wait_time:", shot_timer.wait_time)

func upgrade_range() -> void:
	shoot_distance = min(150.0, shoot_distance + 15.0)
	if aim_ray:
		aim_ray.target_position = Vector3(0, 0, -shoot_distance)
	print(" Range upgrade. Nuevo rango:", shoot_distance)
