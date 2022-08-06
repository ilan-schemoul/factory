extends Node2D

onready var grid = get_node("/root/grid")

var money = 100
var number_of_groups_of_objects = 0
var last_object_of_assembly_line = [$Rock]
var connected_assembly_line = [false]

onready var Object1 = preload("res://scenes/Object1.tscn")
onready var Bullet = preload("res://scenes/Bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func assembly_is_connected(object1, object2):
    print(get_group_number(object1))
    connected_assembly_line[get_group_number(object1)] = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    $Euro.text = String(money)

func shoot(transform):
  if money > 0:
    var b = Bullet.instance()
    add_child(b)
    b.transform = transform
    money -= 1

func get_group(object):
  for group in object.get_groups():
    if group != "objects":
      return group

func get_group_number(object):
    if len(object.get_groups()) == 0:
        print(object.get_name() + " has no group")
        return 0
    var group = object.get_groups()[0]
    return int(group[len(group) - 1])

func add_to_other_group(object1, object2):
    object1.add_to_group(get_group(object2))

func touch_each_other(object1, object2, lambda):
    var left = Vector2()
    left.x = object1.global_position.x - grid.CELL_SIZE
    left.y = object1.global_position.y
    if left.x == object2.global_position.x and left.y == object2.global_position.y:
        lambda.call_func(object1, object2)

    var right = Vector2()
    right.x = object1.global_position.x + grid.CELL_SIZE
    right.y = object1.global_position.y
    if right.x == object2.global_position.x and right.y == object2.global_position.y:
        lambda.call_func(object1, object2)
    print(right, object2.global_position)

    var top = Vector2()
    top.x = object1.global_position.x
    top.y = object1.global_position.y + grid.CELL_SIZE
    if top.x == object2.global_position.x and top.y == object2.global_position.y:
        lambda.call_func(object1, object2)

    var bottom = Vector2()
    bottom.x = object1.global_position.x
    bottom.y = object1.global_position.y - grid.CELL_SIZE
    if bottom.x == object2.global_position.x and bottom.y == object2.global_position.y:
        lambda.call_func(object1, object2)

func player_builds_object(type, player_position):
    var new_object = Object1.instance()
    if money > 0:
        new_object.global_position = grid.position_snapped(player_position)

    for object in get_tree().get_nodes_in_group("objects"):
      touch_each_other(new_object, object, funcref(self, "add_to_other_group"))
    touch_each_other(new_object, $Delivery, funcref(self, "assembly_is_connected"))

    last_object_of_assembly_line[get_group_number(new_object)] = new_object

    if len(new_object.get_groups()) > 0:
      new_object.add_to_group("objects")
      new_object.add_to_group("objects_built_by_player")
      add_child(new_object)
      money -= 10
    else:
      print("You need to build on a rock or assembly line")


func check_earnings():
    money -= len(get_tree().get_nodes_in_group("objects")) - 1
    if connected_assembly_line[0]:
        money += 10

