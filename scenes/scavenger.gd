extends CharacterBody3D

@export var point_a := Vector3(2.7, 0, 1.3)
@export var point_b := Vector3(5.8, 0, -0.8)
@export var speed: float = 1.3
var target: Vector3
var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	target = point_b

func _physics_process(delta: float) -> void:
	var direction := target - global_position
	direction.y = 0.0
	if direction.length() < 0.2:
		target = point_a if target == point_b else point_b
		direction = target - global_position
		direction.y = 0.0
	direction = direction.normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	velocity.y = 0.0 if is_on_floor() else velocity.y - gravity * delta
	move_and_slide()
	if direction.length_squared() > 0.001:
		$Visuals.rotation.y = lerp_angle($Visuals.rotation.y, atan2(-direction.x, -direction.z), minf(8.0 * delta, 1.0))
