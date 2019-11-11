extends Node
var statemachine:AnimationNodeStateMachinePlayback
var last=null
var current=null
func _ready():
    statemachine=get_node("../player/AnimationTree")["parameters/playback"]

func _process(delta):
    var cur_tmp=statemachine.get_current_node()
    if cur_tmp!=current:
        last=current
        current=cur_tmp
