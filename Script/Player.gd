extends KinematicBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var velocityY:=Vector3.ZERO
var velocityXZ:=Vector3.ZERO
var gravity=-9.8
#const SPEED=6
const ACCELERATION=6
const DE_ACCELERATION=20
onready var player=get_node("player")
onready var anitree=get_node("player/AnimationTree")
onready var statemachine=get_node("player/AnimationTree")["parameters/playback"]
onready var camera_helper=get_node("RotationHelperCenter/RotationHelperX")
var fsm
var _is_on_floor=false
static func lerp_angle(from, to, weight):
    return from + _short_angle_dist(from, to) * weight

static func _short_angle_dist(from, to):
    var max_angle = PI * 2
    var difference = fmod(to - from, max_angle)
    return fmod(2 * difference, max_angle) - difference
    
func _ready():
    fsm=$player.fsm

#func on_state_changed(state_from,state_to,args):
#    player.on_state_changed(state_from,state_to,args)


func _process(delta):
    process_move(delta)
    process_state(delta)
    print(_is_on_floor)
    

func process_move(delta):
    if delta:
        velocityY.y+=gravity*delta
        velocityY= move_and_slide(Vector3(0,1,0)*velocityY.y,Vector3(0,1,0))
        _is_on_floor=is_on_floor()
        match fsm.current_state:
            "idle":
                var basis=$player.get_global_transform().basis
                var root_motion=anitree.get_root_motion_transform().origin
                move_and_slide(basis.z*root_motion.z/delta,Vector3(0,1,0))
                move_and_slide(basis.x*root_motion.x/delta,Vector3(0,1,0))
            "fire":
                var basis=$player.get_global_transform().basis
                var root_motion=anitree.get_root_motion_transform().origin
                move_and_slide(basis.z*root_motion.z/delta,Vector3(0,1,0))
                move_and_slide(basis.x*root_motion.x/delta,Vector3(0,1,0))
            "running":
                var dir=Vector3(0,0,0)
                var camera_tsf=camera_helper.get_global_transform()
                
                var basis=$player.get_global_transform().basis
                var root_motion=anitree.get_root_motion_transform().origin
                move_and_slide(basis.z*root_motion.z/delta,Vector3(0,1,0))
                move_and_slide(basis.x*root_motion.x/delta,Vector3(0,1,0))
                if(Input.is_action_pressed("ui_up")):
                    dir+= -camera_tsf.basis[2]
                if(Input.is_action_pressed("ui_down")):
                    dir+= +camera_tsf.basis[2]
                if(Input.is_action_pressed("ui_left")):
                    dir+= -camera_tsf.basis[0]
                if(Input.is_action_pressed("ui_right")):
                    dir+= +camera_tsf.basis[0]
                var c=Vector3(0,0,0)
                $RotationHelperY.look_at(global_transform.origin-dir,Vector3(0,1,0))
                var angle=lerp_angle(player.get_rotation().y,$RotationHelperY.get_rotation().y,1)
                var char_rot=player.get_rotation()
                char_rot=char_rot.linear_interpolate(Vector3(char_rot.x,angle,char_rot.z),ACCELERATION*delta)
                player.set_rotation(char_rot)
            "jumping":
                var dir=Vector3(0,0,0)
                var camera_tsf=camera_helper.get_global_transform()
                
                if(Input.is_action_pressed("ui_up")):
                    dir+= -camera_tsf.basis[2]
                if(Input.is_action_pressed("ui_down")):
                    dir+= +camera_tsf.basis[2]
                if(Input.is_action_pressed("ui_left")):
                    dir+= -camera_tsf.basis[0]
                if(Input.is_action_pressed("ui_right")):
                    dir+= +camera_tsf.basis[0]
                var SPEED=6
                dir.y=0
                dir=dir.normalized()*SPEED
                
                var hv=velocityXZ
                hv.y=0
                
                velocityXZ=hv.linear_interpolate(Vector3(dir.x,0,dir.z),ACCELERATION*delta)
                velocityXZ=move_and_slide(velocityXZ,Vector3(0,1,0))
                if dir.length()>0:
                    #way second
                    var c=Vector3(0,0,0)
                    $RotationHelperY.look_at(global_transform.origin-dir,Vector3(0,1,0))
                    var angle=lerp_angle(player.get_rotation().y,$RotationHelperY.get_rotation().y,1)
                    var char_rot=player.get_rotation()
                    
                    char_rot=char_rot.linear_interpolate(Vector3(char_rot.x,angle,char_rot.z),ACCELERATION*delta)
                    player.set_rotation(char_rot)
            
func process_state(delta):
    pass
#    match fsm.current_state:
#        "pre_fire":
#            player.look_at(get_global_transform().origin+camera_helper.get_global_transform().basis.z*Vector3(1,0,1),Vector3(0,1,0))

func _input(event):
    if Input.is_action_just_pressed("zoom"):
        $Tween.interpolate_property(Global.camera,"fov",Global.camera.fov,40,0.15,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
        $Tween.start()
    if Input.is_action_just_released("zoom"):
        $Tween.interpolate_property(Global.camera,"fov",Global.camera.fov,70,0.15,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
        $Tween.start()
    if Input.is_action_just_pressed("shift"):
        anitree["parameters/run/TimeScale/scale"]=1.6
    if Input.is_action_just_released("shift"):
        anitree["parameters/run/TimeScale/scale"]=1
    
