extends RayCast2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if is_colliding():
        var target = get_collider()
        if target.is_in_group("objects_built_by_player"):
            target.queue_free()
