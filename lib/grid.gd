extends Node

var CELL_SIZE = 32 # or whatever

func position_snapped(pos:Vector2):
    return (pos / CELL_SIZE).floor() * CELL_SIZE

