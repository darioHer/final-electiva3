extends RigidBody3D
signal died

@export var speed: float = 2.0
@export var health: int = 6
@export var xp_reward: int = 3

@onready var model: Node3D = %bat_model
@onready var timer: Timer = %Timer
@onready var player: Node3D = get_node("/root/Game/Player")

func _ready():
	set_color(Color.DODGER_BLUE)
	scale *= 1.2

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


func set_color(color: Color) -> void:
	for child in model.get_children():
		if child is MeshInstance3D:
			var mesh := child as MeshInstance3D



			var base_mat: Material = mesh.get_surface_override_material(0)
			if base_mat == null:
				base_mat = mesh.get_active_material(0)

	
	
			var mat3d := base_mat as BaseMaterial3D
			if mat3d == null:
				continue

			var dup := mat3d.duplicate() as BaseMaterial3D
			dup.albedo_color = color
			mesh.set_surface_override_material(0, dup)
