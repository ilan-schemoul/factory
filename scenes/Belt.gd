extends StaticBody2D

signal destroy

func turn_around():
    if not $Sprite.playing:
        $Sprite.play("turn")
        yield(get_tree().create_timer(1.0), "timeout")
        queue_free()
        var phones = get_parent().get_tree().get_nodes_in_group("phones")
        for phone in phones:
            if phone.position.x == position.x and phone.position.y == position.y:
                phone.queue_free()
        emit_signal("destroy")

