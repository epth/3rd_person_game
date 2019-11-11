extends Node
var player:KinematicBody
var nav:Navigation
var current_scene = null
var camera:InterpolatedCamera
var rect_size:Vector2
var character:Spatial
func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    var root = get_tree().get_root()
    current_scene = root.get_child(root.get_child_count() - 1)
    nav=current_scene.get_node("Navigation")
    player=current_scene.get_node("Player")
    character=player.get_node("player")
    camera=player.get_node("InterpolatedCamera")
    get_tree().get_root().connect("size_changed", self, "on_resize")
    rect_size=get_viewport().size
func on_resize():
    rect_size=get_viewport().size

func _input(event):
    if event.is_action_pressed("ui_cancel"):
        if Input.get_mouse_mode() ==Input.MOUSE_MODE_VISIBLE:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        elif Input.get_mouse_mode() ==Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
