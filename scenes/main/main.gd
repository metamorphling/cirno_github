extends Node2D

signal debug_state_changed(debug_on)

var debug = false
var need_exit = false

func _input(event):
    if event.is_action_pressed("Debug"):
        debug = !debug
        debug_state_changed.emit(debug)
    if event.is_action_pressed("Exit"):
        need_exit = true
        
func _process(delta):
    if (need_exit):
        get_tree().quit()
