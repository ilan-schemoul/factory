extends KinematicBody2D

export var speed = 400 # How fast the player will move (pixels/sec).
export var interval_between_building = 10
export var interval_between_shots = 200

signal build_object(type, player_position)
signal shoot(transform)

onready var last_object_built_at = OS.get_ticks_msec()
onready var last_shot_at = OS.get_ticks_msec()
onready var grid = get_node("/root/grid")

var mode = "building"

func _ready():
    pass # Replace with function body.

func _process(delta):
    var pos_on_grid = grid.position_snapped(global_position)
    $ObjectHover.global_position = pos_on_grid

    $Character.get_node("Weapon").look_at(get_global_mouse_position())

    var velocity = Vector2.ZERO # The player's movement vector.
    if Input.is_action_pressed("move_right"):
        velocity.x += 1
        $Character.get_node("Animation").play("running_right")
    elif Input.is_action_pressed("move_left"):
        velocity.x -= 1
        $Character.get_node("Animation").play("running_left")
    elif Input.is_action_pressed("move_down"):
        velocity.y += 1
        $Character.get_node("Animation").play("running_down")
    elif Input.is_action_pressed("move_up"):
        velocity.y -= 1
        $Character.get_node("Animation").play("running_up")
    else:
        $Character.get_node("Animation").play("RESET")
    if Input.is_action_pressed("1"):
        get_parent().get_node("BuildLabel").modulate.a = 1
        get_parent().get_node("GunLabel").modulate.a = 0.5
        mode = "building"
        $ObjectHover.visible = true
        $Character.get_node("Weapon").visible = false
    if Input.is_action_pressed("2"):
        get_parent().get_node("BuildLabel").modulate.a = 0.5
        get_parent().get_node("GunLabel").modulate.a = 1
        mode = "shooting"
        $ObjectHover.visible = false
        $Character.get_node("Weapon").visible = true
    if Input.is_action_pressed("click"):
        if mode == "building":
            if OS.get_ticks_msec() - last_object_built_at > interval_between_building:
                emit_signal("build_object", 1, global_position)
                last_object_built_at = OS.get_ticks_msec()
        elif mode == "shooting":
            if OS.get_ticks_msec() - last_shot_at > interval_between_shots:
                emit_signal("shoot", $Character.get_node("Weapon").global_transform)
                last_shot_at = OS.get_ticks_msec()

    if velocity.length() > 0:
        velocity = velocity.normalized() * speed
    position += velocity * delta
        # $AnimatedSprite.play()
    # else:
        # $AnimatedSprite.stop()
