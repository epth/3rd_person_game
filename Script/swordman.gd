extends Spatial
signal fireclick
var state
onready var anitree=get_node("AnimationTree")
onready var statemachine=get_node("AnimationTree")["parameters/playback"]
var velocity=Vector3(0,0,0)
onready var fsm=preload("res://Script/fsm.gd").new()
onready var queue=preload("res://Script/queue.gd").new()
onready var statemachineSpy=get_node("../statemachineplaybackSpy")
var time_counter=0
onready var attack_type:Array
var statemachinetraveling

func _ready():
    attack_type.append("slash_01")
    attack_type.append("slash_02")
    attack_type.append("slash_04")
    queue.set_queue(attack_type)
    
    fsm.add_group("IDLE")
    fsm.add_group("ATTACK")
    
    fsm.add_state("idle",null,"IDLE")
    fsm.add_state("running",null,"IDLE")
    fsm.add_state("pre_jump")
    fsm.add_state("jumping")
    fsm.add_state("pre_fire")
    fsm.add_state("fire")
    fsm.add_state("pre_fire_next")
    
    fsm.add_link("idle","running","condition",[self,"is_moving",true])
    fsm.add_link("running","idle","condition",[self,"is_idle",true])
    fsm.add_link("idle","pre_jump","condition",[self,"is_jump",true])
    fsm.add_link("running","pre_jump","condition",[self,"is_jump",true])
    fsm.add_link("pre_jump","jumping","timeout",[0.1])
    fsm.add_link("jumping","idle","timeout",[1])
    fsm.add_link("IDLE","pre_fire","condition",[self,"is_press_fire",true])
    fsm.add_link("pre_fire","fire","condition",[self,"is_prefire_to_fire",true])
#    fsm.add_link("fire","pre_fire_next","condition",[self,"is_fire_next",true])
#    fsm.add_link("pre_fire_next","fire","condition",[self,"is_press_fire",true])

#    fsm.add_link("pre_fire","idle","condition",[self,"is_prefire_to_idle",true])
    fsm.add_link("fire","idle","condition",[self,"is_done_fire",true])

    fsm.set_state("idle")
    fsm.connect("state_changed",self,"on_state_changed")

func on_state_changed(state_from,state_to,args):
    print(state_to)
    match state_to:
        "idle":
            queue.cur_index=0
            statemachine.travel("idle_weapon_down")
            statemachinetraveling="idle_weapon_down"
        "running":
            statemachine.travel("run")
        "pre_fire":
            pass
        "fire":
            var tmp=queue.get_one()
            statemachine.travel(tmp)
            time_counter=0
            while true:
                yield(self,"fireclick")
                if fsm.current_state!="fire":
                    return

                #保证是travel到节点
                if not attack_type.has(statemachine.get_current_node()):
                    continue

                var time_scale=anitree["parameters/"+tmp+"/TimeScale/scale"]
                $AnimationPlayer.play(tmp,0,0)
                if $AnimationPlayer.current_animation==tmp and time_counter>$AnimationPlayer.current_animation_length/2/time_scale:
                    tmp=queue.get_one()
                    statemachine.travel(tmp)
                    time_counter=0
                if queue.last==attack_type[len(attack_type)-1]:
                    return
                pass
        "pre_fire_next":
            pass
        "pre_jump":
            statemachine.travel("idle_weapon_down")
            get_parent().velocityY.y=5

func _physics_process(delta):
    time_counter+=delta
    fsm.process(delta)
    


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

func is_press_fire():
    if Input.is_action_just_pressed("fire"):
#        Input.is_action_just_pressed()
        return true
func is_prefire_to_idle():
    if not Input.is_action_pressed("fire") and statemachine.get_current_node()=="shooting_arrow_cycle_head":
        return true
        
func is_fire():
    if not Input.is_action_pressed("fire") and statemachine.get_current_node()=="shooting_arrow_cycle.freeze":
        return true
func is_done_fire():
    if statemachineSpy.current=="idle_weapon_down" or statemachineSpy.current=="idle_weapon_up":
        if attack_type.has(statemachineSpy.last):
            return true
#    if statemachinetraveling=="idle_weapon_down" or statemachinetraveling=="idle_weapon_up":
#        return true

func is_fire_next():
    var cur_action=statemachine.get_current_node()
    if not attack_type.has(cur_action):
        return
    $AnimationPlayer.play(cur_action,0,0)
    
    var time_scale=anitree["parameters/"+cur_action+"/TimeScale/scale"]
    
    if Input.is_action_pressed("fire") and $AnimationPlayer.current_animation==cur_action and time_counter>$AnimationPlayer.current_animation_length/2/time_scale:
        $AnimationPlayer.stop()
        return true
    $AnimationPlayer.stop()
    return false

func is_prefire_to_fire():
    #some condition
    return true

func _input(event):
    if event is InputEventMouseButton and (event.is_pressed() and event.button_index == BUTTON_LEFT):
        print("emit fireclick")
        emit_signal("fireclick")
