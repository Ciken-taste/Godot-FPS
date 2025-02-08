extends CharacterBody3D


const SPEED = 0.05
const JUMP_VELOCITY = 4.5

var closing_in : bool = false
var is_player_spotted : bool = false
var rotation_patrol : float = 0
var rotation_dir : int = 1

var player_pos : Vector3 = Vector3.ZERO

var ready_to_fire : bool = true
var firing : bool = false

@onready var gunshot_audio := ($AudioStreamPlayer3D as AudioStreamPlayer3D)
@onready var gun_timer := ($GunTimer as Timer)
@onready var gun := ($Gun as MeshInstance3D)
@onready var gun_muzzle := ($Gun/Muzzle as Marker3D)

func approaching_player():
	global_position -= transform.basis.z * SPEED
	if global_position.distance_to(PlayerVars.current_pos) < 20:
		closing_in = false

func patrol():
	rotation_patrol += PI/120 * rotation_dir
	rotation.y = rotation_patrol
	if rotation_patrol >= PI/2 or rotation_patrol <= -PI/2:
		rotation_dir *= -1

func shoot():
	if ready_to_fire and firing:
		gunshot_audio.play(1.3)
		gun_timer.start()
		ready_to_fire = false
		var bullet = preload("res://bullet.tscn")
		bullet = bullet.instantiate()
		bullet.position = gun_muzzle.global_position
		bullet.rotation.y = rotation.y
		bullet.rotation.x = gun.rotation.x
		get_parent().add_child(bullet)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	# if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# if direction:
	# 	velocity.x = direction.x * SPEED
	# 	velocity.z = direction.z * SPEED
	#else:
	#	velocity.x = move_toward(velocity.x, 0, SPEED)
	#	velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if not is_player_spotted:
		patrol()
	else:
		look_at(PlayerVars.current_pos)
		if global_position.distance_to(PlayerVars.current_pos) >= 50:
			closing_in = true
			
		if not closing_in:
			gun.rotation.x = clamp(rotation.x + global_position.distance_to(PlayerVars.current_pos) * 0.0005, -PI/4, PI/3)
			rotation.x = 0
			shoot()
		else:
			approaching_player()
	
	move_and_slide()


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("Player"):
		is_player_spotted = true


func _on_gun_timer_timeout() -> void:
	ready_to_fire = true


func _on_hit_box_area_entered(area: Area3D) -> void:
	if area.is_in_group("Bullet"):
		queue_free()


func _on_burst_timer_timeout() -> void:
	firing = not firing
