extends Node3D

signal mob_spawned(mob)

@onready var marker_3d: Marker3D = $Marker3D
@onready var timer: Timer = %Timer

const MOB := preload("res://lessons_reference/video_16/mob/mob.tscn")
const MOB_RUNNER := preload("res://lessons_reference/video_16/mob/mob_runner.tscn")
const MOB_TANK := preload("res://lessons_reference/video_16/mob/mob_tank.tscn")

func _on_timer_timeout():
	var mob_scene: PackedScene = _pick_mob_scene()
	var new_mob = mob_scene.instantiate()

	add_child(new_mob)
	new_mob.global_position = marker_3d.global_position

	mob_spawned.emit(new_mob)

func _pick_mob_scene() -> PackedScene:

	var r := randi() % 10
	if r <= 5:
		return MOB
	elif r <= 8:
		return MOB_RUNNER
	else:
		return MOB_TANK
