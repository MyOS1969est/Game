extends Area3D

func _ready() -> void:
    connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body) -> void:
    print("Heirloom inspected by: ", body.name)
