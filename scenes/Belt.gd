extends StaticBody2D

signal destroy

func turn_around():
    if not $Sprite.playing:
        $Sprite.play("turn")
        yield(get_tree().create_timer(1.0), "timeout")
        queue_free()
        emit_signal("destroy")

