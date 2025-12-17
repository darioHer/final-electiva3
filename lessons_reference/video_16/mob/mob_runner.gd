extends RigidBody3D
signal died

@export var speed: float = 5.5
@export var health: int = 1
@export var xp_reward: int = 2

@onready var model: Node = %bat_model
@onready var timer: Timer = %Timer
@onready var player: Node3D = get_node("/root/Game/Player")

func _ready():
	set_color_recursive(model, Color.RED)
	scale *= 0.9

func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	direction.y = 0.0
	linear_velocity = direction * speed
	model.rotation.y = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI

func take_damage():
	if health <= 0:
		return
	health -= 1
	if health == 0:
		_die()

func _die():
	set_physics_process(false)
	gravity_scale = 1.0
	timer.start()

func _on_timer_timeout():
	queue_free()
	died.emit()



func set_color_recursive(root: Node, color: Color) -> void:
	if root == null:
		return

	if root is MeshInstance3D:
		_apply_color_to_mesh(root as MeshInstance3D, color)

	for child in root.get_children():
		set_color_recursive(child, color)

func _apply_color_to_mesh(mesh: MeshInstance3D, color: Color) -> void:


	if mesh.mesh == null:
		return

	var std := StandardMaterial3D.new()
	std.albedo_color = color


	mesh.material_override = std
