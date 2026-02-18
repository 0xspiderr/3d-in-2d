class_name PlayerController extends CharacterBody3D

#region REFERENCES
@onready var gun_sprites: AnimatedSprite2D = %GunSprites
@onready var camera_3d: Camera3D = $Camera3D
@onready var ray_cast_3d: RayCast3D = %RayCast3D
#endregion

@export_group("camera settings")
@export var look_sensitivity: float = 0.006
@export var max_pitch: float = 90.0

@export_group("player settings")
@export var speed: float = 6.5
@export var jump_impulse: float = 3.0


@export_group("gun settings")
@export var max_ammo: int = 12
var current_ammo: int = max_ammo


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	gun_sprites.animation_finished.connect(_on_animation_finished)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("shoot"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_key_pressed(KEY_Q):
		get_tree().quit()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var pitch: float = -event.relative.y * look_sensitivity
		var yaw: float = -event.relative.x * look_sensitivity
		# rotate the player
		rotate_y(yaw)
		# rotate the camera
		camera_3d.rotate_x(pitch)
		camera_3d.rotation.x = clampf(camera_3d.rotation.x, deg_to_rad(-max_pitch), deg_to_rad(max_pitch))
	
	if event.is_action_pressed("jump") and is_on_floor():
		_jump()
	
	if Input.is_action_just_pressed("shoot"):
		_shoot()
	
	if Input.is_action_just_pressed("reload"):
		_reload()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	var input_dir = Input.get_vector("left", "right", "up", "down").normalized()
	var dir = Vector3(input_dir.x, 0.0, input_dir.y).rotated(Vector3.UP, rotation.y)
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	move_and_slide()


func _jump() -> void:
	velocity.y = jump_impulse


func _shoot() -> void:
	if not _can_fire():
		return
	
	gun_sprites.play(&"fire")
	
	ray_cast_3d.force_raycast_update()
	var colliding = ray_cast_3d.is_colliding()
	
	if colliding:
		print(ray_cast_3d.get_collider())
	
	current_ammo -= 1


func _on_animation_finished() -> void:
	gun_sprites.play(&"idle")


func _reload() -> void:
	print("reloaded")
	current_ammo = max_ammo


func _can_fire() -> bool:
	return gun_sprites.animation == &"idle" and current_ammo > 0
