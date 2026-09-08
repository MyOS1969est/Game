extends CharacterBody3D

@export var point_a: Vector3 = Vector3(-3, 0, 0)
@export var point_b: Vector3 = Vector3(3, 0, 0)
@export var speed: float = 2.0
var target: Vector3

func _ready() -> void:
    target = point_b

func _physics_process(delta: float) -> void:
    var dir = target - global_transform.origin
    dir.y = 0
    var dist = dir.length()
    if dist < 0.15:
        target = point_a if target == point_b else point_b
        dir = target - global_transform.origin
        dir.y = 0

    if dir.length() > 0.001:
        var move = dir.normalized() * speed
        # Use built-in CharacterBody3D `velocity`
        velocity.x = move.x
        velocity.z = move.z
        velocity.y -= 9.8 * delta
        move_and_slide()

        # rotate to face movement direction smoothly using yaw lerp
        var target_angle = atan2(-move.x, -move.z)
        rotation.y = lerp_angle(rotation.y, target_angle, clamp(8.0 * delta, 0, 1))
    else:
        move_and_slide()
