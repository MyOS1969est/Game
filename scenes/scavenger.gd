extends CharacterBody3D

@export var point_a: Vector3 = Vector3(-3, 0, 0)
@export var point_b: Vector3 = Vector3(3, 0, 0)
@export var speed: float = 2.0
var target: Vector3
var velocity: Vector3 = Vector3.ZERO

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
        velocity.x = move.x
        velocity.z = move.z
        velocity.y -= 9.8 * delta
        velocity = move_and_slide(velocity, Vector3.UP)

        # rotate to face movement direction smoothly
        var target_rot = Quat(Vector3.UP, atan2(-move.x, -move.z))
        global_transform.basis = global_transform.basis.slerp(Basis(target_rot), clamp(8.0 * delta, 0, 1))
    else:
        velocity = move_and_slide(velocity, Vector3.UP)
