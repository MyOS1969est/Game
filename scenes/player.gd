extends CharacterBody3D

@export var speed: float = 4.2
@export var turn_speed: float = 12.0
@export var can_shift_panels: bool = true
var camera: Camera3D
var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("player")
	camera = get_viewport().get_camera_3d()

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var right := Vector3.RIGHT
	var backward := Vector3.BACK
	if is_instance_valid(camera):
		right = camera.global_basis.x
		backward = camera.global_basis.z
		right.y = 0.0
		backward.y = 0.0
		right = right.normalized()
		backward = backward.normalized()
	var direction := right * input_vector.x + backward * input_vector.y
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= gravity * delta
	move_and_slide()
	if direction.length_squared() > 0.001:
		var target_angle := atan2(-direction.x, -direction.z)
		$Visuals.rotation.y = lerp_angle($Visuals.rotation.y, target_angle, minf(turn_speed * delta, 1.0))

func play_interaction(target: Vector3, heavy: bool = false) -> void:
	var direction := target - global_position
	if direction.length_squared() > 0.01:
		$Visuals.rotation.y = atan2(-direction.x, -direction.z)
	$Visuals.perform_interaction(heavy)
