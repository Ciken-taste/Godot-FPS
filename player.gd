extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.01

var is_shooting : bool = false
var ready_to_fire : bool = true

@onready var gun_muzzle := ($Camera3D/Gun/Muzzle as Marker3D)
@onready var camera := ($Camera3D as Camera3D)
@onready var gun_timer := ($GunTimer as Timer)
@onready var gunshot_audio := ($Gunshot as AudioStreamPlayer)
@onready var health_bar := ($HUD/HealthBar as ProgressBar)

@onready var interaction_label := ($HUD/InteractionLabel as Label)

func shoot() -> void:
	if ready_to_fire:
		gunshot_audio.play(1.3)
		gun_timer.start()
		ready_to_fire = false
		var bullet = preload("res://bullet.tscn")
		bullet = bullet.instantiate()
		bullet.position = gun_muzzle.global_position
		bullet.rotation.y = rotation.y
		bullet.rotation.x = camera.rotation.x
		get_parent().add_child(bullet)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * MOUSE_SENSITIVITY
	if event.is_action_pressed("shoot"):
		is_shooting = true
	if event.is_action_released("shoot"):
		is_shooting = false


func _physics_process(delta: float) -> void:
	PlayerVars.current_pos = global_position
	if is_shooting:
		
		shoot()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()




func _on_gun_timer_timeout() -> void:
	ready_to_fire = true
	gun_timer.stop()


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("Bullet"):
		PlayerVars.health -= 10
		health_bar.value = PlayerVars.health


func _on_interaction_zone_area_entered(area: Area3D) -> void:
	if area.is_in_group("Door"):
		interaction_label.show()

func _on_interaction_zone_area_exited(area: Area3D) -> void:
	if area.is_in_group("Door"):
		interaction_label.hide()
