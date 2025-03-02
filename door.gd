extends Node3D

var is_watched : bool = false
var opening : bool = false
var open : bool = false
var rotation_offset : float = 0

func _physics_process(delta: float) -> void:
	toggle_door()
	rotation.y = rotation_offset


func toggle_door() -> void:
	if opening:
		var dir : int = 1
		if open: dir = -1
		rotation_offset += PI/120 * dir
		if rotation_offset >= (3*PI)/4:
			opening = false
			open = true
		if rotation_offset <= 0:
			opening = false
			open = false

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("Bullet"):
		queue_free()
	
	if area.is_in_group("InteractionZone"):
		is_watched = true

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("InteractionZone"):
		is_watched = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact") and is_watched:
		opening = not opening
