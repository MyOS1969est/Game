extends CharacterBody3D

@export var speed: float = 4.0
var velocity: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
    var input_dir = Vector3(
        Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
        0,
        Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    )
    if input_dir.length() > 0:
        input_dir = input_dir.normalized() * speed

    velocity.x = input_dir.x
    velocity.z = input_dir.z
    velocity.y -= 9.8 * delta

    velocity = move_and_slide(velocity, Vector3.UP)
