extends Sprite

signal delivered
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass


func _on_Area2D_body_entered(body:Node):
    if body.is_in_group("delivery"):
        yield(get_tree().create_timer(.2), "timeout")
        queue_free()
        emit_signal("delivered")
