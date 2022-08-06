extends KinematicBody2D

export var run_speed = 150
var velocity = Vector2.ZERO
var target = weakref(null)

func _physics_process(delta):
    velocity = Vector2.ZERO
    if target.get_ref():
        velocity = position.direction_to(target.get_ref().position) * run_speed
        look_at(target.get_ref().global_position)
    velocity = move_and_slide(velocity)

func ennemy_radius_body_entered(body):
    if body.is_in_group("objects_built_by_player"):
        target = weakref(body)

func _on_DetectRadius_body_exited(body):
    target = weakref(null)

    
