extends Control

const COLOR = Color(1, 1, 1)
func _ready():
    rect_position=get_viewport().size/2
    get_tree().get_root().connect("size_changed", self, "on_resize")

func on_resize():
    rect_position=get_viewport().size/2
    
func draw_circle_arc(center, radius, angle_from, angle_to, color):
    var nb_points = 32
    var points_arc = PoolVector2Array()

    for i in range(nb_points + 1):
        var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
        points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

    for index_point in range(nb_points):
        draw_line(points_arc[index_point], points_arc[index_point + 1], color)
func _draw():
    draw_circle(Vector2(0,0),1.0,COLOR)
    var center = Vector2(0, 0)
    var radius = 18
    var angle_from = 45
    var angle_to = 135
    draw_circle_arc(center, radius, angle_from, angle_to, COLOR)
    angle_from = 225
    angle_to = 315
    draw_circle_arc(center, radius, angle_from, angle_to, COLOR)
    
