extends KinematicBody2D

signal destroy

export var run_speed = 150
var velocity = Vector2.ZERO
var target = weakref(null)

func _physics_process(delta):
    velocity = Vector2.ZERO

    var objects = get_tree().get_nodes_in_group("objects_built_by_player")
    var target = get_parent().get_node("Player")
    
    # if object go to objects otherwise destroy human
    if len(objects) > 0:
        var nearest_object = objects[0]
        for object in objects:
            if object.global_position.distance_to(global_position) < nearest_object.global_position.distance_to(global_position):
                nearest_object = object
        target = nearest_object

    velocity = position.direction_to(target.position) * run_speed
    look_at(target.global_position)
    velocity = move_and_slide(velocity)

func _on_DetectRadius_body_exited(body):
    target = weakref(null)

func _on_DestroyRadius_body_entered(body):
    yield(get_tree().create_timer(1.0), "timeout")
    if is_instance_valid(body) and body.is_in_group("objects_built_by_player"):
        body.queue_free()
        emit_signal("destroy")
