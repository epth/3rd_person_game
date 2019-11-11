extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var velocity:Vector3
var gravity=-9.8
#const SPEED=6
const ACCELERATION=6
const DE_ACCELERATION=20
var state
onready var player=self
onready var anitree=get_node("AnimationTree")
onready var statemachine=get_node("AnimationTree")["parameters/playback"]
onready var camera_helper=get_node("RotationHelperCenter/RotationHelperX")
onready var fsm=preload("res://Script/fsm.gd").new()
onready var ammo = preload("res://scene/ammo.tscn")
onready var ammo_pos = get_node("ammoPos")
onready var gongjian_bone=get_node("Armature/Skeleton/BoneGongjian/gongjian")
onready var gong_bone=get_node("Armature/Skeleton/BoneGong/gong")
static func lerp_angle(from, to, weight):
    return from + _short_angle_dist(from, to) * weight

static func _short_angle_dist(from, to):
    var max_angle = PI * 2
    var difference = fmod(to - from, max_angle)
    return fmod(2 * difference, max_angle) - difference
func _ready():
    fsm.add_group("IDLE")
    fsm.add_group("ATTACK")
    
    fsm.add_state("idle",null,"IDLE")
    fsm.add_state("running",null,"IDLE")
    fsm.add_state("pre_jump")
    fsm.add_state("jumping")
    fsm.add_state("pre_fire")
    fsm.add_state("fire")
    
    fsm.add_link("idle","running","condition",[self,"is_moving",true])
    fsm.add_link("running","idle","condition",[self,"is_idle",true])
    fsm.add_link("idle","pre_jump","condition",[self,"is_jump",true])
    fsm.add_link("running","pre_jump","condition",[self,"is_jump",true])
    fsm.add_link("pre_jump","jumping","timeout",[0.1])
    fsm.add_link("jumping","idle","timeout",[1])
    fsm.add_link("IDLE","pre_fire","condition",[self,"is_pre_fire",true])
    fsm.add_link("pre_fire","fire","condition",[self,"is_fire",true])
    fsm.add_link("pre_fire","idle","condition",[self,"is_prefire_to_idle",true])
    fsm.add_link("fire","idle","timeout",[0.1])
    
    fsm.set_state("idle")
    fsm.connect("state_changed",self,"on_state_changed")

func on_state_changed(state_from,state_to,args):
    print(state_to)
    player.on_state_changed(state_from,state_to,args)
#    match state_to:
#        "idle":
#            state="idle"
#            gongjian_bone.hide()
#            anitree["parameters/playback"].travel("idle_cycle")
#        "running":
#            state="running"
#            gongjian_bone.hide()
#            anitree["parameters/playback"].travel("running_slow_cycle")
#        "pre_fire":
#            state="pre_fire"
#            anitree["parameters/playback"].travel("shooting_arrow_cycle_head")
#            gongjian_bone.show()
#
#        "fire":
#            state="fire"
#            anitree["parameters/playback"].travel("shooting_arrow_cycle.end")
#            gongjian_bone.hide()
#            var ammo_clone=ammo.instance()
#            var scene_root = get_tree().root.get_children()[0]
#
#            scene_root.add_child(ammo_clone)
#
#            ammo_clone.global_transform = ammo_pos.global_transform
#            ammo_clone.parent_object=self
#            var camera=Global.camera
#            var from = camera.project_ray_origin(Global.rect_size/2)
#            var to = from + camera.project_ray_normal(Global.rect_size/2) * 1000
#            var space_state=get_world().direct_space_state
#            var result = space_state.intersect_ray(from, to)
#            if result.size():
#                ammo_clone.aim_position=result["position"]
#        "pre_jump":
#            state="pre_jump"
#            statemachine.travel("unarmed_jump_up")
#            velocity.y=5


#func is_jumping_to_idle():
#    if anitree["parameters/playback"].get_current_node()!="unarmed_jump_up":
#        return true        
        
func is_moving():
    if(Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")):
        return true

func is_idle():
    if(Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")):
        return false
    else:
        return true
func is_jump():
    if Input.is_action_just_pressed("ui_select"):
        return true

func is_pre_fire():
    if Input.is_action_pressed("fire"):
        return true
func is_prefire_to_idle():
    if not Input.is_action_pressed("fire") and anitree["parameters/playback"].get_current_node()=="shooting_arrow_cycle_head":
        return true
        
func is_fire():
    if not Input.is_action_pressed("fire") and anitree["parameters/playback"].get_current_node()=="shooting_arrow_cycle.freeze":
        return true
        
func handle_shoot():
    pass


func _process(delta):
    fsm.process(delta)
    process_move(delta)
    process_state(delta)
    

func process_move(delta):
    if delta:
        if fsm.current_state=="running":
            var dir=Vector3(0,0,0)
            var camera_tsf=camera_helper.get_global_transform()
            
            var a=anitree.get_root_motion_transform().origin.z
            a=abs(a)
            if(Input.is_action_pressed("ui_up")):
                anitree.active=true
                dir+= -camera_tsf.basis[2]*a/delta
            if(Input.is_action_pressed("ui_down")):
                anitree.active=true
                dir+= +camera_tsf.basis[2]*a/delta
            if(Input.is_action_pressed("ui_left")):
                anitree.active=true
                dir+= -camera_tsf.basis[0]*a/delta
            if(Input.is_action_pressed("ui_right")):
                anitree.active=true
                dir+= +camera_tsf.basis[0]*a/delta
            dir.y=0
    #        dir=dir.normalized()
            
            velocity.y+=delta*gravity
            
            var hv=velocity
            hv.y=0
            
    #        var new_pos=dir*SPEED
            var new_pos=dir
            var accel=DE_ACCELERATION
            
            if (dir.dot(hv)>0):
                accel=ACCELERATION
            hv= hv.linear_interpolate(new_pos,accel*delta)
            velocity.x=hv.x
            velocity.z=hv.z
            
            velocity=move_and_slide(velocity,Vector3(0,1,0))
    #        get_node("../Camera").translation.z = translation.z+1.5
    #        get_node("../Camera").translation.x = translation.x
            #rotation BEGIN
            if dir.length()>0:
                # way first
    #            var angle=atan2(dir.x,dir.z)
    #            char_rot.y=angle
    
                #way second
                var c=Vector3(0,0,0)
                $RotationHelperY.look_at(global_transform.origin-dir,Vector3(0,1,0))
                var angle=lerp_angle(player.get_rotation().y,$RotationHelperY.get_rotation().y,1)
                var char_rot=player.get_rotation()
                
    
    #
                char_rot=char_rot.linear_interpolate(Vector3(char_rot.x,angle,char_rot.z),accel*1*delta)
                player.set_rotation(char_rot)
            #rotation END
        if fsm.current_state=="jumping":
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
            
            velocity.y+=delta*gravity
            
            var hv=velocity
            hv.y=0
            
    #        var new_pos=dir*SPEED
            var new_pos=dir
            var accel=DE_ACCELERATION
            
            if (dir.dot(hv)>0):
                accel=ACCELERATION
            hv= hv.linear_interpolate(new_pos,accel*delta)
            velocity.x=hv.x
            velocity.z=hv.z
            
            velocity=move_and_slide(velocity,Vector3(0,1,0))
    #        get_node("../Camera").translation.z = translation.z+1.5
    #        get_node("../Camera").translation.x = translation.x
            #rotation BEGIN
            if dir.length()>0:
                # way first
    #            var angle=atan2(dir.x,dir.z)
    #            char_rot.y=angle
    
                #way second
                var c=Vector3(0,0,0)
                $RotationHelperY.look_at(global_transform.origin-dir,Vector3(0,1,0))
                var angle=lerp_angle(player.get_rotation().y,$RotationHelperY.get_rotation().y,1)
                var char_rot=player.get_rotation()
                
    
    #
                char_rot=char_rot.linear_interpolate(Vector3(char_rot.x,angle,char_rot.z),accel*1*delta)
                player.set_rotation(char_rot)
            
func process_state(delta):
    match state:
        "pre_fire":
            player.look_at(get_global_transform().origin+camera_helper.get_global_transform().basis.z*Vector3(1,0,1),Vector3(0,1,0))

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
    
