#extends InterpolatedCamera
extends Position3D
#extends Spatial
var MOUSE_SENSITIVITY=0.1
func _input(event):
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        # Mouse rotation.
        
        # Rotate the camera holder (everything that needs to rotate on the X-axis) by the relative Y mouse motion.
        var x_change_deg = event.relative.y * MOUSE_SENSITIVITY *1
        
        # Rotate the kinematic body on the Y axis by the relative X motion.
        # We also need to multiply it by -1 because we're wanting to turn in the same direction as
        # mouse motion in real life. If we physically move the mouse left, we want to turn to the left.
        var y_change_deg = event.relative.x * MOUSE_SENSITIVITY * -1

        # We need to clamp the rotation_helper's rotation so we cannot rotate ourselves upside down
        # We need to do this every time we rotate so we cannot rotate upside down with mouse and/or joypad input
        var curr_x_rot = rad2deg(rotation.x)
        if x_change_deg > 0:
            x_change_deg = min(x_change_deg, 70 + curr_x_rot)
        else:
            x_change_deg = max(x_change_deg, -70 + curr_x_rot)

        
        get_parent().rotate_y(deg2rad(y_change_deg))
        rotate_x(deg2rad(x_change_deg))
