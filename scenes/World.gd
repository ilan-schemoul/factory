extends Node2D

var disable_waves = true
var waves = [{
        number_of_ennemies = 2,
        start_at = 2000,
        speed = 90,
        done = false
    },
    {
        number_of_ennemies = 1,
        speed = 100,
        start_at = 4000,
        done = false
    },
    {
        number_of_ennemies = 1,
        speed = 110,
        start_at = 10000,
        done = false
    },
    {
        number_of_ennemies = 1,
        speed = 120,
        start_at = 15000,
        done = false
    },
]

onready var DestroySound = preload("res://art/destroy.wav")
onready var BuildingSound = preload("res://art/building.wav")
onready var ShootingSound = preload("res://art/shooting.wav")
onready var grid = get_node("/root/grid")
onready var EnnemySpawn1 = $EnnemySpawn1
onready var EnnemySpawn2 = get_node("EnnemySpawn2")
onready var EnnemySpawn3 = get_node("EnnemySpawn3")

onready var Belt = preload("res://scenes/Belt.tscn")
onready var Bullet = preload("res://scenes/Bullet.tscn")
onready var Ennemy = preload("res://scenes/Ennemy.tscn")
onready var Phone = preload("res://scenes/Phone.tscn")

onready var spawns = [EnnemySpawn1, EnnemySpawn2, EnnemySpawn3]
var money = 1000
var number_of_groups_of_objects = 0
var last_object_of_assembly_line = [$Factory]
var connected_assembly_line = [false]
onready var last_ennemy_spawn_at = OS.get_ticks_msec()
var rng = RandomNumberGenerator.new()
var checked_objects = []

# Called when the node enters the scene tree for the first time.
func _ready():
    rng.randomize()

func belt_is_destroyed():
    if !$Sound.is_playing():
        $Sound.stream = DestroySound
        $Sound.play()
    connected_assembly_line[0] = is_assembly_line_connected()

var next_object_to_check = 0
var found_next_object = false

func update_next_object_to_check(obj1, obj2):
    found_next_object = true
    next_object_to_check = obj2
    checked_objects.append(obj2)

func is_assembly_line_connected():
    next_object_to_check = $Factory
    checked_objects = [next_object_to_check]
    var objects = get_tree().get_nodes_in_group("objects")
    found_next_object = true
    while len(checked_objects) != len(objects) and found_next_object:
        found_next_object = false
        for object in objects:
            if not object in checked_objects:
                touch_each_other(next_object_to_check, object, funcref(self, "update_next_object_to_check"))
            if next_object_to_check.is_in_group("delivery"):
                return true
    return false


func assembly_is_connected(object1, object2):
    connected_assembly_line[get_group_number(object1)] = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    $Euro.text = "Money : " + String(money)

    if not disable_waves:
        for wave in waves:
            if not wave.done and OS.get_ticks_msec() > wave.start_at:
                for i in range(wave.number_of_ennemies):
                    var ennemy_spawn_location = spawns[rng.randi_range(0, 2)].global_position
                    var new_ennemy = Ennemy.instance()
                    new_ennemy.run_speed = wave.speed
                    new_ennemy.connect("destroy", self, "objects_is_destroyed")
                    new_ennemy.global_position = ennemy_spawn_location
                    new_ennemy.global_position.x += rng.randf_range(-60, 60)
                    new_ennemy.global_position.x += rng.randf_range(-60, 60)
                    add_child(new_ennemy)
                    wave.done = true
                    # last_ennemy_spawn_at = OS.get_ticks_msec()

func shoot(transform):
    if money > 0:
        if !$Sound.is_playing():
            $Sound.stream = ShootingSound
            $Sound.play()

        var b = Bullet.instance()
        add_child(b)
        b.transform = transform
        money -= 1
  
func play_again():
    get_tree().paused = true
    get_tree().reload_current_scene()

func get_group(object):
  for group in object.get_groups():
    if group != "objects":
      return group
  return ""

func get_group_number(object):
    if len(object.get_groups()) == 0:
        return 0
    var group = object.get_groups()[0]
    return int(group[len(group) - 1])

func add_to_other_group(object1, object2):
    if get_group(object2) != "delivery":
        object1.add_to_group(get_group(object2))

func touch_each_other(object1, object2, lambda, disable_left = false):
    var right = Vector2()
    right.x = object1.global_position.x + grid.CELL_SIZE
    right.y = object1.global_position.y
    if right.x == object2.global_position.x and right.y == object2.global_position.y:
        lambda.call_func(object1, object2)
        return true

    var top = Vector2()
    top.x = object1.global_position.x
    top.y = object1.global_position.y + grid.CELL_SIZE
    if top.x == object2.global_position.x and top.y == object2.global_position.y:
        lambda.call_func(object1, object2)
        return true

    var bottom = Vector2()
    bottom.x = object1.global_position.x
    bottom.y = object1.global_position.y - grid.CELL_SIZE
    if bottom.x == object2.global_position.x and bottom.y == object2.global_position.y:
        lambda.call_func(object1, object2)
        return true

    if not disable_left:
        var left = Vector2()
        left.x = object1.global_position.x - grid.CELL_SIZE
        left.y = object1.global_position.y
        if left.x == object2.global_position.x and left.y == object2.global_position.y:
            lambda.call_func(object1, object2)
            return true

    return false

func player_builds_object(type, player_position):
    if money <= 0:
        print("No more money")
        return

    if !$Sound.is_playing():
        $Sound.stream = BuildingSound
        $Sound.play()

    var new_object = Belt.instance()
    new_object.connect("destroy", self, "belt_is_destroyed")
    new_object.global_position = grid.position_snapped(player_position)

    for object in get_tree().get_nodes_in_group("objects"):
        if object.global_position.x == new_object.global_position.x and object.global_position.y == new_object.global_position.y:
            return

    for object in get_tree().get_nodes_in_group("objects"):
      touch_each_other(new_object, object, funcref(self, "add_to_other_group"))
    touch_each_other(new_object, $Truck, funcref(self, "assembly_is_connected"))

    last_object_of_assembly_line[get_group_number(new_object)] = new_object

    if len(new_object.get_groups()) > 0:
      new_object.add_to_group("objects")
      new_object.add_to_group("objects_built_by_player")
      add_child(new_object)
      connected_assembly_line[0] = is_assembly_line_connected()
      money -= 10
    else:
      print("You need to build on a rock or assembly line")


func check_earnings():
    money -= len(get_tree().get_nodes_in_group("objects")) - 1
    if money <= 0:
        get_tree().paused = true
        $game_over.visible = true

func move_phone(phone, belt):
    if phone.position.x <= belt.position.x:
        phone.position = belt.position

func phone_delivered():
    money += 100

var possible_next_belts = []

func add_to_array(phone, belt):
    possible_next_belts.append(belt)

func phones_update():
    # creating phone if possible
    var new_phone = Phone.instance()
    new_phone.add_to_group("phones")
    new_phone.connect("delivered", self, "phone_delivered")
    new_phone.position = $Factory.position
    new_phone.position.x += 32
    var phones = get_tree().get_nodes_in_group("phones")
    var create_new_phone = true
    for phone in phones:
        if phone.position.x == new_phone.position.x and phone.position.y == new_phone.position.y:
            create_new_phone = false
    if create_new_phone:
        add_child(new_phone)

    # moving phones
    var belts = get_tree().get_nodes_in_group("objects_built_by_player")
    # belts.append($Truck)
    for phone in phones:
        if not touch_each_other(phone, $Truck, funcref(self, "move_phone")):
            possible_next_belts = []
            for belt in belts:
                var already_a_phone_in_belt = false
                for ph in phones:
                    if ph.position.x == belt.position.x and ph.position.y == belt.position.y:
                        already_a_phone_in_belt = true
                if not already_a_phone_in_belt:
                    touch_each_other(phone, belt, funcref(self, "add_to_array"), true)

            if len(possible_next_belts) > 0:
                var min_belt = possible_next_belts[0]
                var min_dist = possible_next_belts[0].position.distance_to($Truck.position)
                for belt in possible_next_belts:
                    if belt.position.distance_to($Truck.position) < min_dist:
                        min_belt = belt
                        min_dist = belt.position.distance_to($Truck.position)
                move_phone(phone, min_belt)

