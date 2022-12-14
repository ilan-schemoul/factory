extends Node2D

export var speed = 400 # How fast the player will move (pixels/sec).
var CELL_SIZE = 32 # or whatever

func position_snapped(pos:Vector2):
    return (pos / CELL_SIZE).floor() * CELL_SIZE

func _ready():
    pass # Replace with function body.

func _process(delta):
    var velocity = Vector2.ZERO # The player's movement vector.
    if Input.is_action_pressed("move_right"):
        velocity.x += 1
    if Input.is_action_pressed("move_left"):
        velocity.x -= 1
    if Input.is_action_pressed("move_down"):
        velocity.y += 1
    if Input.is_action_pressed("move_up"):
        velocity.y -= 1
    if Input.is_action_pressed("1"):



    if velocity.length() > 0:
        velocity = velocity.normalized() * speed
    position += velocity * delta
        # $AnimatedSprite.play()
    # else:
        # $AnimatedSprite.stop()
