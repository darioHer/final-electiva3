extends CharacterBody3D

const SPEED := 5.5
const BULLET_3D := preload("bullet_3d.tscn")

@export var auto_fire_enabled: bool = true
@export var shoot_distance: float = 50.0
@onready var aim_ray: RayCast3D = $Camera3D/AimRay


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Configuración del RayCast (AimRay)
	$Camera3D/AimRay.enabled = true
	$Camera3D/AimRay.target_position = Vector3(0, 0, -shoot_distance)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5
		$Camera3D.rotation_degrees.x -= event.relative.y * 0.2
		$Camera3D.rotation_degrees.x = clamp(
			$Camera3D.rotation_degrees.x, -60.0, 60.0
		)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta):
	# --- Movimiento ---
	var input_direction_2D = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)
	var input_direction_3D = Vector3(
		input_direction_2D.x, 0, input_direction_2D.y
	)
	var direction = transform.basis * input_direction_3D

	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	# --- Gravedad / salto ---
	velocity.y -= 20.0 * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 10.0
	elif Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y = 0.0

	move_and_slide()

	# --- DISPARO AUTOMÁTICO SOLO SI HAY MOB EN LA MIRA ---
	if auto_fire_enabled and $Timer.is_stopped():
		if is_mob_in_crosshair():
			shoot_bullet()


func is_mob_in_crosshair() -> bool:
	var ray := $Camera3D/AimRay
	ray.force_raycast_update()

	if not ray.is_colliding():
		return false

	var collider = ray.get_collider()
	if collider == null:
		return false

	# Caso 1: el collider es el Mob directamente
	if collider.has_method("take_damage"):
		return true

	# Caso 2: el collider es un hijo (CollisionShape3D)
	var parent = collider.get_parent()
	if parent != null and parent.has_method("take_damage"):
		return true

	return false


func shoot_bullet():
	var new_bullet = BULLET_3D.instantiate()

	# Marker3D está dentro de Camera3D
	$Camera3D/Marker3D.add_child(new_bullet)
	new_bullet.global_transform = $Camera3D/Marker3D.global_transform

	$Timer.start()
	$AudioStreamPlayer.play()
