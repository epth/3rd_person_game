extends KinematicBody
signal selected(node)
var path=[]
var path_ind=0
var move_speed=2
onready var nav =Global.nav
var attack_target=null
var state="idle"
onready var origin=global_transform.origin
var behit_damage=0
var target_last_pos=null
var is_request_stop_attack_cycle=false
onready var anitree=get_node("monster/AnimationTree")
onready var fsm=preload("res://Script/fsm.gd").new()
onready var Queue=preload("res://Script/queue.gd").new()
onready var statemachine=get_node("monster/AnimationTree")["parameters/playback"]
onready var attack_type:Array
func can_be_hit():
    return true


func _ready():
    randomize()
    attack_type.append("slash2")
    attack_type.append("slash3")
    attack_type.append("casting")
    $monster/AnimationPlayer.connect("animation_finished",self,"_on_AnimationPlayer_finished")
#    $monster/AnimationPlayer.play("idle_cycle",0.1)
    connect("selected",Global.player,"handle_shoot")
    fsm.add_group("ALL")
    fsm.add_group("IDLE",null,"ALL")
    fsm.add_group("BEATTACK",null,"ALL")
    fsm.add_group("ATTACK",null,"ALL")
    
    fsm.add_state("idle",null,"IDLE")
    fsm.add_state("idle_walk",null,"IDLE")
    fsm.add_state("be_attack",null,"BEATTACK")
    fsm.add_state("attack_walk",null,"ATTACK")
    fsm.add_state("attack_retarget")
    fsm.add_state("attack",null,"ATTACK")
    fsm.add_state("back_walk")
    fsm.add_state("death")
    
    fsm.add_link("idle","idle_walk","timeout random",[[1,10]])
    fsm.add_link("idle_walk","idle","timeout random",[[1,3]])
    fsm.add_link("IDLE","be_attack","condition",[self,"is_be_attack",true])
    fsm.add_link("IDLE","attack_walk","condition",[self,"has_attack_target",true])
    fsm.add_link("BEATTACK","attack_walk","condition",[self,"is_BEATTACK_to_attack_walk",true])
    
    fsm.add_link("ATTACK","be_attack","condition",[self,"is_be_attack",true])
    
    fsm.add_link("attack_walk","attack","condition",[self,"is_target_near",true])
    fsm.add_link("ATTACK","attack_retarget","condition",[self,"is_turn_to_attack_retarget",true])
    fsm.add_link("attack_retarget","attack_walk","condition",[self,"has_attack_target",true])
    fsm.add_link("attack","idle","condition",[self,"is_attack_to_idle",true])
    fsm.add_link("ATTACK","back_walk","condition",[self,"target_down_or_far",true])
    fsm.add_link("back_walk","idle","condition",[self,"in_origin",true])
    
    fsm.add_link("ALL","death","condition",[self,"is_death",true])
    fsm.set_state("idle")
    fsm.connect("state_changed",self,"on_state_changed")
func is_attack_to_idle():
    if statemachine.get_current_node()=="idle_cycle":
        return true
func is_BEATTACK_to_attack_walk():
    if has_attack_target() and state!="attack" and not attack_type.has(statemachine.get_current_node()):
        return true

func has_attack_target():
    return attack_target != null
func is_death():
    return $Viewport/Control/Progress.value==0
func is_target_near():
    return ((global_transform.origin-attack_target.global_transform.origin)*Vector3(1,0,1)).length()<1.5
func is_be_attack():
    return behit_damage>0
#目标位置变化 且 动画不是attack_cycle 时进入到下一个状态
func is_turn_to_attack_retarget():
    if ((attack_target.global_transform.origin-target_last_pos)*Vector3(1,0,1)).length()>1:
        if state=="attack":
            if not attack_type.has(statemachine.get_current_node()):
                return true
        elif state=="attack_walk":
            return true
    return false

    

func movearound_and_look():
    var x=float(rand_range(-100,100))
    var z=float(rand_range(-100,100))
    var position=global_transform.origin+Vector3(x,0,z)
    $monster.look_at(global_transform.origin*2-position,Vector3(0,1,0))
    move_to_position(position)

func _input_event(camera, event, click_position, click_normal, shape_idx):
    if (event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT):
        emit_signal("selected",self)

func _process(delta):
    if delta:
        fsm.process(delta)
        match state:
            "idle":
                var basis=$monster.get_global_transform().basis
                var root_motion=anitree.get_root_motion_transform().origin
                move_and_slide(basis.z*root_motion.z/delta,Vector3(0,1,0))
                move_and_slide(basis.x*root_motion.x/delta,Vector3(0,1,0))
            "attack":
                var basis=$monster.get_global_transform().basis
                var root_motion=anitree.get_root_motion_transform().origin
                move_and_slide(basis.z*root_motion.z/delta,Vector3(0,1,0))
                move_and_slide(basis.x*root_motion.x/delta,Vector3(0,1,0))
            "idle_walk":
                var root_motion=anitree.get_root_motion_transform().origin
                if path_ind<path.size():
                    var move_vec=(path[path_ind]-global_transform.origin)
                    if move_vec.length()<0.1:
                        path_ind+=1
                    else:
                        move_and_slide(move_vec.normalized()*root_motion.length()/delta,Vector3(0,1,0))
            "attack_walk":
                $monster.look_at((global_transform.origin*2-attack_target.global_transform.origin)*Vector3(1,0,1)+global_transform.origin*Vector3(0,1,0),Vector3(0,1,0))
                if path_ind<path.size():
                    var move_vec=(path[path_ind]-global_transform.origin)
                    if move_vec.length()<0.1:
                        path_ind+=1
                    else:
                        move_and_slide(move_vec.normalized()*move_speed,Vector3(0,1,0))


func move_to_position(pos):
    path=nav.get_simple_path(global_transform.origin,pos)
    path_ind=0
func move_to_object(object):
    path=nav.get_simple_path(global_transform.origin,object.global_transform.origin)
    path_ind=0



func on_state_changed(state_from,state_to,args):
    match state_to:
        "idle":
            state="idle"
#            $monster/AnimationPlayer.play("idle_cycle",0.1)
            statemachine.travel("idle_cycle")
        "idle_walk":
            state="idle_walk"
#            $monster/AnimationPlayer.play("walk_cycle",0.2)
            move_speed=2
            statemachine.travel("walk_cycle")
            movearound_and_look()
        "be_attack":
            state="be_attack"
            $Viewport/Control/Progress.value-=behit_damage
            behit_damage=0
#            $monster/AnimationPlayer.play("be_attacked",0.2)
        "attack_walk":
            state="attack_walk"
            statemachine.travel("walk_cycle")
            move_speed=4
            move_to_object(attack_target)
            target_last_pos=attack_target.global_transform.origin
            #be_hit(behit_damage,attack_target)
        "attack":
            state="attack"
            
            Queue.set_queue(attack_type)
            var a=Queue.get_random_next()
            statemachine.travel(a)
            
#            while state=="attack":
#                yield(get_tree().create_timer(10),"timeout")
#                statemachine.travel(rd_queue.get_one())
                
#            $monster/AnimationPlayer.play("attack_cycle",0.2)
        "death":
            state="death"
            yield(get_tree().create_timer(5),"timeout")
            queue_free()
func _on_AnimationPlayer_finished(name):
    if $monster/AnimationPlayer.current_animation=="attack_cycle":
        if is_request_stop_attack_cycle:
            $monster/AnimationPlayer.stop()
            is_request_stop_attack_cycle=false
    
